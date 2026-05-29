{
  lib,
  pkgs,
  config,
  inputs,
  system,
  homelab,
  stablePkgs,
  unstablePkgs,
  ...
}:
let
  inherit (config.networking) hostName;
in
{
  imports = [
    inputs.nixcfg.modules.nixos.default
    ./kea.nix
    ./virtual-hosts.nix
    inputs.catppuccin.nixosModules.catppuccin
    inputs.dioxus_monorepo.nixosModules.discord_bot
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.default
    inputs.nh.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nixos-unstable.nixosModules.notDetected
    inputs.nur.modules.nixos.default
    inputs.sops-nix.nixosModules.sops
  ];
  home-manager = {
    extraSpecialArgs = {
      inherit
        inputs
        system
        homelab
        stablePkgs
        unstablePkgs
        ;
    };
    sharedModules = [ ./home.nix ];
  };
  hardware.cpu.intel.updateMicrocode = true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  networking = {
    hostName = "router";
    networkmanager.enable = lib.mkForce false;
    domain = "diekvoss.net";
    useNetworkd = true;
    useDHCP = false;
    nameservers = [ "127.0.0.1" ];
    # Local /etc/hosts backup for when DNS is down or during bootstrap
    hosts = {
      "127.0.0.1" = [ "localhost" ];
      "::1" = [ "localhost" ];
    }
    // (lib.pipe homelab [
      (lib.filterAttrs (
        _: host: lib.hasPrefix "10.1.0." (host.ip or "") || lib.hasPrefix "10.200." (host.ip or "")
      ))
      (lib.mapAttrsToList (
        name: host:
        lib.nameValuePair host.ip [
          "${name}.diekvoss.net"
          name
        ]
      ))
      lib.listToAttrs
    ]);
    nat = {
      enable = true;
      externalInterface = "enp2s0";
      internalInterfaces = [
        "br0"
        "br0.20"
        "br0.30"
        "wg0"
      ];
    };
    wireguard.interfaces.wg0 = {
      ips = [ "10.100.0.1/24" ];
      listenPort = 51820;
      privateKeyFile = config.sops.secrets.wireguard-router-private-key.path;
      peers = [
        {
          publicKey = "G78etq+AQlSTd1fOXTpxt+mSB5A+kozeUFfagXz49Ws=";
          allowedIPs = [ "10.100.0.2/32" ];
          persistentKeepalive = 25;
        }
        {
          publicKey = "94cgu2UpmNSwFldrufSwCuUW65dTB0GikxG/HF+JMg4=";
          allowedIPs = [ "10.100.0.3/32" ];
          persistentKeepalive = 25;
        }
      ];
    };
    firewall = {
      enable = true;
      # Port 53 is for DNS, 22 is for SSH, 67/68 is for DHCP, 80 is for HTTP, 443 is for HTTPS
      interfaces.enp2s0 = {
        allowedTCPPorts = [
          80
          443
        ];
        allowedUDPPorts = [
          443
          51820
        ];
      };
      interfaces.br0 = {
        allowedTCPPorts = [
          53
          22
          80
          443
        ];
        allowedUDPPorts = [
          53
          67
          68
          443
        ];
      };
      interfaces."br0.20" = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [
          53
          67
          68
        ];
      };
      interfaces."br0.30" = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [
          53
          67
          68
        ];
      };
    };
    nftables.tables.vlan-isolation = {
      family = "inet";
      content = ''
        chain forward {
          type filter hook forward priority filter; policy accept;

          # Allow established/related traffic (enables CDWifi->IoT return traffic)
          ct state established,related accept

          # Allow CDWifi (br0) to initiate connections to IoT (VLAN 30)
          iifname "br0" oifname "br0.30" accept

          # Guest (VLAN 20): drop all forwarding to private subnets
          iifname "br0.20" ip daddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } drop
          iifname "br0.20" ip6 daddr { fc00::/7 } drop

          # IoT (VLAN 30): drop all forwarding to private subnets
          iifname "br0.30" ip daddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } drop
          iifname "br0.30" ip6 daddr { fc00::/7 } drop
        }
      '';
    };
  };
  boot = {
    kernel.sysctl = {
      # Prevent IP spoofing
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.conf.default.rp_filter" = 1;
      # Ignore ICMP redirects
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      # Don't send ICMP redirects
      "net.ipv4.conf.all.send_redirects" = 0;
      # Log martian packets
      "net.ipv4.conf.all.log_martians" = 1;
      # Ignore broadcast pings
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      # SYN flood protection
      "net.ipv4.tcp_syncookies" = 1;
    };
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usb_storage"
      "usbhid"
      "sd_mod"
      "sdhci_pci"
    ];
    kernelModules = [ "kvm-intel" ];
  };
  virtualisation.containers.enable = true;
  profiles.defaults.enable = true;
  userPresets.toyvo.enable = true;
  fileSystemPresets.boot.enable = true;
  fileSystemPresets.btrfs.enable = true;
  systemd = {
    network = {
      enable = true;
      networks.wan0 = {
        matchConfig.Name = "enp2s0";
        networkConfig.DHCP = "ipv4";
        dhcpV4Config = {
          UseDNS = false;
        };
        linkConfig.RequiredForOnline = "routable";
      };
      networks.lan0 = {
        matchConfig.Name = "enp3s0 enp4s0 enp5s0";
        networkConfig.Bridge = "br0";
      };
      networks.br0 = {
        matchConfig.Name = "br0";
        address = [
          "10.1.0.1/24"
          "fdcd:2022:1118::1/64"
        ];
        routes = [
          {
            Destination = "10.200.0.0/16";
            Gateway = "10.1.0.3";
          }
        ];
        networkConfig = {
          IPMasquerade = "ipv4";
          MulticastDNS = true;
          IPv6SendRA = true;
        };
        ipv6SendRAConfig = {
          EmitDNS = true;
          DNS = [ "fdcd:2022:1118::1" ];
        };
        ipv6Prefixes = [
          { Prefix = "fdcd:2022:1118::/64"; }
        ];
        vlan = [
          "br0.20"
          "br0.30"
        ];
      };
      networks."br0.20" = {
        matchConfig.Name = "br0.20";
        address = [
          "10.1.20.1/24"
          "fdcd:2022:1118:20::1/64"
        ];
        networkConfig = {
          IPMasquerade = "ipv4";
          IPv6SendRA = true;
        };
        ipv6SendRAConfig = {
          EmitDNS = true;
          DNS = [ "fdcd:2022:1118::1" ];
        };
        ipv6Prefixes = [
          { Prefix = "fdcd:2022:1118:20::/64"; }
        ];
      };
      networks."br0.30" = {
        matchConfig.Name = "br0.30";
        address = [
          "10.1.30.1/24"
          "fdcd:2022:1118:30::1/64"
        ];
        networkConfig = {
          IPMasquerade = "ipv4";
          IPv6SendRA = true;
        };
        ipv6SendRAConfig = {
          EmitDNS = true;
          DNS = [ "fdcd:2022:1118::1" ];
        };
        ipv6Prefixes = [
          { Prefix = "fdcd:2022:1118:30::/64"; }
        ];
      };
      netdevs.br0.netdevConfig = {
        Name = "br0";
        Kind = "bridge";
        MACAddress = "none";
      };
      netdevs."br0.20" = {
        netdevConfig = {
          Name = "br0.20";
          Kind = "vlan";
        };
        vlanConfig.Id = 20;
      };
      netdevs."br0.30" = {
        netdevConfig = {
          Name = "br0.30";
          Kind = "vlan";
        };
        vlanConfig.Id = 30;
      };
      links.br0 = {
        matchConfig.OriginalName = "br0";
        linkConfig.MACAddressPolicy = "none";
      };
    };
  };
  services = {
    fail2ban = {
      enable = true;
      maxretry = 5;
      bantime = "1h";
    };
    openssh = {
      enable = true;
      openFirewall = false;
      settings.PasswordAuthentication = false;
    };
    resolved = {
      enable = true;
    };
    technitium-dns-server = {
      enable = true;
      openFirewall = false;
    };
    # Alloy scrapes local exporters and pushes to Prometheus remote-write
    monitoring = {
      enable = true;
      internet.enable = true;
      alloyExtraConfig = ''
        prometheus.scrape "technitium" {
          targets = [{"__address__" = "localhost:9187"}]
          forward_to = [prometheus.relabel.instance.receiver]
          scrape_interval = "30s"
        }
      '';
      textfileDirectory = "/var/lib/alloy/textfiles";
    };
    caddy = {
      enable = true;
      globalConfig = ''
        servers {
          metrics
        }
      '';
    };
    cloudflare-dyndns = {
      enable = true;
      domains = [
        "toyvo.dev"
        "cache.toyvo.dev"
      ];
      proxied = false;
      apiTokenFile = config.sops.secrets.cloudflare_w_dns_r_zone_token.path;
    };
  };
  systemd.services.technitium-dns-server.serviceConfig.LogsDirectory = "technitium";
  # Prometheus exporter for Technitium stats + query-log threat scanning
  systemd.services.technitium-exporter = {
    description = "Technitium DNS Prometheus Exporter";
    after = [
      "network.target"
      "technitium-dns-server.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      Environment = [
        "TECHNITIUM_URL=http://127.0.0.1:${toString homelab.${hostName}.services.technitium.port}"
        "EXPORTER_PORT=9187"
        "EXPORTER_ADDR=127.0.0.1"
        "TECHNITIUM_TOKEN_FILE=${config.sops.secrets.technitium_api_key.path}"
      ];
      ExecStart = lib.getExe inputs.nixcfg.packages.${system}.technitium-exporter;
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
  # Periodic network device inventory (ARP + Kea + Technitium clients)
  systemd.services.network-inventory = {
    description = "Collect network device inventory";
    serviceConfig = {
      Type = "oneshot";
      DynamicUser = true;
      SupplementaryGroups = [ "systemd-journal" ];
      Environment = [
        "INVENTORY_OUTPUT=/var/lib/alloy/textfiles/network_inventory.prom"
        "KEA_LEASES=/var/lib/kea/dhcp4.leases"
        "TECHNITIUM_URL=http://127.0.0.1:${toString homelab.${hostName}.services.technitium.port}"
        "TECHNITIUM_TOKEN_FILE=${config.sops.secrets.technitium_api_key.path}"
      ];
      ExecStartPre = "+${pkgs.coreutils}/bin/install -d -m 0755 -o root -g root /var/lib/alloy/textfiles";
      ExecStart = lib.getExe inputs.nixcfg.packages.${system}.network-inventory;
    };
  };
  systemd.timers.network-inventory = {
    description = "Periodic network device inventory";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "5min";
      Persistent = true;
    };
  };
  # Configure Technitium DNS apps via API after service is online
  systemd.services.configure-technitium = {
    description = "Configure Technitium DNS Server via API";
    after = [
      "network.target"
      "technitium-dns-server.service"
    ];
    requires = [ "technitium-dns-server.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      DynamicUser = true;
      Environment = [
        "TECHNITIUM_URL=http://127.0.0.1:${toString homelab.${hostName}.services.technitium.port}"
        "TECHNITIUM_TOKEN_FILE=${config.sops.secrets.technitium_api_key.path}"
      ];
      ExecStart = lib.getExe (pkgs.writeScriptBin "configure-technitium" ''
        #!${pkgs.python3}/bin/python3
        import json
        import os
        import sys
        import time
        import urllib.request
        import urllib.error

        URL = os.environ.get("TECHNITIUM_URL", "http://127.0.0.1:5380")
        TOKEN_FILE = os.environ.get("TECHNITIUM_TOKEN_FILE", "")
        TOKEN = ""
        if TOKEN_FILE:
            try:
                with open(TOKEN_FILE) as f:
                    TOKEN = f.read().strip()
            except Exception as e:
                print(f"Warning: could not read token file: {e}", file=sys.stderr)

        def api_request(endpoint, data=None, method="GET"):
            url = f"{URL}{endpoint}"
            headers = {}
            if TOKEN:
                headers["Authorization"] = f"Bearer {TOKEN}"
            if data is not None:
                headers["Content-Type"] = "application/json"
                body = json.dumps(data).encode()
            else:
                body = None
            req = urllib.request.Request(url, data=body, headers=headers, method=method)
            try:
                with urllib.request.urlopen(req, timeout=30) as resp:
                    return json.loads(resp.read().decode())
            except urllib.error.HTTPError as e:
                print(f"HTTP {e.code} from {endpoint}: {e.read().decode()}", file=sys.stderr)
                return None
            except Exception as e:
                print(f"Error calling {endpoint}: {e}", file=sys.stderr)
                return None

        def wait_for_api(timeout=120):
            print("Waiting for Technitium API...", file=sys.stderr)
            for i in range(timeout):
                try:
                    req = urllib.request.Request(f"{URL}/api/stats", method="GET")
                    if TOKEN:
                        req.add_header("Authorization", f"Bearer {TOKEN}")
                    with urllib.request.urlopen(req, timeout=5) as resp:
                        if resp.status == 200:
                            print("Technitium API is ready.", file=sys.stderr)
                            return True
                except Exception:
                    pass
                time.sleep(1)
            print("Timeout waiting for Technitium API", file=sys.stderr)
            return False

        def configure_app(app_name, config):
            print(f"Configuring {app_name}...", file=sys.stderr)
            # Try common API endpoint patterns for app configuration
            endpoints = [
                f"/api/apps/config?appName={app_name.replace(' ', '%20')}",
                f"/api/apps/{app_name.replace(' ', '%20')}/config",
                "/api/apps/config",
            ]
            for endpoint in endpoints:
                result = api_request(endpoint, {"appName": app_name, "config": config}, method="POST")
                if result is not None:
                    print(f"Successfully configured {app_name} via {endpoint}", file=sys.stderr)
                    return True
            print(f"Failed to configure {app_name} - check API docs and endpoint", file=sys.stderr)
            return False

        def main():
            if not wait_for_api():
                sys.exit(1)

            blocking_config = {
                "enableBlocking": True,
                "blockingAnswerTtl": 30,
                "blockListUrlUpdateIntervalHours": 24,
                "blockListUrlUpdateIntervalMinutes": 0,
                "localEndPointGroupMap": {
                    "127.0.0.1": "bypass",
                    "10.1.0.1:53": "bypass"
                },
                "networkGroupMap": {
                    "10.1.0.0/24": "everyone else",
                    "10.1.20.0/24": "everyone else",
                    "10.1.30.0/24": "everyone else",
                    "0.0.0.0/0": "everyone else",
                    "[::]/0": "everyone else"
                },
                "groups": [
                    {
                        "name": "everyone else",
                        "enableBlocking": True,
                        "allowTxtBlockingReport": True,
                        "blockAsNxDomain": True,
                        "blockingAddresses": ["0.0.0.0", "::"],
                        "allowed": [],
                        "blocked": [],
                        "allowListUrls": [],
                        "blockListUrls": [
                            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts",
                            "https://urlhaus.abuse.ch/downloads/hostfile/",
                            "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/tif.txt"
                        ],
                        "allowedRegex": [],
                        "blockedRegex": [],
                        "regexAllowListUrls": [],
                        "regexBlockListUrls": [],
                        "adblockListUrls": []
                    },
                    {
                        "name": "bypass",
                        "enableBlocking": False,
                        "allowTxtBlockingReport": True,
                        "blockAsNxDomain": True,
                        "blockingAddresses": ["0.0.0.0", "::"],
                        "allowed": [],
                        "blocked": [],
                        "allowListUrls": [],
                        "blockListUrls": [],
                        "allowedRegex": [],
                        "blockedRegex": [],
                        "regexAllowListUrls": [],
                        "regexBlockListUrls": [],
                        "adblockListUrls": []
                    }
                ]
            }

            forwarding_config = {
                "appPreference": 200,
                "enableForwarding": True,
                "proxyServers": [],
                "forwarders": [
                    {
                        "name": "quad9-doh",
                        "proxy": None,
                        "dnssecValidation": True,
                        "forwarderProtocol": "Https",
                        "forwarderAddresses": [
                            "https://dns.quad9.net/dns-query (9.9.9.9)"
                        ]
                    },
                    {
                        "name": "cloudflare-google",
                        "proxy": None,
                        "dnssecValidation": True,
                        "forwarderProtocol": "Tls",
                        "forwarderAddresses": [
                            "1.1.1.1",
                            "8.8.8.8"
                        ]
                    }
                ],
                "networkGroupMap": {
                    "0.0.0.0/0": "everyone",
                    "[::]/0": "everyone"
                },
                "groups": [
                    {
                        "name": "everyone",
                        "enableForwarding": True,
                        "forwardings": [
                            {
                                "forwarders": ["cloudflare-google"],
                                "domains": ["*"]
                            }
                        ],
                        "adguardUpstreams": []
                    }
                ]
            }

            # Discover available apps first
            print("Discovering installed apps...", file=sys.stderr)
            apps = api_request("/api/apps/list")
            if apps:
                print(f"Installed apps: {json.dumps(apps, indent=2)}", file=sys.stderr)
            else:
                print("Could not list apps; will try direct configuration anyway.", file=sys.stderr)

            configure_app("Advanced Blocking", blocking_config)
            configure_app("Advanced Forwarding", forwarding_config)

            print("Technitium configuration complete.", file=sys.stderr)

        if __name__ == "__main__":
            main()
      '');
    };
  };
  security.acme =
    let
      cloudflare = {
        email = "collin@diekvoss.com";
        dnsProvider = "cloudflare";
        credentialFiles = {
          "CF_DNS_API_TOKEN_FILE" = config.sops.secrets.cloudflare_w_dns_r_zone_token.path;
        };
      };
    in
    {
      acceptTerms = true;
      defaults.email = cloudflare.email;
      certs = {
        "diekvoss.net" = cloudflare // {
          extraDomainNames = [ "*.diekvoss.net" ];
        };
        "toyvo.dev" = cloudflare // {
          extraDomainNames = [ "*.toyvo.dev" ];
        };
      };
    };
  sops.secrets = {
    cloudflare_w_dns_r_zone_token = { };
    "wireguard-router-private-key" = { };
    technitium_api_key = { };
  };
}
