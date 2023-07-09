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
    inputs.jovian.nixosModules.jovian
    ../system/filesystem/btrfs.nix
    ../system/filesystem/efi.nix
    ../system/gnome.nix
    ../home/toyvo.nix
    ({ lib, pkgs, ... }: {
      boot = {
        initrd.availableKernelModules = [ "nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
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
        options = [ "defaults" "nofail" ];
      };
      swapDevices = [ ];
      hardware.cpu.amd.updateMicrocode = true;
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      networking.hostName = "steamdeck";
      jovian = {
        devices.steamdeck.enable = true;
        steam.enable = true;
        steam.autoStart = true;
        steam.user = "toyvo";
        steam.desktopSession = "gnome";
      };
      environment.systemPackages = [
        pkgs.steam
      ];
      services.xserver.displayManager.gdm.enable = lib.mkForce false;
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs system; };
      cdcfg.users.toyvo.enable = true;
    })
  ];
}
