{ config, pkgs, ... }:
{
  imports = [ ./samba.nix ];

  hardware.cpu.amd.updateMicrocode = true;
  networking = {
    hostName = "nas";
    firewall = {
      allowedTCPPorts = [
        80
        53
        443
      ];
      allowedUDPPorts = [
        53
        443
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
    nextcloud = {
      enable = true;
      home = "/mnt/POOL/nextcloud";
      hostName = "nextcloud.diekvoss.net";
      config.adminpassFile = config.sops.secrets.nextcloud_admin_password.path;
    };
    discord_bot = {
      enable = true;
      env_file = config.sops.secrets."discord_bot.env".path;
      env = {
        MINECRAFT_GEYSER_RCON_ADDRESS = "100.89.118.92:25576";
        MINECRAFT_MODDED_RCON_ADDRESS = "100.89.118.92:25575";
        TSHOCK_REST_BASE_URL = "http://100.89.118.92:7878";
      };
    };
  };
  sops.secrets = {
    nextcloud_admin_password = {
      owner = "nextcloud";
    };
    "discord_bot.env" = { };
  };
  containerPresets = {
    podman.enable = true;
    homepage = {
      enable = true;
      openFirewall = true;
    };
    open-webui = {
      enable = true;
      openFirewall = true;
    };
  };
  fileSystems."/mnt/POOL" = {
    device = "/dev/disk/by-label/POOL";
    fsType = "btrfs";
  };
  users.users = {
    toyvo.extraGroups = [ "libvirtd" ];
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
