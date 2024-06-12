{ apple-silicon-support
, catppuccin
, disko
, home-manager
, jovian
, nh
, nix-darwin
, nix-index-database
, nixos-hardware
, nixos-unstable
, nixvim
, plasma-manager
, self
, sops-nix
, ...
}@inputs:
let
  sharedHomeManagerModules = [
    self.homeManagerModules.default
    catppuccin.homeManagerModules.catppuccin
    nix-index-database.hmModules.nix-index
    nixvim.homeManagerModules.nixvim
    sops-nix.homeManagerModules.sops
  ];
  lib = nixos-unstable.lib;
  nixosSystem = { system, nixosModules ? [ ], homeManagerModules ? [ ] }:
    let
      pkgs = self.lib.import_nixpkgs { inherit system; };
      specialArgs = inputs // { inherit system; };
    in
    lib.nixosSystem {
      inherit system pkgs;
      specialArgs = specialArgs;
      modules = [
        self.nixosModules.default
        nixos-unstable.nixosModules.notDetected
        catppuccin.nixosModules.catppuccin
        nh.nixosModules.default
        nix-index-database.nixosModules.nix-index
        home-manager.nixosModules.default
        sops-nix.nixosModules.sops
        {
          home-manager = {
            extraSpecialArgs = specialArgs;
            sharedModules = homeManagerModules ++ sharedHomeManagerModules ++ [ plasma-manager.homeManagerModules.plasma-manager ];
          };
        }
      ] ++ nixosModules;
    };
  darwinSystem = { system, darwinModules ? [ ], homeManagerModules ? [ ] }:
    let
      pkgs = self.lib.import_nixpkgs { inherit system; };
      specialArgs = inputs // { inherit system; };
    in
    nix-darwin.lib.darwinSystem {
      inherit pkgs;
      specialArgs = specialArgs;
      modules = [
        self.darwinModules.default
        nh.nixDarwinModules.prebuiltin
        nix-index-database.darwinModules.nix-index
        home-manager.darwinModules.default
        {
          home-manager = {
            extraSpecialArgs = specialArgs;
            sharedModules = homeManagerModules ++ sharedHomeManagerModules;
          };
        }
      ] ++ darwinModules;
    };
  homeManagerConfiguration = { system, homeManagerModules ? [ ] }:
    let
      pkgs = self.lib.import_nixpkgs { inherit system; };
      specialArgs = inputs // { inherit system; };
    in
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = specialArgs;
      modules = homeManagerModules ++ sharedHomeManagerModules;
    };
in
{
  darwinConfigurations = {
    FQ-M-4CP7WX04 = darwinSystem { system = "aarch64-darwin"; darwinModules = [ ./FQ-M-4CP7WX04 ]; };
    MacBook-Pro = darwinSystem { system = "aarch64-darwin"; darwinModules = [ ./MacBook-Pro.nix ]; };
    MacMini-Intel = darwinSystem { system = "x86_64-darwin"; darwinModules = [ ./MacMini-Intel.nix ]; };
    MacMini-M1 = darwinSystem { system = "aarch64-darwin"; darwinModules = [ ./MacMini-M1.nix ]; };
  };
  homeManagerConfigurations = {
    "deck@steamdeck" = homeManagerConfiguration { system = "x86_64-linux"; homeManagerModules = [ ./steamdeck.nix plasma-manager.homeManagerModules.plasma-manager ]; };
  };
  nixosConfigurations = {
    HP-Envy = nixosSystem { system = "x86_64-linux"; nixosModules = [ ./HP-Envy.nix ]; };
    HP-ZBook = nixosSystem { system = "x86_64-linux"; nixosModules = [ ./HP-ZBook.nix ]; };
    MacBook-Pro-Nixos = nixosSystem { system = "aarch64-linux"; nixosModules = [ ./MacBook-Pro-Nixos apple-silicon-support.nixosModules.apple-silicon-support ]; };
    ncase = nixosSystem { system = "x86_64-linux"; nixosModules = [ ./ncase ]; };
    PineBook-Pro = nixosSystem { system = "aarch64-linux"; nixosModules = [ ./PineBook-Pro.nix nixos-hardware.nixosModules.pine64-pinebook-pro ]; };
    Protectli = nixosSystem { system = "x86_64-linux"; nixosModules = [ ./Protectli.nix ]; };
    router = nixosSystem { system = "x86_64-linux"; nixosModules = [ ./router ]; };
    rpi4b4a = nixosSystem { system = "aarch64-linux"; nixosModules = [ ./rpi4b4a.nix ]; };
    rpi4b8a = nixosSystem { system = "aarch64-linux"; nixosModules = [ ./rpi4b8a.nix ]; };
    rpi4b8b = nixosSystem { system = "aarch64-linux"; nixosModules = [ ./rpi4b8b.nix ]; };
    rpi4b8c = nixosSystem { system = "aarch64-linux"; nixosModules = [ ./rpi4b8c.nix ]; };
    steamdeck-nixos = nixosSystem { system = "x86_64-linux"; nixosModules = [ ./steamdeck-nixos.nix jovian.nixosModules.jovian ]; };
    Thinkpad = nixosSystem { system = "x86_64-linux"; nixosModules = [ ./Thinkpad.nix ]; };
    utm = nixosSystem { system = "aarch64-linux"; nixosModules = [ ./utm.nix "${nixos-unstable}/nixos/modules/profiles/qemu-guest.nix" ]; };
    oracle-ampere-nixos = nixosSystem { system = "aarch64-linux"; nixosModules = [ ./oracle.nix "${nixos-unstable}/nixos/modules/virtualisation/oci-image.nix" ]; };
    oracle-cloud-aarch64 = nixosSystem { system = "aarch64-linux"; nixosModules = [ ./oracle-cloud-aarch64.nix disko.nixosModules.disko "${nixos-unstable}/nixos/modules/installer/scan/not-detected.nix" "${nixos-unstable}/nixos/modules/profiles/qemu-guest.nix" ]; };
  };
}
