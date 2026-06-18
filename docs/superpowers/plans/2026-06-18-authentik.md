# Authentik Forward-Auth Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Authentik as a forward-auth gate for all homelab services behind Caddy, with split server/worker/Redis containers on NAS and a proxy outpost on the router.

**Architecture:** Three NixOS containers on NAS (authentik server, authentik-worker, authentik-redis) sharing host PostgreSQL. Native systemd proxy outpost on router. Caddy virtual hosts auto-generated with forward_auth blocks based on a `protected` flag in homelab.nix.

**Tech Stack:** NixOS containers (systemd-nspawn), Authentik 2025.12.4, PostgreSQL 16 (shared host), Redis, Caddy forward_auth, sops-nix secrets.

______________________________________________________________________

### Task 1: Add Authentik UIDs/GIDs to ids.nix

**Files:**

- Modify: `modules/nixos/ids.nix`

- [ ] **Step 1: Add authentik UIDs/GIDs**

Add entries for `authentik` (UID/GID 362) to both `ourUids` and `ourGids` in `modules/nixos/ids.nix`:

```nix
ourUids = {
  # ... existing entries ...
  hermes = 361;
  authentik = 362;
  toyvo = 1000;
  chloe = 1001;
};

ourGids = {
  # ... existing entries ...
  hermes = 361;
  authentik = 362;
  toyvo = 1000;
  chloe = 1001;
};
```

- [ ] **Step 2: Verify no collision**

Run: `nix flake show`
Expected: No errors (UID 362 is not claimed by any existing package)

- [ ] **Step 3: Commit**

```bash
git add modules/nixos/ids.nix
git commit -m "nixcfg(ids): add authentik uid/gid 362"
```

______________________________________________________________________

### Task 2: Create Authentik Container Module

**Files:**

- Create: `modules/nixos/containers/authentik.nix`

- Modify: `modules/nixos/default.nix`

- [ ] **Step 1: Create the module file**

Create `modules/nixos/containers/authentik.nix` following the established container pattern (see `modules/nixos/containers/monitoring.nix` for reference):

