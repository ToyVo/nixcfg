# Authentik Forward-Auth Integration — Design Spec

## Goal

Add Authentik as a centralized forward-auth gate for all homelab services behind Caddy, with local user management. Services are protected by default; explicitly whitelist those that should remain open (currently only the Nix cache).

## Architecture

### Container Layout (NAS)

| Container | IP | Purpose |
|-----------|-----|---------|
| **authentik** | 10.200.0.16 | Server — web UI + API |
| **authentik-worker** | 10.200.0.18 | Worker — task execution, email, outpost communication |
| **authentik-redis** | 10.200.0.20 | Dedicated Redis instance |

**PostgreSQL:** Shared on host (existing PG16 on NAS). New `authentik` database + user created automatically.

### Forward-Auth Flow

```
Browser → Caddy (router, :443)
  → forward_auth → authentik-proxy-outpost (router, native systemd, :9000)
    → Authentik Server (NAS, 10.200.0.16:9000)
```

- `authentik-proxy-outpost` runs as a native systemd service on the router (single Go binary, minimal footprint)
- Caddy uses `forward_auth` directive pointing to the proxy outpost on `10.1.0.1:9000`
- Proxy outpost communicates back to Authentik server over the LAN
- On successful auth, Caddy receives `X-Authentik-*` headers and forwards them to the upstream service

### Caddy Integration

`virtual-hosts.nix` extended to check `service.protected or true`:

- When `true`: inject `forward_auth` block before the `reverse_proxy` directive
- When `false`: plain reverse proxy (current behavior)

The `forward_auth` block:

```
forward_auth http://10.1.0.1:9000 {
    uri /outpost.goauthentik.io/auth/caddy
    copy_headers X-Authentik-Username X-Authentik-Groups X-Authentik-Jwt X-Authentik-Email X-Authentik-Name X-Authentik-Uid
}
```

### homelab.nix Service Protection

Services in `homelab.nix` get an optional `protected` boolean field:

```nix
nas.services = {
  jellyfin = { port = 8096; };                          # protected = true (default)
  immich = { port = 2283; };                            # protected = true (default)
  cache = { port = 5000; protected = false; domain = "toyvo.dev"; };  # explicitly unprotected
};
```

## NixOS Module Structure

```
modules/nixos/
├── containers/
│   ├── authentik/
│   │   ├── default.nix        # Server + worker containers, options
│   │   └── redis.nix          # Redis container (when redis.location = "internal")
```

### Module Options

```nix
nixcfg.containers.authentik = {
  enable = lib.mkEnableOption "authentik SSO";

  db.location = lib.mkOption {
    type = lib.types.enum [ "internal" "external" ];
    default = "external";
    description = "Where PostgreSQL runs. 'external' uses host PostgreSQL, 'internal' provisions a dedicated container.";
  };

  redis.location = lib.mkOption {
    type = lib.types.enum [ "internal" "external" ];
    default = "internal";
    description = "Where Redis runs. 'internal' provisions a dedicated container, 'external' uses a host-level Redis.";
  };

  server.container.ip = "10.200.0.16";
  worker.container.ip = "10.200.0.18";
  redis.container.ip = "10.200.0.20";
};
```

When `db.location = "external"`:

- Creates PostgreSQL user `authentik` with a dedicated database on the host PG instance
- Password from sops-nix

When `db.location = "internal"`:

- Provisions a dedicated PostgreSQL container (future pattern for spreading this)

When `redis.location = "internal"`:

- Provisions the `authentik-redis` container

When `redis.location = "external"`:

- Expects a host-level Redis, configurable via `redis.externalUrl`

### Container Configuration

**authentik server container:**

- Binds to `10.200.0.16:9000` (server port) and `10.200.0.16:9001` (worker/gunicorn port)
- Environment: `AUTHENTIK_SECRET_KEY`, `AUTHENTIK_POSTGRESQL__*`, `AUTHENTIK_REDIS__*`
- State directory: `/mnt/POOL/nixos-containers/authentik-server`
- Pinned UID/GID from `config.ids`

**authentik-worker container:**

- Same environment variables as server
- Runs `ak worker` and `ak beat` processes
- State directory: `/mnt/POOL/nixos-containers/authentik-worker`
- Pinned UID/GID from `config.ids`

**authentik-redis container:**

- Standard Redis with persistence to state directory
- Listens on `10.200.0.20:6379`
- No auth required (isolated container network)

## Router: Proxy Outpost

Native systemd service on the router (not containerized):

```nix
systemd.services.authentik-proxy-outpost = {
  wantedBy = [ "multi-user.target" ];
  serviceConfig = {
    ExecStart = "${pkgs.authentik-proxy-outpost}/bin/proxy-outpost";
    RestartSec = "30";
  };
  environment = {
    AUTHENTIK_HOST = "http://10.200.0.16:9000";
    AUTHENTIK_TOKEN_FILE = config.sops.secrets.authentik-outpost-token.path;
  };
};
```

The outpost token is read from the sops secret at runtime. During bootstrap (before the token exists), the service restarts every 30s until the token is provisioned.

## Caddy Virtual Host Changes

`virtual-hosts.nix` modified to support the `protected` field:

```nix
# For each service in homelab.nix:
protected = service.protected or true;

# If protected, prepend forward_auth block:
forwardAuthBlock = lib.optionalString protected ''
  forward_auth http://10.1.0.1:9000 {
    uri /outpost.goauthentik.io/auth/caddy
    copy_headers X-Authentik-Username X-Authentik-Groups X-Authentik-Jwt X-Authentik-Email X-Authentik-Name X-Authentik-Uid
  }
'';
```

