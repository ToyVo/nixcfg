{nixpkgs, nixos-hardware, home-manager}: let
  system = "aarch64-linux";
  user = "toyvo";
in nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ../system/filesystem/sd.nix
    ../system/xfce.nix
    ({ lib, ... }: {
      boot.loader.grub.enable = false;
      boot.loader.generic-extlinux-compatible.enable = true;
      networking.hostName = "PineBook-Pro";
      networking.useDHCP = lib.mkDefault true;
      nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
    })
    nixos-hardware.nixosModules.pine64-pinebook-pro
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
