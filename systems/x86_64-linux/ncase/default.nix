{ pkgs, ... }: {
  hardware.cpu.amd.updateMicrocode = true;
  hardware.bluetooth.enable = true;
  networking = {
    hostName = "ncase";
    firewall.allowedTCPPorts = [ 5357 80 443 ];
    firewall.allowedUDPPorts = [ 3702 ];
  };
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
    kernelModules = [ "kvm-amd" ];
  };
  cd = {
    defaults.enable = true;
    users.toyvo.enable = true;
    fs.boot.enable = true;
    fs.btrfs.enable = true;
    remote-builds.server.enable = true;
    homer = {
      enable = true;
      openFirewall = true;
    };
    desktops.gnome.enable = true;
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
  services.xserver.displayManager.gdm.autoSuspend = false;
  services.samba-wsdd.enable = true;
  services.samba = {
    enable = true;
    openFirewall = true;
    extraConfig = ''
      netbios name = ncasesmb
      security = user
      server role = standalone server
      hosts allow = 10.1.0.0/24 127.0.0.1 localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
    '';
    shares = {
      public = {
        path = "/mnt/POOL/Public";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "share";
        "force group" = "users";
        "valid users" = "@users";
      };
      collin = {
        path = "/mnt/POOL/Collin";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "toyvo";
        "force group" = "users";
        "valid users" = "toyvo";
      };
      chloe = {
        path = "/mnt/POOL/Chloe";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "chloe";
        "force group" = "users";
        "valid users" = "chloe";
      };
    };
  };
  services.nextcloud = {
    enable = false;
    package = pkgs.nextcloud28;
    hostName = "nextcloud.diekvoss.net";
    home = "/mnt/POOL/nextcloud";
    settings.trusted_domains = ["10.1.0.3"];
    config.adminpassFile = "${./adminpass}";
  };
  services.ollama.enable = true;
  programs.steam.enable = true;
  programs.dconf.enable = true;
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
  services.spice-vdagentd.enable = true;
}
