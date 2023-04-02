{
  description = "Collin Diekvoss Dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    apple-silicon-support.url = "github:tpwrules/nixos-apple-silicon";
  };

  outputs = { nixpkgs, home-manager, darwin, nixos-hardware, apple-silicon-support, self }: {
    darwinConfigurations = {
      MacBook-Pro = import ./hosts/MacBook-Pro.nix {
        inherit nixpkgs home-manager darwin;
      };
      FQ-M-4CP7WX04 = import ./hosts/FQ-M-4CP7WX04.nix {
        inherit nixpkgs home-manager darwin;
      };
    };

    nixosConfigurations = {
      Thinkpad = import ./hosts/Thinkpad.nix {
        inherit nixpkgs home-manager;
      };
      HP-Envy = import ./hosts/HP-Envy.nix {
        inherit nixpkgs home-manager;
      };
      HP-ZBook = import ./hosts/HP-ZBook.nix {
        inherit nixpkgs home-manager;
      };
      Protectli = import ./hosts/Protectli.nix {
        inherit nixpkgs home-manager;
      };
      MacBook-Pro-Nixos = import ./hosts/MacBook-Pro-Nixos.nix {
        inherit nixpkgs home-manager apple-silicon-support;
      };
      rpi4b8a = import ./hosts/rpi4b8a.nix {
        inherit nixpkgs home-manager nixos-hardware;
      };
      PineBook-Pro = import ./hosts/PineBook-Pro.nix {
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