```nix
{
  config,
  lib,
  pkgs,
  homelab,
  ...
}:
let
  cfg = config.nixcfg.containers.authentik;
  ids = config.ids;
in
{
  options.nixcfg.containers.authentik = {
    enable = lib.mkEnableOption "Authentik SSO container";

    hostAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.0.15";
      description = "Host side of the veth pair for the authentik server container";
    };

    localAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.0.16";
      description = "Authentik server container IP address";
    };

    workerHostAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.0.17";
      description = "Host side of the veth pair for the authentik worker container";
    };

    workerLocalAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.0.18";
      description = "Authentik worker container IP address";
    };

    redisHostAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.0.19";
      description = "Host side of the veth pair for the authentik redis container";
    };

    redisLocalAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.0.20";
      description = "Authentik redis container IP address";
    };

    natInterface = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Host WAN-facing interface for NAT masquerade";
    };

    db.location = lib.mkOption {
      type = lib.types.enum [ "internal" "external" ];
      default = "external";
      description = "Where PostgreSQL runs. 'external' uses host PostgreSQL, 'internal' provisions a dedicated container.";
    };

    db.host = lib.mkOption {
      type = lib.types.str;
      default = config.nixcfg.containers.authentik.hostAddress;
      description = "PostgreSQL host address (reachable from container)";
    };

    db.port = lib.mkOption {
      type = lib.types.port;
      default = 5432;
      description = "PostgreSQL port";
    };

    db.name = lib.mkOption {
      type = lib.types.str;
      default = "authentik";
      description = "PostgreSQL database name";
    };

    db.user = lib.mkOption {
      type = lib.types.str;
      default = "authentik";
      description = "PostgreSQL user name";
    };

    db.passwordFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the PostgreSQL password file on the host (decrypted by sops; bind-mounted read-only into containers)";
    };

    redis.location = lib.mkOption {
      type = lib.types.enum [ "internal" "external" ];
      default = "internal";
      description = "Where Redis runs. 'internal' provisions a dedicated container, 'external' uses a host-level Redis.";
    };

    redis.host = lib.mkOption {
      type = lib.types.str;
      default = config.nixcfg.containers.authentik.redisLocalAddress;
      description = "Redis host address (reachable from container)";
    };

    redis.port = lib.mkOption {
      type = lib.types.port;
      default = 6379;
      description = "Redis port";
    };

    secretKeyFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the Authentik secret key file on the host (decrypted by sops; bind-mounted read-only into containers)";
    };

    bootstrapPasswordFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the Authentik bootstrap admin password file on the host (decrypted by sops; bind-mounted read-only into server container)";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = homelab.authentik.services.authentik.port;
      description = "Authentik server listen port";
    };
  };

  config = lib.mkIf cfg.enable {
    # NAT for outbound internet access (needed for ACME, updates, etc.)
    networking.nat = lib.mkIf (cfg.natInterface != null) {
      enable = true;
      externalInterface = cfg.natInterface;
      internalInterfaces = [
        "ve-authentik"
        "ve-authentik-worker"
        "ve-authentik-redis"
      ];
    };

    # When using external PostgreSQL, create the database and user on the host
    services.postgresql = lib.mkIf (cfg.db.location == "external") {
      ensureDatabases = [ cfg.db.name ];
      ensureUsers = [
        {
          name = cfg.db.user;
          ensureDBs."${cfg.db.name}".grant = "ALL";
        }
      ];
    };

    # sops secrets on the host
    sops.secrets."authentik-secret-key".mode = "0444";
    sops.secrets."authentik-bootstrap-password".mode = "0444";
    sops.secrets."authentik-db-password".mode = "0444";

    # Journal directory for all three containers
    systemd.tmpfiles.rules = [
      "d /var/lib/nixos-containers/authentik/var/log/journal 0755 root systemd-journal -"
      "d /var/lib/nixos-containers/authentik-worker/var/log/journal 0755 root systemd-journal -"
      "d /var/lib/nixos-containers/authentik-redis/var/log/journal 0755 root systemd-journal -"
    ];

    # === AUTHENTIK SERVER CONTAINER ===
    containers.authentik = {
      autoStart = true;
      extraFlags = [ "--link-journal=guest" ];
      privateNetwork = true;
      hostAddress = cfg.hostAddress;
      localAddress = cfg.localAddress;

      bindMounts = {
        "/run/secrets/authentik-secret-key" = {
          hostPath = cfg.secretKeyFile;
          isReadOnly = true;
        };
        "/run/secrets/authentik-bootstrap-password" = {
          hostPath = cfg.bootstrapPasswordFile;
          isReadOnly = true;
        };
        "/run/secrets/authentik-db-password" = {
          hostPath = cfg.db.passwordFile;
          isReadOnly = true;
        };
        "/var/lib/authentik" = {
          hostPath = "/mnt/POOL/authentik";
          isReadOnly = false;
        };
        "/var/lib/authentik/media" = {
          hostPath = "/mnt/POOL/authentik/media";
          isReadOnly = false;
        };
        "/var/lib/authentik/custom-templates" = {
          hostPath = "/mnt/POOL/authentik/custom-templates";
          isReadOnly = false;
        };
        "/etc/authentik/config.yml" = {
          hostPath = "/var/lib/authentik/etc-authentik-config.yml";
          isReadOnly = true;
        };
      };

      config = { ... }: {
        users.users.authentik = {
          uid = lib.mkForce ids.uids.authentik;
          group = "authentik";
          isSystemUser = true;
        };
        users.groups.authentik.gid = lib.mkForce ids.gids.authentik;

        # No NixOS module exists for Authentik — configure via systemd service with env vars.
        # Authentik reads config from default.yml + /etc/authentik/config.yml (overrides).
        # We generate a config.yml that references secrets via file:// URIs.
        systemd.services.authentik-server = {
          description = "Authentik Server";
          wantedBy = [ "multi-user.target" ];
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          environment = {
            AUTHENTIK_POSTGRESQL__HOST = cfg.db.host;
            AUTHENTIK_POSTGRESQL__PORT = toString cfg.db.port;
            AUTHENTIK_POSTGRESQL__NAME = cfg.db.name;
            AUTHENTIK_POSTGRESQL__USER = cfg.db.user;
            AUTHENTIK_REDIS__HOST = cfg.redis.host;
            AUTHENTIK_REDIS__PORT = toString cfg.redis.port;
          };
          serviceConfig = {
            Type = "notify";
            User = "authentik";
            Group = "authentik";
            WorkingDirectory = "/var/lib/authentik";
            ExecStart = "${pkgs.authentik}/bin/ak server";
            Restart = "on-failure";
            RestartSec = "5s";
          };
          preStart = ''
            mkdir -p /var/lib/authentik/etc-authentik
            cat > /var/lib/authentik/etc-authentik/config.yml << 'EOF'
            secret_key: "file:///run/secrets/authentik-secret-key"
            postgresql:
              password: "file:///run/secrets/authentik-db-password"
            bootstrap:
              admin_password: "file:///run/secrets/authentik-bootstrap-password"
            EOF
          '';
        };

        networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
        networking.defaultGateway = cfg.hostAddress;

        networking.firewall.allowedTCPPorts = [ cfg.port ];

        system.stateVersion = "26.05";
      };
    };

    # === AUTHENTIK WORKER CONTAINER ===
    containers.authentik-worker = {
      autoStart = true;
      extraFlags = [ "--link-journal=guest" ];
      privateNetwork = true;
      hostAddress = cfg.workerHostAddress;
      localAddress = cfg.workerLocalAddress;

      bindMounts = {
        "/run/secrets/authentik-secret-key" = {
          hostPath = cfg.secretKeyFile;
          isReadOnly = true;
        };
        "/run/secrets/authentik-db-password" = {
          hostPath = cfg.db.passwordFile;
          isReadOnly = true;
        };
        "/var/lib/authentik" = {
          hostPath = "/mnt/POOL/authentik";
          isReadOnly = false;
        };
        "/var/lib/authentik/media" = {
          hostPath = "/mnt/POOL/authentik/media";
          isReadOnly = false;
        };
        "/var/lib/authentik/certs" = {
          hostPath = "/mnt/POOL/authentik/certs";
          isReadOnly = false;
        };
      };

      config = { ... }: {
        users.users.authentik = {
          uid = lib.mkForce ids.uids.authentik;
          group = "authentik";
          isSystemUser = true;
        };
        users.groups.authentik.gid = lib.mkForce ids.gids.authentik;

        # The worker runs the same authentik package but with worker-only processes.
        systemd.services.authentik-worker = {
          description = "Authentik Worker";
          wantedBy = [ "multi-user.target" ];
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          environment = {
            AUTHENTIK_POSTGRESQL__HOST = cfg.db.host;
            AUTHENTIK_POSTGRESQL__PORT = toString cfg.db.port;
            AUTHENTIK_POSTGRESQL__NAME = cfg.db.name;
            AUTHENTIK_POSTGRESQL__USER = cfg.db.user;
            AUTHENTIK_REDIS__HOST = cfg.redis.host;
            AUTHENTIK_REDIS__PORT = toString cfg.redis.port;
          };
          serviceConfig = {
            Type = "notify";
            User = "authentik";
            Group = "authentik";
            WorkingDirectory = "/var/lib/authentik";
            ExecStart = "${pkgs.authentik}/bin/ak worker";
            Restart = "on-failure";
            RestartSec = "5s";
          };
          preStart = ''
            mkdir -p /var/lib/authentik/etc-authentik
            cat > /var/lib/authentik/etc-authentik/config.yml << 'EOF'
            secret_key: "file:///run/secrets/authentik-secret-key"
            postgresql:
              password: "file:///run/secrets/authentik-db-password"
            EOF
          '';
        };

        # Beat scheduler for periodic tasks
        systemd.services.authentik-beat = {
          description = "Authentik Beat Scheduler";
          wantedBy = [ "multi-user.target" ];
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          environment = {
            AUTHENTIK_POSTGRESQL__HOST = cfg.db.host;
            AUTHENTIK_POSTGRESQL__PORT = toString cfg.db.port;
            AUTHENTIK_POSTGRESQL__NAME = cfg.db.name;
            AUTHENTIK_POSTGRESQL__USER = cfg.db.user;
            AUTHENTIK_REDIS__HOST = cfg.redis.host;
            AUTHENTIK_REDIS__PORT = toString cfg.redis.port;
          };
          serviceConfig = {
            Type = "notify";
            User = "authentik";
            Group = "authentik";
            WorkingDirectory = "/var/lib/authentik";
            ExecStart = "${pkgs.authentik}/bin/ak beat";
            Restart = "on-failure";
            RestartSec = "5s";
          };
          preStart = ''
            mkdir -p /var/lib/authentik/etc-authentik
            cat > /var/lib/authentik/etc-authentik/config.yml << 'EOF'
            secret_key: "file:///run/secrets/authentik-secret-key"
            postgresql:
              password: "file:///run/secrets/authentik-db-password"
            EOF
          '';
        };

        networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
        networking.defaultGateway = cfg.workerHostAddress;

        networking.firewall.allowedTCPPorts = [ ];

        system.stateVersion = "26.05";
      };
    };

    # === AUTHENTIK REDIS CONTAINER ===
    containers.authentik-redis = lib.mkIf (cfg.redis.location == "internal") {
      autoStart = true;
      extraFlags = [ "--link-journal=guest" ];
      privateNetwork = true;
      hostAddress = cfg.redisHostAddress;
      localAddress = cfg.redisLocalAddress;

      bindMounts = {
        "/var/lib/redis" = {
          hostPath = "/mnt/POOL/authentik-redis";
          isReadOnly = false;
        };
      };

      config = { ... }: {
        services.redis = {
          enable = true;
          bind = cfg.redisLocalAddress;
          port = cfg.redis.port;
        };

        networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
        networking.defaultGateway = cfg.redisHostAddress;

        networking.firewall.allowedTCPPorts = [ cfg.redis.port ];

        system.stateVersion = "26.05";
      };
    };
  };
}
```

