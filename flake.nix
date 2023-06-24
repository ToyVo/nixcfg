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
    hyprland.url = "github:hyprwm/hyprland";
    mkAlias.url = "github:reckenrode/mkAlias";
    mkAlias.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.url = "github:pta2002/nixvim";
    jovian.url = "github:ToyVo/Jovian-NixOS/flakes";
    jovian.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: {
    darwinConfigurations = {
      MacBook-Pro = import ./hosts/MacBook-Pro.nix inputs;
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
      steamdeck = import ./hosts/SteamDeck.nix inputs;
    };
  };
}
