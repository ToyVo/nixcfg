{
  description = "Collin Diekvoss Dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware
    nixos-hardware.url = "github:nixos/nixos-hardware";
    apple-silicon-support = {
      url = "github:tpwrules/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Applications
    hyprland = {
      url = "github:hyprwm/hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mkAlias = {
      url = "github:reckenrode/mkAlias";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:pta2002/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: {
    darwinConfigurations = {
      MacBook-Pro = import ./systems/aarch64-darwin/MacBook-Pro { inherit inputs; };
      MacMini-M1 = import ./systems/aarch64-darwin/MacMini-M1 { inherit inputs; };
      FQ-M-4CP7WX04 = import ./systems/aarch64-darwin/FQ-M-4CP7WX04 { inherit inputs; };
    };

    nixosConfigurations = {
      Thinkpad = import ./systems/x86_64-linux/Thinkpad { inherit inputs; };
      HP-Envy = import ./systems/x86_64-linux/HP-Envy { inherit inputs; };
      HP-ZBook = import ./systems/x86_64-linux/HP-ZBook { inherit inputs; };
      Protectli = import ./systems/x86_64-linux/Protectli { inherit inputs; };
      router = import ./systems/x86_64-linux/router { inherit inputs; };
      ncase = import ./systems/x86_64-linux/ncase { inherit inputs; };
      steamdeck-nixos = import ./systems/x86_64-linux/steamdeck-nixos { inherit inputs; };

      MacBook-Pro-Nixos = import ./systems/aarch64-linux/MacBook-Pro-Nixos { inherit inputs; };
      rpi4b8a = import ./systems/aarch64-linux/rpi4b8a { inherit inputs; };
      PineBook-Pro = import ./systems/aarch64-linux/PineBook-Pro { inherit inputs; };
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };
}
