{nixpkgs, home-manager, apple-silicon-support}: let
  system = "aarch64-linux";
  user = "toyvo";
in nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ../system/common.nix
    ../system/nixos.nix
    ../system/gnome.nix
    ../system/macbook-nixos.nix
    apple-silicon-support.nixosModules.apple-silicon-support
    nixpkgs.nixosModules.notDetected
    home-manager.nixosModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
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

