{ home-manager, darwin, ... }@inputs:
let
  system = "aarch64-darwin";
  user = "CollinDie";
in darwin.lib.darwinSystem {
  inherit system;
  modules = [
    ../system/darwin.nix
    home-manager.darwinModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs system; };
      home-manager.users.${user} = {
        home.username = user;
        home.homeDirectory = "/Users/${user}";
        imports = [
          ../home
          ../home/emu.nix
          ../home/neovim
          ../home/git.nix
          ../home/gpg.nix
          ../home/ssh.nix
          ../home/starship.nix
          ../home/zsh.nix
          ../home/alias-mac-apps.nix
        ];
      };
      users.users.${user} = {
        name = user;
        description = "Collin Diekvoss";
        home = "/Users/${user}";
      };
      homebrew.brews = [
        "mongosh"
        "mongodb-community@4.4"
        "mongodb-community-shell@4.4"
        "mongodb-database-tools"
      ];
      homebrew.casks = [
        # nix package not available on darwin
        "docker"
        "mongodb-compass"
      ];
      homebrew.taps = [
        "mongodb/brew"
      ];
    }
  ];
}
