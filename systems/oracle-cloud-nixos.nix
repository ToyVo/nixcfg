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
  containerPresets.podman.enable = true;
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
  environment.systemPackages = with pkgs; [
    packwiz
  ];
  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    discord_bot = {
      enable = true;
      env_file = config.sops.secrets."discord_bot.env".path;
      rclone_dir = "${config.users.users.${config.userPresets.toyvo.name}.home}/.config/rclone";
      minecraft = {
        openFirewall = true;
        datadir = "/minecraft-modded-data";
      };
      minecraft_geyser = {
        openFirewall = true;
        datadir = "/minecraft-geyser-data";
      };
      terraria = {
        openFirewall = true;
        datadir = "/terraria-data";
      };
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
        "https://static.toyvo.dev:443" = {
          useACMEHost = "static.toyvo.dev";
          extraConfig = ''
            reverse_proxy http://0.0.0.0:8787
          '';
        };
      };
    };
    static-web-server = {
      enable = true;
      root = "/var/www/";
    };
    surrealdb.extraFlags = [ "--user" "--pass" ];
    remote-builds.server.enable = true;
    github-runners = {
      discord_bot = {
        enable = true;
        name = config.networking.hostName;
        tokenFile = config.sops.secrets.gha_discord_bot.path;
        user = "nixremote";
        group = "nixremote";
        url = "https://github.com/toyvo/discord_bot";
        extraPackages = with pkgs; [
          nixVersions.nix_2_22
          cachix
        ];
      };
      nh_darwin = {
        enable = true;
        name = config.networking.hostName;
        tokenFile = config.sops.secrets.gha_nh_darwin.path;
        user = "nixremote";
        group = "nixremote";
        url = "https://github.com/toyvo/nh_darwin";
        extraPackages = with pkgs; [
          nixVersions.nix_2_22
          cachix
        ];
      };
      nur-packages = {
        enable = true;
        name = config.networking.hostName;
        tokenFile = config.sops.secrets.gha_nur.path;
        user = "nixremote";
        group = "nixremote";
        url = "https://github.com/toyvo/nur-packages";
        extraPackages = with pkgs; [
          nixVersions.nix_2_22
          cachix
        ];
      };
    };
  };
  systemd.services.surrealdb.preStart = ''
    export SURREAL_USER=root
    export SURREAL_PASS=$(cat ${config.sops.secrets.surreal_pass.path})
  '';
  security.acme = {
    acceptTerms = true;
    certs =
      let
        cf = {
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
        "mc.toyvo.dev" = cf;
        "static.toyvo.dev" = cf;
      };
  };
  sops.secrets = {
    gha_discord_bot = {
      format = "yaml";
      sopsFile = ../secrets/oracle.yaml;
      owner = "nixremote";
      group = "nixremote";
    };
    gha_nh_darwin = {
      format = "yaml";
      sopsFile = ../secrets/oracle.yaml;
      owner = "nixremote";
      group = "nixremote";
    };
    gha_nur = {
      format = "yaml";
      sopsFile = ../secrets/oracle.yaml;
      owner = "nixremote";
      group = "nixremote";
    };
    cloudflare_global_api_key = { };
    cloudflare_w_dns_r_zone_token = { };
    "discord_bot.env" = { };
    surreal_pass = { };
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
