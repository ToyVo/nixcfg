{
  description = "Collin Diekvoss Dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    apple-silicon-support.url = "github:tpwrules/nixos-apple-silicon";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";

    mkAlias.url = "github:reckenrode/mkAlias";
    mkAlias.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:pta2002/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
    jovian.inputs.nixpkgs.follows = "nixpkgs";

    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = inputs: {
    darwinConfigurations = {
      MacBook-Pro = import ./hosts/MacBook-Pro.nix inputs;
      MacMini-M1 = import ./hosts/MacMini-M1.nix inputs;
      FQ-M-4CP7WX04 = import ./hosts/FQ-M-4CP7WX04.nix inputs;
    };

    nixosConfigurations = {
      Thinkpad = import ./hosts/Thinkpad.nix inputs;
      HP-Envy = import ./hosts/HP-Envy.nix inputs;
      HP-ZBook = import ./hosts/HP-ZBook.nix inputs;
      Protectli = import ./hosts/Protectli.nix inputs;
      MacBook-Pro-Nixos = import ./hosts/MacBook-Pro-Nixos.nix inputs;
      rpi4b8a = import ./hosts/rpi4b8a.nix inputs;
      PineBook-Pro = import ./hosts/PineBook-Pro.nix inputs;
      router = import ./hosts/router.nix inputs;
      ncase = import ./hosts/ncase.nix inputs;
      steamdeck-nixos = import ./hosts/steamdeck-nixos.nix inputs;
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