- [ ] **Step 2: Import the module**

Add the import to `modules/nixos/default.nix` in the containers section (alphabetically with other container imports):

```nix
imports = [
  ../os
  ./containers/authentik.nix          # <-- ADD THIS LINE
  ./containers/home-assistant.nix
  # ... rest unchanged ...
];
```

- [ ] **Step 3: Verify evaluation**

Run: `nix flake show`
Expected: No errors, authentik module evaluated successfully

- [ ] **Step 4: Commit**

```bash
git add modules/nixos/containers/authentik.nix modules/nixos/default.nix
git commit -m "nixcfg(containers): add authentik SSO container module"
```

______________________________________________________________________

### Task 3: Register Authentik in homelab.nix and Enable on NAS

**Files:**

- Modify: `homelab.nix`

- Modify: `systems/nas/configuration.nix`

- [ ] **Step 1: Add Authentik to homelab.nix**

Add an `authentik` host entry in `homelab.nix` (after the existing `monitoring` entry, alphabetically):

```nix
authentik = {
  ip = "10.200.0.16";
  services.authentik = {
    port = 9000;
    subdomain = "auth";
    displayName = "Authentik";
    description = "Identity Provider";
    category = "Infrastructure";
    icon = "si:authentik";
  };
};
```

- [ ] **Step 2: Set nix-serve as unprotected**

