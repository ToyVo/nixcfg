{ pkgs, config, ... }: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "virtio_scsi" ];
  networking.hostName = "oracle-cloud-nixos";
  networking.firewall.allowedTCPPorts = [ 443 ];
  networking.firewall.allowedUDPPorts = [ 443 ];
  profiles.defaults.enable = true;
  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    mc_discord_bot = {
      enable = true;
      env_file = config.sops.secrets."discord_bot.env".path;
    };
    caddy = {
      enable = true;
      email = "collin@diekvoss.com";
      virtualHosts."https://mc.toyvo.dev:443" = {
        useACMEHost = "mc.toyvo.dev";
        extraConfig = ''
          reverse_proxy http://0.0.0.0:8080
        '';
      };
    };
  };
  security.acme = {
    acceptTerms = true;
    certs = {
      "mc.toyvo.dev" = {
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
  sops.secrets = {
    cloudflare_global_api_key = { };
    cloudflare_w_dns_r_zone_token = { };
    discord_client_id = { };
    discord_client_secret = { };
    discord_public_key = { };
    discord_bot_token = { };
    "discord_bot.env" = { };
    forge_api_key = { };
  };
  users.users.caddy.extraGroups = [ "acme" ];
  userPresets.toyvo.enable = true;
  containerPresets.minecraft = {
    enable = true;
    openFirewall = true;
    datadir = "/minecraft-data/server";
    downloadsdir = "/minecraft-data/downloads";
  };
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
            extraArgs = [ "-n" "BOOT" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" "-L" "NIXOS" ];
            subvolumes = {
              "@" = {
                mountpoint = "/";
              };
              "@home" = {
                mountOptions = [ "compress=zstd" ];
                mountpoint = "/home";
              };
              "@nix" = {
                mountOptions = [ "compress=zstd" "noatime" ];
                mountpoint = "/nix";
              };
            };
          };
        };
      };
    };
  };
}
