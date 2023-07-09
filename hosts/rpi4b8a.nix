inputs:
let
  system = "aarch64-linux";
in inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    inputs.home-manager.nixosModules.home-manager
    inputs.nixvim.nixosModules.nixvim
    ../system/filesystem/boot.nix
    ../system/filesystem/btrfs.nix
    ../system/nixos.nix
    ../home/toyvo.nix
    ({ lib, ... }: {
      boot.loader.generic-extlinux-compatible.enable = true;
      networking.hostName = "rpi4b8a";
      networking.useDHCP = lib.mkDefault true;
      nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
      hardware.raspberry-pi."4".fkms-3d.enable = true;
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs system; };
      cdcfg.users.toyvo.enable = true;
    })
  ];
}
