{nixpkgs, home-manager, nixos-hardware}:
nixpkgs.lib.nixosSystem {
  system = "aarch64-linux";
  modules = [
    ../system/rpi4b8a.nix
    nixos-hardware.nixosModules.raspberry-pi-4
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
        ];
      };
    }
  ];
}
