{
  config,
  pkgs,
  ...
}: {
  imports = [./samba.nix];

  hardware.cpu.amd.updateMicrocode = true;
  networking = {
    hostName = "nas";
    firewall = {
      allowedTCPPorts = [
        80
        53
        443
        8080
      ];
      allowedUDPPorts = [
        53
        443
        8080
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
    kernelModules = ["kvm-amd"];
    binfmt.emulatedSystems = ["aarch64-linux"];
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
  };
  # sops.secrets = {
  #   "discord_bot.env" = {
  #     owner = "discord_bot";
  #   };
  #   cloud_ssh_ed25519 = {
  #     owner = "discord_bot";
  #   };
  # };
  containerPresets = {
    podman.enable = true;
    homepage = {
      enable = true;
      openFirewall = true;
      dataDir = "/mnt/POOL/homepage";
    };
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
  users.users = {
    toyvo.extraGroups = ["libvirtd"];
  };
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
        ovmf.packages = [pkgs.OVMFFull.fd];
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
