{ pkgs, config, ... }:
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
    minecraft-modded = {
      enable = true;
      openFirewall = true;
      dataDir = "/minecraft-modded-data";
      env_file = config.sops.secrets."discord_bot.env".path;
    };
    minecraft-geyser = {
      enable = true;
      openFirewall = true;
      dataDir = "/minecraft-geyser-data";
      env_file = config.sops.secrets."discord_bot.env".path;
    };
    terraria = {
      enable = true;
      openFirewall = true;
      dataDir = "/terraria-data";
    };
  };
  networking = {
    hostName = "oracle-cloud-nixos";
    firewall = {
      allowedTCPPorts = [
        443
      ];
      allowedUDPPorts = [
        53
        443
      ];
    };
  };
  profiles.defaults.enable = true;
  profiles.dev.enable = true;
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
      virtualHosts = {
        "https://mc.toyvo.dev:443" = {
          useACMEHost = "mc.toyvo.dev";
          extraConfig = ''
            reverse_proxy http://0.0.0.0:8080
          '';
        };
      };
    };
    remote-builds.server.enable = true;
    github-runners = {
      nur-packages = {
        enable = true;
        name = config.networking.hostName;
        tokenFile = config.sops.secrets.gha_nur.path;
        user = "nixremote";
        group = "nixremote";
        url = "https://github.com/toyvo/nur-packages";
        extraPackages = with pkgs; [
          cachix
        ];
      };
    };
  };
  security.acme = {
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
  sops.secrets = {
    gha_nur = {
      format = "yaml";
      sopsFile = ../secrets/oracle.yaml;
      owner = "nixremote";
      group = "nixremote";
    };
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
