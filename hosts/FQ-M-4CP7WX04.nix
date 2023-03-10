{nixpkgs, nixpkgs-unstable, home-manager, darwin}: let
  system = "aarch64-darwin";
  user = "CollinDie";
  pkgs = nixpkgs.legacyPackages.${system};
  pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
in darwin.lib.darwinSystem {
  inherit system pkgs;
  modules = [
    ../system/work.nix
    home-manager.darwinModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = {
        inherit pkgs-unstable;
      };
      home-manager.users.${user} = {
        home.username = user;
        home.homeDirectory = "/Users/${user}";
        imports = [ 
          ../home/home-common.nix 
          ../home/home-darwin.nix
          ../home/emu.nix
          ../home/neovim.nix
          ../home/alacritty.nix
          ../home/kitty.nix
          ../home/git.nix
          ../home/gpg-common.nix
          ../home/gpg-darwin.nix
          ../home/starship.nix
          ../home/zsh.nix
        ];
      };
      users.users.${user} = {
        name = user;
        description = "Collin Diekvoss";
        home = "/Users/${user}";
      };
    }
  ];
}
