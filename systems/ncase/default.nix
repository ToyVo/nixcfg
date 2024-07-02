{ config, pkgs, lib, ... }: {
  imports = [ ./samba.nix ];

  hardware = {
    cpu.amd.updateMicrocode = true;
    bluetooth.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      modesetting.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };
  networking = {
    hostName = "ncase";
    firewall.allowedTCPPorts = [ 80 ];
  };
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
    kernelModules = [ "kvm-amd" ];
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };
  profiles.gaming.enable = true;
  profiles.dev.enable = true;
  userPresets.toyvo.enable = true;
  userPresets.chloe.enable = true;
  fileSystemPresets.efi.enable = true;
  fileSystemPresets.btrfs.enable = true;
  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    desktopManager.plasma6.enable = true;
    remote-builds.server.enable = true;
    ollama.enable = true;
    spice-vdagentd.enable = true;
    nextcloud = {
      enable = true;
      home = "/mnt/POOL/nextcloud";
      hostName = "nextcloud.diekvoss.net";
      config.adminpassFile = "${../../secrets/nextcloudpass.txt}";
    };
    xserver.videoDrivers = [ "nvidia" ];
    displayManager.defaultSession = "plasmax11";
    displayManager.sddm.catppuccin.enable = lib.mkForce false;
  };
  containerPresets = {
    homepage = {
      enable = true;
      openFirewall = true;
    };
    open-webui = {
      enable = true;
      openFirewall = true;
    };
    minecraft-experimental = {
      enable = true;
      openFirewall = true;
      datadir = "/mnt/POOL/minecraft-experimental";
    };
  };
  fileSystems."/mnt/POOL" = {
    device = "/dev/disk/by-label/POOL";
    fsType = "btrfs";
  };
  users.users = {
    toyvo.extraGroups = [ "libvirtd" ];
    share = {
      isSystemUser = true;
      group = "share";
    };
  };
  users.groups.share = { };
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
    mpv
    kdenlive
    glaxnimate
    google-chrome
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
