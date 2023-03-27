{nixpkgs, home-manager}: let
  system = "x86_64-linux";
  user = "toyvo";
in nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ../system/gnome.nix
    nixpkgs.nixosModules.notDetected
    home-manager.nixosModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
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
