{
  description = "Collin Diekvoss Nix Configurations";

  inputs = {
    nixos.url = "github:nixos/nixpkgs/nixos-24.05";
    nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    # Hardware
    nixos-hardware.url = "github:nixos/nixos-hardware";
    apple-silicon-support.url = "github:tpwrules/nixos-apple-silicon";
    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
    # Applications
    mc_discord_bot.url = "github:toyvo/mc_discord_bot";
    mkAlias.url = "github:reckenrode/mkAlias";
    nh_darwin.url = "github:toyvo/nh_darwin";
    nixpkgs-esp-dev.url = "github:mirrexagon/nixpkgs-esp-dev";
    nixvim.url = "github:nix-community/nixvim";
    plasma-manager.url = "github:pjones/plasma-manager";
    rust-overlay.url = "github:oxalica/rust-overlay";
    sops-nix.url = "github:Mic92/sops-nix";
    # Misc sources
    catppuccin.url = "github:catppuccin/nix";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
  };

  outputs = inputs:
    let
      configurations = import ./systems inputs;
    in
    {
      lib = import ./lib.nix inputs;
      nixosModules.default = ./modules/nixos;
      darwinModules.default = ./modules/darwin;
      homeManagerModules.default = ./modules/home;
      nixosConfigurations = configurations.nixosConfigurations;
      darwinConfigurations = configurations.darwinConfigurations;
      homeManagerConfigurations = configurations.homeManagerConfigurations;
    };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