In `homelab.nix`, add `protected = false` to the `nix-serve` service under `nas.services`:

```nix
nix-serve = {
  port = 5000;
  subdomain = "cache";
  domain = "toyvo.dev";
  protected = false;
  displayName = "Nix Cache";
  description = "Binary Cache";
  category = "Nas";
  icon = "sh-nixos";
};
```

- [ ] **Step 3: Enable the container on NAS**

In `systems/nas/configuration.nix`, add the authentik container configuration inside the `nixcfg.containers` block (after the existing entries):

```nix
authentik = {
  enable = true;
  natInterface = "eno1";
  db.passwordFile = config.sops.secrets."authentik-db-password".path;
  secretKeyFile = config.sops.secrets."authentik-secret-key".path;
  bootstrapPasswordFile = config.sops.secrets."authentik-bootstrap-password".path;
};
```

- [ ] **Step 4: Add sops secrets declarations on NAS**

In `systems/nas/configuration.nix`, add the sops secret declarations (near the other authentik-related sops entries):

```nix
sops.secrets."authentik-secret-key".mode = "0444";
sops.secrets."authentik-bootstrap-password".mode = "0444";
sops.secrets."authentik-db-password".mode = "0444";
```

Note: The module already declares these, but NAS config also needs them for the host-side sops-nix integration.

- [ ] **Step 5: Add ACL rules for authentik state directories**

In `systems/nas/configuration.nix`, add entries to `systemd.tmpfiles.generateRules`:

```nix
"/mnt/POOL/authentik" = with config.ids.uids; [ authentik toyvo ];
"/mnt/POOL/authentik-redis" = with config.ids.uids; [ authentik toyvo ];
```

