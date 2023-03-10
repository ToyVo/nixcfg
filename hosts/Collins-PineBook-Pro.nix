{nixpkgs, nixos-hardware, home-manager}:
nixpkgs.lib.nixosSystem {
  system = "aarch64-linux";
  modules = [
    ../system/pinebookpro.nix
    nixos-hardware.nixosModules.pine64-pinebook-pro
    home-manager.nixosModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.toyvo = {
        home.username = "toyvo";
        home.homeDirectory = "/home/toyvo";
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
