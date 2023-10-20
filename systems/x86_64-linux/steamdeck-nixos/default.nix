{ inputs, ... }:
let
  system = "x86_64-linux";
in
inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    inputs.nixpkgs.nixosModules.notDetected
    inputs.home-manager.nixosModules.home-manager
    inputs.jovian.nixosModules.jovian
    ../../../modules/nixos/cd-nixos
    ../../../modules/nixos/toyvo
    ({ lib, pkgs, ... }: {
      home-manager.extraSpecialArgs = { inherit inputs system; };
      nixpkgs.hostPlatform = lib.mkDefault system;
      nixpkgs.overlays = [ inputs.jovian.overlays.jovian ];
      hardware.cpu.amd.updateMicrocode = true;
      networking.hostName = "steamdeck-nixos";
      boot = {
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
        initrd.availableKernelModules = [ "nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
        kernelModules = [ "kvm-amd" ];
      };
      cd = {

        users.toyvo.enable = true;
        fs.boot.enable = true;
        fs.btrfs.enable = true;
        plasma.enable = true;
      };
      fileSystems."/mnt/POOL" = {
        device = "/dev/disk/by-label/POOL";
        fsType = "btrfs";
        options = [ "nofail" "noatime" "lazytime" "compress-force=zstd" "space_cache=v2" "autodefrag" "ssd_spread" ];
      };
      jovian = {
        devices.steamdeck.enable = true;
        steam.enable = true;
        steam.autoStart = true;
        steam.user = "toyvo";
        steam.desktopSession = "plasma-wayland";
      };
      environment.systemPackages = [
        pkgs.steam
      ];
      services.xserver.displayManager.sddm.enable = lib.mkForce false;
    })
  ];
}