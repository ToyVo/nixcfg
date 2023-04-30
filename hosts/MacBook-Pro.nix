{ home-manager, darwin, ... }@inputs:
let
  system = "aarch64-darwin";
  user = "toyvo";
in darwin.lib.darwinSystem {
  inherit system;
  modules = [
    ../system/darwin.nix
    ({ homebrew.casks = [ "prusaslicer" ]; })
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
    }
  ];
}
