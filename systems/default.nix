{ apple-silicon-support
, catppuccin
, home-manager
, jovian
, nh
, nix-darwin
, nix-index-database
, nixos-hardware
, nixos-unstable
, nixvim
, rust-overlay
, self
, sops-nix
, ...
}@inputs:
let
  import_nixpkgs = {system, nixpkgs ? nixos-unstable}: import nixpkgs {
    inherit system;
    overlays = [ (import rust-overlay) ];
    config.allowUnfree = true;
  };
  homeManagerModules = [
    self.homeManagerModules.default
    catppuccin.homeManagerModules.catppuccin
    nix-index-database.hmModules.nix-index
    nixvim.homeManagerModules.nixvim
    sops-nix.homeManagerModules.sops
  ];
  lib = nixos-unstable.lib;
  nixosSystem = system: configurations:
    let
      pkgs = import_nixpkgs { inherit system; };
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
            sharedModules = homeManagerModules;
          };
        }
      ] ++ configurations;
    };
  darwinSystem = system: configurations:
    let
      pkgs = import_nixpkgs { inherit system; };
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
            sharedModules = homeManagerModules;
          };
        }
      ] ++ configurations;
    };
  homeManagerConfiguration = system: configurations:
    let
      pkgs = import_nixpkgs { inherit system; };
      specialArgs = inputs // { inherit system; };
    in
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = specialArgs;
      modules = configurations ++ homeManagerModules;
    };
in
{
  darwinConfigurations = {
    FQ-M-4CP7WX04 = darwinSystem "aarch64-darwin" [ ./FQ-M-4CP7WX04 ];
    MacBook-Pro = darwinSystem "aarch64-darwin" [ ./MacBook-Pro.nix ];
    MacMini-Intel = darwinSystem "x86_64-darwin" [ ./MacMini-Intel.nix ];
    MacMini-M1 = darwinSystem "aarch64-darwin" [ ./MacMini-M1.nix ];
  };
  homeManagerConfigurations."deck@steamdeck" = homeManagerConfiguration "x86_64-linux" [ ./steamdeck.nix ];
  nixosConfigurations = {
    HP-Envy = nixosSystem "x86_64-linux" [ ./HP-Envy.nix ];
    HP-ZBook = nixosSystem "x86_64-linux" [ ./HP-ZBook.nix ];
    MacBook-Pro-Nixos = nixosSystem "aarch64-linux" [ ./MacBook-Pro-Nixos apple-silicon-support.nixosModules.apple-silicon-support ];
    ncase = nixosSystem "x86_64-linux" [ ./ncase ];
    PineBook-Pro = nixosSystem "aarch64-linux" [ ./PineBook-Pro.nix nixos-hardware.nixosModules.pine64-pinebook-pro ];
    Protectli = nixosSystem "x86_64-linux" [ ./Protectli.nix ];
    router = nixosSystem "x86_64-linux"  [  ./router  ];
    rpi4b4a = nixosSystem "aarch64-linux" [ ./rpi4b4a.nix ];
    rpi4b8a = nixosSystem "aarch64-linux" [ ./rpi4b8a.nix ];
    rpi4b8b = nixosSystem "aarch64-linux" [ ./rpi4b8b.nix ];
    rpi4b8c = nixosSystem "aarch64-linux" [ ./rpi4b8c.nix ];
    steamdeck-nixos = nixosSystem "x86_64-linux" [ ./steamdeck-nixos.nix jovian.nixosModules.jovian ];
    Thinkpad = nixosSystem "x86_64-linux" [ ./Thinkpad.nix ];
    utm = nixosSystem "aarch64-linux" [ ./utm.nix "${nixos-unstable}/nixos/modules/profiles/qemu-guest.nix" ];
  };
}
