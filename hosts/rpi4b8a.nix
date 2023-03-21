{nixpkgs, home-manager, nixos-hardware}: let
  system = "aarch64-linux";
  user = "toyvo";
in nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ../system/common.nix
    ../system/nixos.nix
    ../system/rpi4b8a.nix
    nixos-hardware.nixosModules.raspberry-pi-4
    home-manager.nixosModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = {
        home.username = user;
        home.homeDirectory = "/home/${user}";
        imports = [ 
          ../home/home-common.nix
          ../home/neovim.nix
          ../home/git.nix
          ../home/gpg-common.nix
          ../home/gpg-linux.nix
          ../home/ssh.nix
          ../home/starship.nix
          ../home/zsh.nix
          ../home/kitty.nix
          ../home/alacritty.nix
        ];
      };
    }
  ];
}
