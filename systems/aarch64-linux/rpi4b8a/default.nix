{ inputs, ... }:
let
  system = "aarch64-linux";
in
inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    inputs.nixpkgs.nixosModules.notDetected
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    inputs.home-manager.nixosModules.home-manager
    ../../../modules/nixos/cd-nixos
    ../../../modules/nixos/users/toyvo
    ({ lib, ... }: {
      home-manager.extraSpecialArgs = { inherit inputs system; };
      powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
      nixpkgs.hostPlatform = lib.mkDefault system;
      networking.hostName = "rpi4b8a";
      boot = {
        loader.grub.enable = false;
        loader.generic-extlinux-compatible.enable = false;
        loader.systemd-boot.enable = true;
        initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
      };
      cd = {
        defaults.enable = true;
        users.toyvo.enable = true;
        fs.boot.enable = true;
        fs.btrfs.enable = true;
      };
      hardware.raspberry-pi."4".fkms-3d.enable = true;
    })
  ];
}