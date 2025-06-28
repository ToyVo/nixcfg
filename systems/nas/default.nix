{
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./samba.nix
    ./nextcloud.nix
    ./homepage.nix
    ./starr.nix
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
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    ollama = {
      enable = true;
      port = config.homelab.${config.networking.hostName}.services.ollama.port;
    };
    spice-vdagentd.enable = true;
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
    jellyfin = {
      enable = true;
      openFirewall = true;
      group = "multimedia";
    };
    coder = {
      enable = true;
      accessUrl = "https://coder.diekvoss.net";
      listenAddress = "0.0.0.0:${
        toString config.homelab.${config.networking.hostName}.services.coder.port
      }";
    };
    cockpit = {
      enable = true;
      openFirewall = true;
      port = config.homelab.${config.networking.hostName}.services.cockpit.port;
      allowed-origins = [ "https://cockpit.diekvoss.net" ];
    };
    homepage-dashboard.enable = true;
    immich = {
      enable = true;
      openFirewall = true;
      host = "0.0.0.0";
      port = config.homelab.${config.networking.hostName}.services.immich.port;
      group = "multimedia";
    };
    # Immich doesn't support postgresql_17 yet;
    postgresql.package = pkgs.postgresql_16;
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
    nextcloud.enable = true;
    nix-serve = {
      enable = true;
      openFirewall = true;
      secretKeyFile = config.sops.secrets."cache-priv-key.pem".path;
      port = config.homelab.${config.networking.hostName}.services.nix-serve.port;
    };
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
