inputs:
let
  system = "aarch64-darwin";
  user = "CollinDie";
in inputs.darwin.lib.darwinSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    inputs.home-manager.darwinModules.home-manager
    inputs.nixvim.nixDarwinModules.nixvim
    ../system/darwin.nix
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
