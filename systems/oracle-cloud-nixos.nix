{
  pkgs,
  config,
  ...
}:
{
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [
      "xhci_pci"
      "virtio_scsi"
    ];
    binfmt.emulatedSystems = [ "x86_64-linux" ];
  };
  containerPresets = {
    podman.enable = true;
  };
  networking = {
    hostName = "oracle-cloud-nixos";
    firewall = {
      allowedTCPPorts = [
        443
        # gmod
        27015
        # minecraft java
        25565
        25566
        # terraria
        7777
        # vintage story
        42420
      ];
      allowedUDPPorts = [
        53
        443
        # gmod
        27015
        27005
        # minecraft bedrock
        19132
        # mincraft voice mod
        24454
        # terraria
        7777
        # vintage story
        42420
      ];
    };
  };
  profiles.defaults.enable = true;
  environment.systemPackages = with pkgs; [
    packwiz
  ];
  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    caddy = {
      enable = true;
      email = "collin@diekvoss.com";
      virtualHosts."mc.toyvo.dev" = {
        useACMEHost = "mc.toyvo.dev";
        extraConfig = "reverse_proxy http://0.0.0.0:7878";
      };
    };
    mcsmanager.daemon = {
      enable = true;
      openFirewall = true;
    };
    mcsmanager.panel = {
      enable = true;
      openFirewall = true;
    };
    minecraft-server = {
      declarative = true;
      enable = true;
      eula = true;
      lazymc = {
        enable = true;
        config = {
          public = {
            protocol = 771;
            version = "1.21.6";
          };
          advanced.rewrite_server_properties = false;
        };
      };
      openFirewall = true;
      package = pkgs.papermcServers.papermc-1_21_11;
      serverProperties = {
        allow-flight = true;
        difficulty = 3;
        enable-query = true;
        max-world-size = 50000;
        "query.port" = 25566;
        server-port = 25566;
        spawn-protection = 0;
      };
    };
  };
  security = {
    acme = {
      acceptTerms = true;
      certs."mc.toyvo.dev" = {
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
    };
  };
  containerPresets.portainer = {
    enable = true;
  };
  sops.secrets = {
    cloudflare_global_api_key = { };
    cloudflare_w_dns_r_zone_token = { };
    "discord_bot.env" = { };
    "rclone.conf" = { };
  };
  users.users.caddy.extraGroups = [ "acme" ];
  userPresets.toyvo.enable = true;
  disko.devices.disk.sda = {
    type = "disk";
    device = "/dev/sda";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          name = "ESP";
          size = "500M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            extraArgs = [
              "-n"
              "BOOT"
            ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [
              "-f"
              "-L"
              "NIXOS"
            ];
            subvolumes = {
              "@" = {
                mountpoint = "/";
              };
              "@home" = {
                mountOptions = [ "compress=zstd" ];
                mountpoint = "/home";
              };
              "@nix" = {
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
                mountpoint = "/nix";
              };
            };
          };
        };
      };
    };
  };
}
