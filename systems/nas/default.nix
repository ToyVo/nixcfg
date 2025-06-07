{
  pkgs,
  ...
}:
{
  imports = [
    ./samba.nix
    ./nextcloud.nix
    ./homepage.nix
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
  fileSystemPresets.boot.enable = true;
  fileSystemPresets.btrfs.enable = true;
  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    remote-builds.server.enable = true;
    ollama.enable = true;
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
    #     BASE_URL = "https://toyvo.dev";
    #     CLOUD_SSH_HOST = "discord_bot@mc.toyvo.dev";
    #     CLOUD_SSH_KEY = config.sops.secrets.cloud_ssh_ed25519.path;
    #   };
    # };
    jellyfin = {
      enable = true;
      openFirewall = true;
    };
    coder = {
      enable = true;
      accessUrl = "https://coder.diekvoss.net";
      listenAddress = "0.0.0.0:7080";
    };
    cockpit = {
      enable = true;
      openFirewall = true;
      allowed-origins = [ "https://cockpit.diekvoss.net" ];
    };
    homepage-dashboard.enable = true;
    deluge = {
      enable = true;
      web = {
        enable = true;
        openFirewall = true;
      };
    };
    immich = {
      enable = true;
      openFirewall = true;
      host = "0.0.0.0";
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
        http.trusted_proxies = [ "10.1.0.1" ];
      };
    };
    nextcloud.enable = true;
    sonarr = {
      enable = true;
      openFirewall = true;
    };
    lidarr = {
      enable = true;
      openFirewall = true;
    };
    radarr = {
      enable = true;
      openFirewall = true;
    };
    bazarr = {
      enable = true;
      openFirewall = true;
    };
    prowlarr = {
      enable = true;
      openFirewall = true;
    };
    readarr = {
      enable = true;
      openFirewall = true;
    };
    flaresolverr = {
      enable = true;
      openFirewall = true;
      package = pkgs.toyvo.byparr;
    };
  };
  containerPresets = {
    podman.enable = true;
    open-webui = {
      enable = true;
      openFirewall = true;
      dataDir = "/mnt/POOL/open-webui";
      port = 11435;
    };
    portainer = {
      enable = true;
      openFirewall = true;
    };
  };
  fileSystems."/mnt/POOL" = {
    device = "/dev/disk/by-label/POOL";
    fsType = "btrfs";
  };
  users.users.toyvo.extraGroups = [ "libvirtd" ];
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
}
