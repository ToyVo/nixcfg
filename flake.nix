{
  description = "Collin Diekvoss Dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
  };

  outputs = { nixpkgs, home-manager, darwin, nixos-hardware, ... }: {
    darwinConfigurations = {
      Collins-MacBook-Pro = import ./hosts/Collins-MacBook-Pro.nix {
        inherit home-manager darwin;
      };

      FQ-M-4CP7WX04 = import ./hosts/FQ-M-4CP7WX04.nix {
        inherit home-manager darwin;
      };
    };

    nixosConfigurations = {
      Collins-Thinkpad = import ./hosts/Collins-Thinkpad.nix {
        inherit nixpkgs home-manager;
      };

      rpi4b8a = import ./hosts/rpi4b8a.nix {
        inherit nixpkgs home-manager nixos-hardware;
      };

      Collins-PineBook-Pro = import ./hosts/Collins-PineBook-Pro.nix {
        inherit nixpkgs home-manager nixos-hardware;
      };
    };

    homeConfigurations = {
      "deck" = import ./hosts/SteamDeck.nix {
        inherit nixpkgs home-manager;
      };
    };
  };
}
