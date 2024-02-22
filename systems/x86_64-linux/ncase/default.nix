{ pkgs, ... }: {
  imports = [ ./samba.nix ];

  hardware = {
    cpu.amd.updateMicrocode = true;
    bluetooth.enable = true;
  };
  networking = {
    hostName = "ncase";
    firewall = {
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [ 443 ];
    };
  };
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
  fileSystemPresets.boot.enable = true;
  fileSystemPresets.btrfs.enable = true;
  services = {
    xserver.desktopManager.gnome.enable = true;
    remote-builds.server.enable = true;
    xserver.displayManager.gdm.autoSuspend = false;
    nextcloud = {
      enable = false;
      package = pkgs.nextcloud28;
      hostName = "nextcloud.diekvoss.net";
      home = "/mnt/POOL/nextcloud";
      settings.trusted_domains = [ "10.1.0.3" ];
      config.adminpassFile = "${./adminpass}";
    };
    ollama.enable = true;
    spice-vdagentd.enable = true;
  };
  containerPresets = {
    nextcloud = {
      enable = true;
      openFirewall = true;
    };
    homer = {
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
      isNormalUser = true;
    };
  };
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
    gnome.adwaita-icon-theme
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
