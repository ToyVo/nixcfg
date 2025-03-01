{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./kea.nix
    ./virtual-hosts.nix
  ];

  hardware.cpu.intel.updateMicrocode = true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  networking = {
    hostName = "router";
    networkmanager.enable = lib.mkForce false;
    domain = "diekvoss.net";
    useNetworkd = true;
    useDHCP = false;
    nameservers = [ "127.0.1.53" ];
    nat = {
      enable = true;
      externalInterface = "enp2s0";
      internalInterfaces = [
        "br0"
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
    };
  };
  boot = {
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
        networkConfig = {
          Address = "10.1.0.1/24";
          IPMasquerade = "ipv4";
          MulticastDNS = true;
        };
      };
      netdevs.br0.netdevConfig = {
        Name = "br0";
        Kind = "bridge";
        MACAddress = "none";
      };
      links.br0 = {
        matchConfig.OriginalName = "br0";
        linkConfig.MACAddressPolicy = "none";
      };
    };
  };
  services = {
    openssh = {
      enable = true;
      openFirewall = false;
      settings.PasswordAuthentication = false;
    };
    resolved = {
      enable = true;
      extraConfig = ''
        DNSStubListenerExtra=10.1.0.1
      '';
    };
    adguardhome = {
      enable = true;
      mutableSettings = false;
      settings = {
        dns = {
          bind_hosts = [ "127.0.1.53" ];
          bootstrap_dns = [ "9.9.9.9" ];
        };
        filters = [
          {
            enabled = true;
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
            name = "AdGuard DNS filter";
            id = 1;
          }
          {
            enabled = true;
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
            name = "AdAway Default Blocklist";
            id = 2;
          }
          {
            enabled = true;
            url = "https://blocklistproject.github.io/Lists/adguard/porn-ags.txt";
            name = "BlocklistProject Porn Blocklist";
            id = 3;
          }
        ];
        filtering.rewrites = [
          {
            domain = "router.internal";
            answer = "10.1.0.1";
          }
          {
            domain = "omada.internal";
            answer = "10.1.0.2";
          }
          {
            domain = "nas.internal";
            answer = "10.1.0.3";
          }
          {
            domain = "cannon-printer.internal";
            answer = "10.1.0.4";
          }
          {
            domain = "hp-printer.internal";
            answer = "10.1.0.5";
          }
          {
            domain = "protectli.internal";
            answer = "10.1.0.6";
          }
          {
            domain = "rpi4b8a.internal";
            answer = "10.1.0.7";
          }
          {
            domain = "rpi4b8b.internal";
            answer = "10.1.0.8";
          }
          {
            domain = "rpi4b8c.internal";
            answer = "10.1.0.9";
          }
          {
            domain = "rpi4b4a.internal";
            answer = "10.1.0.10";
          }
          {
            domain = "macmini-m1.internal";
            answer = "10.1.0.11";
          }
          {
            domain = "macmini-intel.internal";
            answer = "10.1.0.12";
          }
        ];
      };
    };
    caddy = {
      enable = true;
      email = "collin@diekvoss.com";
    };
    cloudflare-ddns = {
      enable = true;
      records = [
        "toyvo.dev"
      ];
      tokenFile = config.sops.secrets.cloudflare_w_dns_r_zone_token.path;
    };
  };
  security.acme =
    let
      cloudflare = {
        email = "collin@diekvoss.com";
        dnsProvider = "cloudflare";
        credentialFiles = {
          "CF_API_EMAIL_FILE" = "${pkgs.writeText "cfemail" ''
            collin@diekvoss.com
          ''}";
          "CF_API_KEY_FILE" = config.sops.secrets.cloudflare_global_api_key.path;
          "CF_DNS_API_TOKEN_FILE" = config.sops.secrets.cloudflare_w_dns_r_zone_token.path;
        };
      };
    in
    {
      acceptTerms = true;
      certs = {
        "diekvoss.net" = cloudflare // {
          extraDomainNames = [ "*.diekvoss.net" ];
        };
        "toyvo.dev" = cloudflare;
      };
    };
  sops.secrets = {
    cloudflare_global_api_key = { };
    cloudflare_w_dns_r_zone_token = { };
  };
  users.users.caddy.extraGroups = [ "acme" ];
}
