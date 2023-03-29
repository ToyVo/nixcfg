{nixpkgs, home-manager, darwin}: let
  system = "aarch64-darwin";
  user = "CollinDie";
in darwin.lib.darwinSystem {
  inherit system;
  modules = [
    ../system/darwin.nix
    ({
      homebrew.taps = [
        "mongodb/brew"
      ];
      homebrew.casks = [
        "slack"
        "docker"
      ];
      homebrew.brews = [
        "mongodb-community"
        "mongodb-community-shell"
        "mongosh"
        "mongodb-database-tools"
      ];
    })
    home-manager.darwinModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = {
        home.username = user;
        home.homeDirectory = "/Users/${user}";
        imports = [ 
          ../home/home-darwin.nix
          ../home/emu.nix
          ../home/neovim
          ../home/alacritty.nix
          ../home/kitty.nix
          ../home/git.nix
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
