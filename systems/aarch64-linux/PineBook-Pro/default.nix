{ inputs, ... }:
let
  system = "aarch64-linux";
in
inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    ({ lib, ... }: {
      imports = [
        inputs.nixos-hardware.nixosModules.pine64-pinebook-pro
        ../../../modules/nixos/cd-nixos
        ../../../modules/nixos/users/toyvo
      ];
      home-manager.extraSpecialArgs = { inherit inputs system; };
      powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
      nixpkgs.hostPlatform = lib.mkDefault system;
      networking.hostName = "PineBook-Pro";
      boot.loader.systemd-boot.enable = true;
      cd = {
        defaults.enable = true;
        users.toyvo.enable = true;
        fs.boot.enable = true;
        fs.btrfs.enable = true;
        desktops.xfce.enable = true;
      };
    })
  ];
}
