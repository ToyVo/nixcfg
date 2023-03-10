{nixpkgs, nixpkgs-unstable, home-manager}: let
  system = "x86_64-linux";
  user = "toyvo";
  pkgs = nixpkgs.legacyPackages.${system};
  pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
in nixpkgs.lib.nixosSystem {
  inherit system pkgs;
  modules = [
    ../system/thinkpad.nix
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
          ../home/home-linux.nix
          ../home/neovim.nix
          ../home/alacritty.nix
          ../home/kitty.nix
          ../home/git.nix
          ../home/gpg-common.nix
          ../home/gpg-linux.nix
          ../home/ssh.nix
          ../home/starship.nix
          ../home/zsh.nix
        ];
      };
    }
  ];
}