- [ ] **Step 6: Verify evaluation**

Run: `nix flake show`
Expected: No errors

- [ ] **Step 7: Commit**

```bash
git add homelab.nix systems/nas/configuration.nix
git commit -m "nixcfg(nas): enable authentik container and register in homelab"
```

______________________________________________________________________

### Task 4: Extend virtual-hosts.nix with Protected Flag Support

**Files:**

- Modify: `systems/router/virtual-hosts.nix`

- [ ] **Step 1: Add protected field to the service destructure pattern**

In `systems/router/virtual-hosts.nix`, modify the service destructure to include `protected`:

```nix
{
  port,
  subdomain ? service,
  domain ? "diekvoss.net",
  selfSigned ? false,
  public ? domain != "diekvoss.net",
  protected ? true,
  ...
}:
```

- [ ] **Step 2: Add forward_auth block generation**

Inside the `value` attrset, add a `forwardAuthBlock` variable and prepend it to `extraConfig` when `protected` is true:

The `extraConfig` should become:

```nix
extraConfig =
  let
    forwardAuthBlock = lib.optionalString (protected && !selfSigned) ''
      forward_auth http://${homelab.router.ip}:9000 {
        uri /outpost.goauthentik.io/auth/caddy
        copy_headers X-Authentik-Username X-Authentik-Groups X-Authentik-Jwt X-Authentik-Email X-Authentik-Name X-Authentik-Uid X-Authentik-Session-Issuer
      }
    '';
  in
  forwardAuthBlock + (
    if selfSigned then
      ''
        header Strict-Transport-Security "max-age=15552000; includeSubDomains; preload"
        header_down -Server
        reverse_proxy https://${ip}:${toString port} {
          transport http {
            tls_insecure_skip_verify
          }
        }
      ''
    else
      ''
        header Strict-Transport-Security "max-age=15552000; includeSubDomains; preload"
        header_down -Server
        reverse_proxy http://${ip}:${toString port}
      ''
  );
```

Note: `protected && !selfSigned` ensures self-signed services (like Cockpit) don't get forward_auth blocks since they use HTTPS transport which complicates the forward_auth flow.

- [ ] **Step 3: Verify evaluation**

Run: `nix flake show`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add systems/router/virtual-hosts.nix
git commit -m "nixcfg(router): add protected flag support to caddy virtual hosts"
```

______________________________________________________________________

### Task 5: Add Proxy Outpost to Router

**Files:**

- Modify: `systems/router/configuration.nix`

- Modify: `.sops.yaml` (no changes needed — secrets.yaml already includes router key)

- [ ] **Step 1: Add the proxy outpost systemd service**

In `systems/router/configuration.nix`, add the proxy outpost service configuration. Find a good spot (near the end, before the closing `}`):

```nix
# Authentik proxy outpost for forward-auth
# The proxy outpost is a Go binary (pkgs.authentik-outposts.proxy, binary name: proxy)
# that authenticates requests for Caddy via forward_auth.
systemd.services.authentik-proxy-outpost = {
  description = "Authentik Proxy Outpost";
  wantedBy = [ "multi-user.target" ];
  after = [ "network-online.target" ];
  wants = [ "network-online.target" ];
  environment = {
    AUTHENTIK_HOST = "http://10.200.0.16:9000";
    AUTHENTIK_TOKEN_FILE = config.sops.secrets."authentik-outpost-token".path;
  };
  serviceConfig = {
    ExecStart = "${pkgs.authentik-outposts.proxy}/bin/proxy";
    Restart = "on-failure";
    RestartSec = "30";
  };
};

sops.secrets."authentik-outpost-token" = { };
```

Note: The proxy outpost is at `pkgs.authentik-outposts.proxy` (binary name: `proxy`). It reads `AUTHENTIK_HOST` (server URL) and `AUTHENTIK_TOKEN_FILE` (path to token file) or `AUTHENTIK_TOKEN` (direct value). The `RestartSec = "30"` allows the service to tolerate connection failures during the bootstrap phase.

- [ ] **Step 2: Verify evaluation**

Run: `nix flake show`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add systems/router/configuration.nix
git commit -m "nixcfg(router): add authentik proxy outpost service"
```

______________________________________________________________________

### Task 6: Generate Secrets and Deploy

**Files:**

- Modify: `secrets.yaml` (encrypted)

