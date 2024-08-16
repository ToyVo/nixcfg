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
    nix_home_files.url = "github:toyvo/nix_home_files";
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
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";
    nur.url = "github:nix-community/nur";
  };

  outputs = inputs@{ flake-parts, rust-overlay, nixpkgs-esp-dev, nixos-unstable, ... }:
    let
      configurations = import ./systems inputs;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = {
        lib.import_nixpkgs = { system, nixpkgs ? nixos-unstable }: import nixpkgs {
          inherit system;
          overlays = [ (import rust-overlay) nixpkgs-esp-dev.overlays.default ];
          config.allowUnfree = true;
        };
        nixosModules.default = ./modules/nixos;
        darwinModules.default = ./modules/darwin;
        homeManagerModules.default = ./modules/home;
        nixosConfigurations = configurations.nixosConfigurations;
        darwinConfigurations = configurations.darwinConfigurations;
        homeConfigurations = configurations.homeConfigurations;
      };
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      perSystem = { config, pkgs, system, self', ... }: {
        _module.args.pkgs = self'.lib.import_nixpkgs { };
      };
    };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cosmic.cachix.org/"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
    ];
  };
}
