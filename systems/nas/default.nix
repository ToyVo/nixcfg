{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    ./samba.nix
    ./nextcloud.nix
    ./homepage.nix
    ./transmission.nix
  ];

  hardware.cpu.amd.updateMicrocode = true;
  networking = {
    hostName = "nas";
    firewall = {
      allowedTCPPorts = [
        80
        53
        443
        8080
        7080
      ];
      allowedUDPPorts = [
        53
        443
        8080
        7080
      ];
    };
  };
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    kernelModules = [ "kvm-amd" ];
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };
  profiles = {
    defaults.enable = true;
    dev.enable = true;
  };
  userPresets.chloe.enable = true;
  userPresets.toyvo.enable = true;
  users.groups.multimedia.members = [
    "chloe"
    "toyvo"
    "nextcloud"
  ];
  fileSystemPresets.boot.enable = true;
  fileSystemPresets.btrfs.enable = true;
  services = {
    bazarr = {
      enable = true;
      openFirewall = true;
      group = "multimedia";
      listenPort = config.homelab.${config.networking.hostName}.services.bazarr.port;
    };
    cockpit = {
      enable = true;
      openFirewall = true;
      port = config.homelab.${config.networking.hostName}.services.cockpit.port;
      allowed-origins = [ "https://cockpit.diekvoss.net" ];
    };
    coder = {
      enable = true;
      accessUrl = "https://coder.diekvoss.net";
      listenAddress = "0.0.0.0:${
        toString config.homelab.${config.networking.hostName}.services.coder.port
      }";
    };
    # discord_bot = {
    #   enable = true;
    #   env_file = config.sops.secrets."discord_bot.env".path;
    #   env = {
    #     MINECRAFT_GEYSER_ADDRESS = "mc.toyvo.dev:25566";
    #     MINECRAFT_MODDED_ADDRESS = "mc.toyvo.dev:25565";
    #     TERRARIA_ADDRESS = "mc.toyvo.dev:7777";
    #     TSHOCK_REST_BASE_URL = "https://mc.toyvo.dev";
    #     IP = "0.0.0.0";
    #     ADDR = "0.0.0.0";
    #     PORT = config.homelab.${config.networking.hostName}.services.discord_bot.port;
    #     BASE_URL = "https://toyvo.dev";
    #     CLOUD_SSH_HOST = "discord_bot@mc.toyvo.dev";
    #     CLOUD_SSH_KEY = config.sops.secrets.cloud_ssh_ed25519.path;
    #   };
    # };
    flaresolverr = {
      enable = true;
      openFirewall = true;
      port = config.homelab.${config.networking.hostName}.services.flaresolverr.port;
      package = pkgs.flaresolverr.overrideAttrs (
        finalAttrs: previousAttrs: rec {
          version = "3.3.24";
          src = pkgs.fetchFromGitHub {
            owner = "FlareSolverr";
            repo = "FlareSolverr";
            rev = "v${version}";
            hash = "sha256-BIV5+yLTgVQJtxi/F9FwtZ4pYcE2vGHmEgwigMtqwD8=";
          };
        }
      );
    };
    home-assistant = {
      enable = true;
      openFirewall = true;
      config = {
        homeassistant = {
          name = "Home";
          unit_system = "metric";
          temperature_unit = "F";
        };
        http = {
          trusted_proxies = [ config.homelab.router.ip ];
          server_port = config.homelab.${config.networking.hostName}.services.home-assistant.port;
        };
      };
    };
    homepage-dashboard.enable = true;
    immich = {
      enable = true;
      openFirewall = true;
      host = "0.0.0.0";
      port = config.homelab.${config.networking.hostName}.services.immich.port;
      group = "multimedia";
    };
    jellyfin = {
      enable = true;
      openFirewall = true;
      group = "multimedia";
    };
    lidarr = {
      enable = true;
      openFirewall = true;
      group = "multimedia";
      settings.server.port = config.homelab.${config.networking.hostName}.services.lidarr.port;
      package = pkgs.lidarr.overrideAttrs rec {
        version = "2.12.4.4658";
        src = pkgs.fetchurl {
          url = "https://github.com/lidarr/Lidarr/releases/download/v${version}/Lidarr.master.${version}.linux-core-x64.tar.gz";
          sha256 = "sha256-ttbQj6GYuKedDEdF8vUZcmc0AluZS6pPC5GCQTUu7OM=";
        };
      };
    };
    minecraft-server = {
      enable = true;
      eula = true;
      enableHibernation = true;
      package = pkgs.papermcServers.papermc-1_21_6;
      declarative = true;
      openFirewall = true;
      serverProperties = {
        server-port = 25566;
        "query.port" = 25566;
        difficulty = 3;
        enable-query = true;
        allow-flight = true;
        spawn-protection = 0;
        max-world-size = 50000;
      };
      mshConfig = {
        Server = {
          Folder = config.services.minecraft-server.dataDir;
          # cfg.package will be linked to cfg.dataDir/minecraft-server
          FileName = "minecraft-server";
          Version = "1.21.6";
          Protocol = 771;
        };
        Commands = {
          StartServer = "${lib.getExe config.services.minecraft-server.package} ${config.services.minecraft-server.jvmOpts}";
          # StartServerParam = "-Xmx1024M -Xms1024M";
          StopServer = "stop";
          StopServerAllowKill = 10;
        };
        Msh = {
          Debug = 3;
          ID = "a8b5f0e12f7def4fe2dc710cdd43993548ff03a3";
          MshPort = 25565;
          MshPortQuery = 25565;
          EnableQuery = true;
          TimeBeforeStoppingEmptyServer = 30;
          SuspendAllow = false;
          SuspendRefresh = -1;
          InfoHibernation = "                   §fserver status:\n                   §b§lHIBERNATING";
          InfoStarting = "                   §fserver status:\n                    §6§lWARMING UP";
          NotifyUpdate = true;
          NotifyMessage = true;
          Whitelist = [ ];
          WhitelistImport = false;
          ShowResourceUsage = false;
          ShowInternetUsage = false;
        };
      };
    };
    nextcloud.enable = true;
    nix-serve = {
      enable = true;
      openFirewall = true;
      secretKeyFile = config.sops.secrets."cache-priv-key.pem".path;
      port = config.homelab.${config.networking.hostName}.services.nix-serve.port;
    };
    ollama = {
      enable = true;
      port = config.homelab.${config.networking.hostName}.services.ollama.port;
    };
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    # Immich doesn't support postgresql_17 yet;
    postgresql.package = pkgs.postgresql_16;
    prowlarr = {
      enable = true;
      openFirewall = true;
      settings.server.port = config.homelab.${config.networking.hostName}.services.prowlarr.port;
    };
    radarr = {
      enable = true;
      openFirewall = true;
      group = "multimedia";
      settings.server.port = config.homelab.${config.networking.hostName}.services.radarr.port;
    };
    readarr = {
      enable = true;
      openFirewall = true;
      group = "multimedia";
      settings.server.port = config.homelab.${config.networking.hostName}.services.readarr.port;
    };
    samba.enable = true;
    sonarr = {
      enable = true;
      openFirewall = true;
      group = "multimedia";
      settings.server.port = config.homelab.${config.networking.hostName}.services.sonarr.port;
    };
    spice-vdagentd.enable = true;
    transmission.enable = true;
  };
  containerPresets = {
    podman.enable = true;
    open-webui = {
      enable = true;
      openFirewall = true;
      dataDir = "/mnt/POOL/open-webui";
      port = config.homelab.${config.networking.hostName}.services.open-webui.port;
    };
    portainer = {
      enable = true;
      openFirewall = true;
      sport = config.homelab.${config.networking.hostName}.services.portainer.port;
    };
  };
  fileSystems."/mnt/POOL" = {
    device = "/dev/disk/by-label/POOL";
    fsType = "btrfs";
  };
  users.users.toyvo.extraGroups = [ "libvirtd" ];
  home-manager.users.toyvo.programs.beets.settings.directory = "/mnt/POOL/Public/Music";
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [
    bottles
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    virtio-win
    guestfs-tools
    libosinfo
    win-spice
    distrobox
  ];
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };
  sops.secrets."cache-priv-key.pem" = { };
}
