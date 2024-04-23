{ pkgs, ... }: {
  imports = [ ./samba.nix ];

  hardware = {
    cpu.amd.updateMicrocode = true;
    bluetooth.enable = true;
  };
  networking.hostName = "ncase";
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
    kernelModules = [ "kvm-amd" ];
  };
  profiles.defaults.enable = true;
  userPresets.toyvo.enable = true;
  fileSystemPresets.efi.enable = true;
  fileSystemPresets.btrfs.enable = true;
  services = {
    openssh.enable = true;
    desktopManager.plasma6.enable = true;
    remote-builds.server.enable = true;
    ollama.enable = true;
    spice-vdagentd.enable = true;
    nextcloud = {
      enable = true;
      home = "/mnt/POOL/nextcloud";
      hostName = "nextcloud.diekvoss.net";
      config.adminpassFile = "${./nextcloudpass.txt}";
    };
  };
  containerPresets = {
    homepage = {
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
    chloe = {
      isNormalUser = true;
      description = "Chloe Diekvoss";
    };
    share = {
      isSystemUser = true;
      group = "share";
    };
  };
  users.groups.share = {};
  programs = {
    steam.enable = true;
    dconf.enable = true;
  };
  environment.systemPackages = with pkgs; [
    steamPackages.steamcmd
    discord
    r2modman
    (pkgs.wrapOBS {
      plugins = with pkgs.obs-studio-plugins; [
        obs-gstreamer
        obs-vkcapture
        obs-vaapi
      ];
    })
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    win-virtio
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
}
