{ inputs, ... }:
let
  system = "aarch64-linux";
in
inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    inputs.nixpkgs.nixosModules.notDetected
    inputs.nixos-hardware.nixosModules.pine64-pinebook-pro
    inputs.home-manager.nixosModules.home-manager
    ../../../modules/nixos/cd-nixos
    ../../../modules/nixos/toyvo
    ({ lib, ... }: {
      home-manager.extraSpecialArgs = { inherit inputs system; };
      powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
      nixpkgs.hostPlatform = lib.mkDefault system;
      networking.hostName = "PineBook-Pro";
      boot.loader.systemd-boot.enable = true;
      cd = {
        users.toyvo.enable = true;
        fs.boot.enable = true;
        fs.btrfs.enable = true;
        xfce.enable = true;
      };
    })
  ];
}