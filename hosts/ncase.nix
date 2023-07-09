inputs:
let
  system = "x86_64-linux";
in
inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    inputs.nixpkgs.nixosModules.notDetected
    inputs.nixvim.nixosModules.nixvim
    inputs.home-manager.nixosModules.home-manager
    ../system/nixos.nix
    ../home/toyvo.nix
    ({ lib, ... }: {
      boot = {
        initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
        initrd.kernelModules = [ ];
        kernelModules = [ "kvm-amd" ];
        extraModulePackages = [ ];
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
        loader.efi.efiSysMountPoint = "/boot/efi";
      };
      fileSystems."/mnt/POOL" = {
        device = "/dev/disk/by-label/POOL";
        fsType = "btrfs";
      };
      swapDevices = [ ];
      hardware.cpu.amd.updateMicrocode = true;
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      networking.hostName = "ncase";

      services.samba-wsdd.enable = true;
      networking.firewall.allowedTCPPorts = [ 5357 ];
      networking.firewall.allowedUDPPorts = [ 3702 ];

      users.users.chloe = {
        isNormalUser = true;
        description = "Chloe Diekvoss";
        extraGroups = [ "chloe" "share" ];
      };
      users.users.share = {
        isNormalUser = true;
        extraGroups = [ "share" ];
      };

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
            "guest ok" = "yes";
            "create mask" = "0644";
            "directory mask" = "0755";
            "force user" = "share";
            "force group" = "share";
          };
          collin = {
            path = "/mnt/POOL/Collin";
            browseable = "yes";
            "read only" = "no";
            "guest ok" = "no";
            "create mask" = "0644";
            "directory mask" = "0755";
            "force user" = "toyvo";
            "force group" = "toyvo";
            "valid users" = "@toyvo";
          };
          chloe = {
            path = "/mnt/POOL/Chloe";
            browseable = "yes";
            "read only" = "no";
            "guest ok" = "no";
            "create mask" = "0644";
            "directory mask" = "0755";
            "force user" = "chloe";
            "force group" = "chloe";
            "valid users" = "@chloe";
          };
        };
      };
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs system; };
      cdcfg.users.toyvo.enable = true;
      cdcfg.fs.efi.enable = true;
      cdcfg.fs.btrfs.enable = true;
    })
  ];
}
