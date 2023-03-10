{home-manager, darwin}:
darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  modules = [
    ../system/work.nix
    home-manager.darwinModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.CollinDie = {
        home.username = "CollinDie";
        home.homeDirectory = "/Users/CollinDie";
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
      users.users.CollinDie = {
        name = "CollinDie";
        description = "Collin Diekvoss";
        home = "/Users/CollinDie";
      };
    }
  ];
}
