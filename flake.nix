{
  description = "Collin Diekvoss Dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-22.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    apple-silicon-support.url = "github:tpwrules/nixos-apple-silicon";
  };

  outputs = { nixpkgs, nixpkgs-unstable, home-manager, darwin, nixos-hardware, apple-silicon-support, self }: {
    darwinConfigurations = {
      Collins-MacBook-Pro = import ./hosts/Collins-MacBook-Pro.nix {
        inherit nixpkgs nixpkgs-unstable home-manager darwin;
      };

      FQ-M-4CP7WX04 = import ./hosts/FQ-M-4CP7WX04.nix {
        inherit nixpkgs nixpkgs-unstable home-manager darwin;
      };
    };

    nixosConfigurations = {
      Collins-Thinkpad = import ./hosts/Collins-Thinkpad.nix {
        inherit nixpkgs nixpkgs-unstable home-manager;
      };

      Collins-MacBook-Pro-Nixos = import ./hosts/Collins-MacBook-Pro-Nixos.nix {
        inherit nixpkgs nixpkgs-unstable home-manager apple-silicon-support;
      };

      rpi4b8a = import ./hosts/rpi4b8a.nix {
        inherit nixpkgs nixpkgs-unstable home-manager nixos-hardware;
      };

      Collins-PineBook-Pro = import ./hosts/Collins-PineBook-Pro.nix {
        inherit nixpkgs nixpkgs-unstable home-manager nixos-hardware;
      };
    };

    homeConfigurations = {
      "deck" = import ./hosts/SteamDeck.nix {
        inherit nixpkgs nixpkgs-unstable home-manager;
      };
    };
  };
}
