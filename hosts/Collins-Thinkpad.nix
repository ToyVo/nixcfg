{nixpkgs, home-manager}:
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ../system/thinkpad.nix
    home-manager.nixosModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.toyvo = {
        home.username = "toyvo";
        home.homeDirectory = "/home/toyvo";
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
