{ pkgs, ... }: {
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
    mc-discord-bot = {
      enable = true;
      env_file = ./discord-bot.env;
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
          "CF_API_KEY_FILE" = "${../router/cfapikey}";
          "CF_DNS_API_TOKEN_FILE" = "${../router/cfapitoken}";
        };
      };
    };
  };
  users.users.caddy.extraGroups = [ "acme" ];
  userPresets.toyvo.enable = true;
  containerPresets.minecraft = {
    enable = true;
    openFirewall = true;
    datadir = "/minecraft-data";
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
