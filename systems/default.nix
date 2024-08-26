{ apple-silicon-support
, catppuccin
, disko
, home-manager
, jovian
, mc_discord_bot
, nh_darwin
, nix-darwin
, nix-index-database
, nixos-cosmic
, nixos-hardware
, nixos-unstable
, nixvim
, plasma-manager
, self
, sops-nix
, nur
, ...
}@inputs:
let
  sharedHomeManagerModules = [
    catppuccin.homeManagerModules.catppuccin
    nix-index-database.hmModules.nix-index
    nixvim.homeManagerModules.nixvim
    self.homeManagerModules.default
    sops-nix.homeManagerModules.sops
    nur.nixosModules.nur
  ];
  lib = nixos-unstable.lib;
  nixosSystem = { system, nixosModules ? [ ], homeManagerModules ? [ ] }:
    let
      pkgs = self.lib.import_nixpkgs { inherit system; };
      pkgsStable = self.lib.import_nixpkgs { inherit system; nixpkgs=inputs.nixos; };
      specialArgs = inputs // { inherit system pkgsStable; };
    in
    lib.nixosSystem {
      inherit system pkgs;
      specialArgs = specialArgs;
      modules = [
        catppuccin.nixosModules.catppuccin
        disko.nixosModules.disko
        home-manager.nixosModules.default
        mc_discord_bot.nixosModules.mc_discord_bot
        nh_darwin.nixosModules.default
        nix-index-database.nixosModules.nix-index
        nixos-cosmic.nixosModules.default
        nixos-unstable.nixosModules.notDetected
        self.nixosModules.default
        sops-nix.nixosModules.sops
        nur.nixosModules.nur
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
      pkgsStable = self.lib.import_nixpkgs { inherit system; nixpkgs=inputs.nixos; };
      specialArgs = inputs // { inherit system pkgsStable; };
    in
    nix-darwin.lib.darwinSystem {
      inherit pkgs;
      specialArgs = specialArgs;
      modules = [
        home-manager.darwinModules.default
        nh_darwin.nixDarwinModules.prebuiltin
        nix-index-database.darwinModules.nix-index
        self.darwinModules.default
        nur.nixosModules.nur
        {
          home-manager = {
            extraSpecialArgs = specialArgs;
            sharedModules = homeManagerModules ++ sharedHomeManagerModules;
          };
        }
      ] ++ darwinModules;
    };
  homeConfiguration = { system, homeManagerModules ? [ ] }:
    let
      pkgs = self.lib.import_nixpkgs { inherit system; };
      pkgsStable = self.lib.import_nixpkgs { inherit system; nixpkgs=inputs.nixos; };
      specialArgs = inputs // { inherit system pkgsStable; };
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
  homeConfigurations = {
    "deck@steamdeck" = homeConfiguration { system = "x86_64-linux"; homeManagerModules = [ ./steamdeck.nix plasma-manager.homeManagerModules.plasma-manager ]; };
  };
  nixosConfigurations = {
    HP-Envy = nixosSystem { system = "x86_64-linux"; nixosModules = [ ./HP-Envy.nix ]; };
    HP-ZBook = nixosSystem { system = "x86_64-linux"; nixosModules = [ ./HP-ZBook.nix ]; };
    MacBook-Pro-Nixos = nixosSystem { system = "aarch64-linux"; nixosModules = [ ./MacBook-Pro-Nixos apple-silicon-support.nixosModules.apple-silicon-support ]; };
    nas = nixosSystem { system = "x86_64-linux"; nixosModules = [ ./nas ]; };
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
    oracle-cloud-nixos = nixosSystem { system = "aarch64-linux"; nixosModules = [ ./oracle-cloud-nixos.nix "${nixos-unstable}/nixos/modules/profiles/qemu-guest.nix" ]; };
  };
}
