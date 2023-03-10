{nixpkgs, nixpkgs-unstable, nixos-hardware, home-manager}: let
  system = "aarch64-linux";
  user = "toyvo";
  pkgs = nixpkgs.legacyPackages.${system};
  pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
in nixpkgs.lib.nixosSystem {
  inherit system pkgs;
  modules = [
    ../system/pinebookpro.nix
    nixos-hardware.nixosModules.pine64-pinebook-pro
    home-manager.nixosModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = {
        inherit pkgs-unstable;
      };
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
          ../home/home-linux.nix
          ../home/alacritty.nix
          ../home/kitty.nix
        ];
      };
    }
  ];
}