- [ ] **Step 1: Generate secrets**

Run these commands to generate the required secrets:

```bash
# Generate Authentik secret key
openssl rand -base64 60

# Generate bootstrap admin password
openssl rand -base64 32

# Generate database password
openssl rand -base64 32
```

- [ ] **Step 2: Add secrets to sops**

```bash
sops secrets.yaml
```

Add these entries under the "api keys" section:

```yaml
authentik-secret-key: "<generated-base64-key>"
authentik-bootstrap-password: "<generated-base64-password>"
authentik-db-password: "<generated-base64-password>"
authentik-outpost-token: "PLACEHOLDER"
```

The outpost token is set to `PLACEHOLDER` initially — it will be updated after bootstrapping Authentik in the UI.

- [ ] **Step 3: Commit encrypted secrets**

```bash
git add secrets.yaml
git commit -m "secrets: add authentik secrets"
```

- [ ] **Step 4: Deploy NAS config**

```bash
nixos-rebuild switch --flake .#nas
```

Expected: Authentik containers start, PostgreSQL user/db created, Redis container running.

- [ ] **Step 5: Verify Authentik is accessible**

```bash
curl -s http://10.200.0.16:9000/if/health -o /dev/null -w "%{http_code}"
```

Expected: `200`

- [ ] **Step 6: Deploy Router config**

```bash
nixos-rebuild switch --flake .#router
```

Expected: Proxy outpost service starts (will restart every 30s until token is set — this is expected during bootstrap).

______________________________________________________________________

### Task 7: Bootstrap Authentik and Finalize

**Files:** None (manual UI steps)

- [ ] **Step 1: Access Authentik UI**

Open `https://auth.diekvoss.net` in a browser.

- [ ] **Step 2: Log in with bootstrap credentials**

Username: `akadmin`
Password: value of `authentik-bootstrap-password` from sops secrets

- [ ] **Step 3: Create an outpost token**

In the Authentik UI:

1. Go to Admin Interface → System → Outposts
1. Create a new outpost (type: Proxy)
1. Generate a token for the outpost
1. Copy the token value

- [ ] **Step 4: Update the outpost token in sops**

```bash
sops secrets.yaml
```

Replace `authentik-outpost-token: "PLACEHOLDER"` with the actual token value.

- [ ] **Step 5: Re-deploy router with real token**

```bash
nixos-rebuild switch --flake .#router
```

Expected: Proxy outpost connects successfully to Authentik server.

- [ ] **Step 6: Verify forward-auth is working**

1. Access any protected service (e.g., `https://immich.diekvoss.net`)
1. Should be redirected to `https://auth.diekvoss.net/if/flow/default-provider-login/`
1. Log in with an Authentik user
1. Should be redirected back to the original service

- [ ] **Step 7: Verify nix cache is NOT protected**

```bash
curl -sI https://cache.toyvo.dev
```

Expected: `200 OK` without redirect to Authentik login.

- [ ] **Step 8: Create local user accounts**

In the Authentik UI, create user accounts for anyone who needs access to the homelab services.

______________________________________________________________________

### Task 8: Self-Hosted Icon for Authentik (Optional Polish)

**Files:**

- Modify: `systems/nas/homepage.nix` (if custom icons are managed there)

- [ ] **Step 1: Verify icon displays correctly**

The `icon = "si:authentik"` references Simple Icons. Check if the Homepage dashboard renders it correctly. If not, the icon may need to be added to the custom icon set or the icon reference updated.

- [ ] **Step 2: Commit if changes needed**

```bash
git add systems/nas/homepage.nix
git commit -m "nixcfg(nas): add authentik icon to homepage dashboard"
```

______________________________________________________________________

## Deployment Notes

**Order matters:** Deploy NAS first (containers must be running), then Router (proxy outpost needs Authentik to connect to).

**Bootstrap chicken-and-egg:** The proxy outpost will fail to start until you create the outpost token in the Authentik UI. The `RestartSec=30` ensures it keeps trying without crashing.

**All services protected by default:** After deploying the router config, every service except the nix cache will require Authentik authentication. Make sure you have the bootstrap credentials ready before deploying.

**Self-signed services excluded from forward-auth:** Services with `selfSigned = true` (like Cockpit) don't get forward_auth blocks because Caddy's HTTPS transport mode is incompatible with forward_auth. These services will need separate auth configuration.
