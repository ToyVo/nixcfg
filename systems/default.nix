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
, ...
}@inputs:
let
  syspkgs = {system, nixpkgs ? nixos-unstable}: import nixpkgs {
    inherit system;
    overlays = [ (import rust-overlay) ];
    config.allowUnfree = true;
  };
  homemodules = [
    self.homeManagerModules.default
    catppuccin.homeManagerModules.catppuccin
    nix-index-database.hmModules.nix-index
    nixvim.homeManagerModules.nixvim
  ];
  lib = nixos-unstable.lib;
  nixcfg = system: configurations:
    let
      pkgs = syspkgs { inherit system; };
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
        {
          home-manager = {
            extraSpecialArgs = specialArgs;
            sharedModules = homemodules;
          };
        }
      ] ++ configurations;
    };
  darwincfg = system: configurations:
    let
      pkgs = syspkgs { inherit system; };
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
            sharedModules = homemodules;
          };
        }
      ] ++ configurations;
    };
  homecfg = system: configurations:
    let
      pkgs = syspkgs { inherit system; };
      specialArgs = inputs // { inherit system; };
    in
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = specialArgs;
      modules = configurations ++ homemodules;
    };
in
{
  darwinConfigurations = {
    FQ-M-4CP7WX04 = darwincfg "aarch64-darwin" [ ./FQ-M-4CP7WX04 ];
    MacBook-Pro = darwincfg "aarch64-darwin" [ ./MacBook-Pro.nix ];
    MacMini-Intel = darwincfg "x86_64-darwin" [ ./MacMini-Intel.nix ];
    MacMini-M1 = darwincfg "aarch64-darwin" [ ./MacMini-M1.nix ];
  };
  homeManagerConfigurations."deck@steamdeck" = homecfg "x86_64-linux" [ ./steamdeck.nix ];
  nixosConfigurations = {
    HP-Envy = nixcfg "x86_64-linux" [ ./HP-Envy.nix ];
    HP-ZBook = nixcfg "x86_64-linux" [ ./HP-ZBook.nix ];
    MacBook-Pro-Nixos = nixcfg "aarch64-linux" [ ./MacBook-Pro-Nixos.nix apple-silicon-support.nixosModules.apple-silicon-support ];
    ncase = nixcfg "x86_64-linux" [ ./ncase ];
    PineBook-Pro = nixcfg "aarch64-linux" [ ./PineBook-Pro.nix nixos-hardware.nixosModules.pine64-pinebook-pro ];
    Protectli = nixcfg "x86_64-linux" [ ./Protectli.nix ];
    rpi4b4a = nixcfg "aarch64-linux" [ ./rpi4b4a.nix ];
    rpi4b8a = nixcfg "aarch64-linux" [ ./rpi4b8a.nix ];
    rpi4b8b = nixcfg "aarch64-linux" [ ./rpi4b8b.nix ];
    rpi4b8c = nixcfg "aarch64-linux" [ ./rpi4b8c.nix ];
    steamdeck-nixos = nixcfg "x86_64-linux" [ ./steamdeck-nixos.nix jovian.nixosModules.jovian ];
    Thinkpad = nixcfg "x86_64-linux" [ ./Thinkpad.nix ];
    utm = nixcfg "aarch64-linux" [ ./utm.nix "${nixos-unstable}/nixos/modules/profiles/qemu-guest.nix" ];
  };
}
