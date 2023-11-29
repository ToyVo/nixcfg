{ pkgs, ... }: {
  hardware.cpu.amd.updateMicrocode = true;
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
  };
  fileSystems."/mnt/POOL" = {
    device = "/dev/disk/by-label/POOL";
    fsType = "btrfs";
  };
  users.users = {
    chloe = {
      isNormalUser = true;
      description = "Chloe Diekvoss";
    };
    share = {
      isNormalUser = true;
    };
  };
  virtualization.docker = {
    enable = true;
    storageDriver = "btrfs";
  };
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
    enable = true;
    package = pkgs.nextcloud27;
    hostName = "nextcloud.diekvoss.net";
    home = "/mnt/POOL/nextcloud";
    config = {
      extraTrustedDomains = ["10.1.0.3"];
      adminpassFile = "${./adminpass}";
    };
  };
}
