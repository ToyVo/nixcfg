{ inputs, ... }:
let
  system = "aarch64-linux";
in
inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    inputs.apple-silicon-support.nixosModules.apple-silicon-support
    inputs.nixpkgs.nixosModules.notDetected
    inputs.home-manager.nixosModules.home-manager
    ../../../modules/nixos/cd-nixos
    ../../../modules/nixos/users/toyvo
    ({ lib, ... }: {
      home-manager.extraSpecialArgs = { inherit inputs system; };
      nixpkgs.hostPlatform = lib.mkDefault system;
      powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
      networking.hostName = "MacBook-Pro-Nixos";
      boot = {
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = false;
        initrd.availableKernelModules = [ "usb_storage" "sdhci_pci" ];
      };
      cd = {
        users.toyvo.enable = true;
        fs.boot.enable = true;
        fs.btrfs.enable = true;
        gnome.enable = true;
      };
      hardware.asahi.peripheralFirmwareDirectory = ./firmware;
    })
  ];
}