The Authentik server itself gets a vhost (`auth.diekvoss.net`) that is **not** forward-auth protected (bootstrap access).

## homelab.nix Registration

Add `nas` host entry for Authentik:

```nix
nas = {
  ip = "10.1.0.3";
  mac = "...";
  services = {
    authentik = {
      port = 9000;
      displayName = "Authentik";
      icon = "si:authentik";
      description = "Identity provider";
      category = "infrastructure";
    };
    # existing services...
    cache = { port = 5000; protected = false; domain = "toyvo.dev"; };
  };
};
```

## Secrets (sops-nix)

| Secret Name | Used By | How to Generate |
|-------------|---------|-----------------|
| `authentik-secret-key` | Server + Worker containers | `openssl rand -base64 60` |
| `authentik-bootstrap-password` | Server (initial admin) | `openssl rand -base64 32` |
| `authentik-db-password` | Server + Worker containers (external PG) | `openssl rand -base64 32` |
| `authentik-outpost-token` | Proxy outpost on router | Generate in Authentik UI after bootstrap |

**sops.yaml key assignments:**

- `authentik-secret-key`: NAS only
- `authentik-bootstrap-password`: NAS only
- `authentik-db-password`: NAS only
- `authentik-outpost-token`: Router only

The proxy outpost environment file is constructed in Nix from the token secret:

```nix
Environment = [
  "AUTHENTIK_HOST=http://10.200.0.16:9000"
  "AUTHENTIK_TOKEN=${config.sops.secrets.authentik-outpost-token.path}"
];
```

## Bootstrap Process

1. Deploy NAS config with Authentik containers + PG user/db creation
1. Deploy router config with proxy outpost service (configured with `RestartSec=30` to tolerate connection failures during bootstrap)
1. Access `auth.diekvoss.net` (not protected by forward-auth)
1. Log in with `akadmin` / bootstrap password
1. In Authentik UI: create outpost token, update sops secrets
1. Re-deploy router config with actual outpost token
1. Create local user accounts, set up flows/providers
1. Optionally remove `akadmin` account

## Service Protection Plan

Initially, all existing services are protected by default. The only explicit exception:

| Service | Protected | Reason |
|---------|-----------|--------|
| `cache.toyvo.dev` (Nix cache) | No | Binary cache must be accessible without auth |

All other services (immich, nextcloud, jellyfin, grafana, home-assistant, chat, hermes-agent, \*arr, etc.) are protected on first deploy. Users will need to authenticate via Authentik to access them.

## Firewall Changes

| Machine | Port | Protocol | Direction | Purpose |
|---------|------|----------|-----------|---------|
| NAS | 9000 | TCP | Inbound (LAN) | Authentik server UI/API |
| NAS | 9001 | TCP | Container internal | Authentik worker/gunicorn |
| NAS | 6379 | TCP | Container internal | Redis |
| Router | 9000 | TCP | Inbound (LAN) | Proxy outpost (forward_auth target) |

## Data Flow

### Authentication Request

```
Browser → Caddy (:443)
  → forward_auth http://10.1.0.1:9000/outpost.goauthentik.io/auth/caddy
    → Proxy Outpost (:9000)
      → Authentik Server (10.200.0.16:9000)
        → Check session/token
          → If valid: return headers with user info
          → If invalid: redirect to auth.diekvoss.net/login
```

### Container Communication

```
[authentik server] --Redis protocol--> [authentik-redis] (10.200.0.20:6379)
[authentik server] --SQL--> [host PostgreSQL] (localhost:5432)
[authentik worker] --Redis protocol--> [authentik-redis] (10.200.0.20:6379)
[authentik worker] --SQL--> [host PostgreSQL] (localhost:5432)
[proxy outpost] --HTTP API--> [authentik server] (10.200.0.16:9000)
```

## Incremental Build Order

### Phase 1 — NAS: PostgreSQL prep + Redis container

1. Add `db.location` and `redis.location` options to container module pattern
1. Create PostgreSQL user/db for Authentik on host PG
1. Create `authentik-redis` container module
1. Verify Redis container connectivity

### Phase 2 — NAS: Authentik server + worker containers

5. Create `authentik/default.nix` with server + worker containers
1. Wire up environment variables from sops secrets
1. Register Authentik in `homelab.nix`
1. Deploy and verify bootstrap access at `auth.diekvoss.net`

### Phase 3 — Router: Proxy outpost + Caddy integration

9. Add `authentik-proxy-outpost` systemd service on router
1. Extend `virtual-hosts.nix` with `protected` field support
1. Set `protected = false` on cache service
1. Deploy and verify forward-auth flow

### Phase 4 — Bootstrap + Polish

13. Bootstrap Authentik (admin login, outpost token creation)
01. Update sops secrets with actual outpost token
01. Re-deploy router with working outpost
01. Create initial local users
01. Verify all services behind forward-auth

## Notes

- **Authentik version:** 2025.12.4 (from nixpkgs unstable)
- **No NixOS module exists** for Authentik — we configure it via container environment variables
- **Bootstrap password** is one-time use; after initial setup, the `akadmin` account can be deleted
- **Outpost token** must be generated in the Authentik UI after bootstrap — this is a chicken-and-egg problem solved by deploying router config twice (once with placeholder, once with real token)
- **Protected default** means existing services will require Authentik auth immediately after deploy — plan to have bootstrap credentials ready before deploying
- **Future pattern:** The `db.location` / `redis.location` options establish a reusable pattern for other services that may want internal vs external dependencies
