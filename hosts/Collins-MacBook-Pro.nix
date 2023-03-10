{home-manager, darwin}:
darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  modules = [
    ../system/darwin.nix
    home-manager.darwinModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.toyvo = {
        home.username = "toyvo";
        home.homeDirectory = "/Users/toyvo";
        imports = [ 
          ../home/home-common.nix
          ../home/home-darwin.nix
          ../home/neovim.nix
          ../home/alacritty.nix
          ../home/kitty.nix
          ../home/git.nix
          ../home/gpg-common.nix
          ../home/gpg-darwin.nix
          ../home/ssh.nix
          ../home/starship.nix
          ../home/zsh.nix
        ];
      };
      users.users.toyvo = {
        name = "toyvo";
        description = "Collin Diekvoss";
        home = "/Users/toyvo";
      };
    }
  ];
}
