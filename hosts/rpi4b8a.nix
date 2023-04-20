{ nixpkgs, home-manager, nixos-hardware, ... }:
let
  system = "aarch64-linux";
  user = "toyvo";
in
nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ../system/filesystem/sd.nix
    ../system/nixos.nix
    ({ lib, ... }: {
      networking.hostName = "rpi4b8a";
      networking.useDHCP = lib.mkDefault true;
      nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
      hardware.raspberry-pi."4".fkms-3d.enable = true;
    })
    nixos-hardware.nixosModules.raspberry-pi-4
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = {
        home.username = user;
        home.homeDirectory = "/home/${user}";
        imports = [
          ../home
          ../home/neovim
          ../home/git.nix
          ../home/gpg.nix
          ../home/ssh.nix
          ../home/starship.nix
          ../home/zsh.nix
        ];
      };
    }
  ];
}
