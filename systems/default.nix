{
  apple-silicon-support,
  arion,
  catppuccin,
  discord_bot,
  disko,
  home-manager,
  jovian,
  mac-app-util,
  nh,
  nix-darwin,
  nix-index-database,
  nixos-hardware,
  nixos-wsl,
  nixpkgs,
  nixpkgs-esp-dev,
  nur,
  nur-packages,
  nvf,
  plasma-manager,
  rust-overlay,
  self,
  sops-nix,
  ...
}@inputs:
let
  sharedHomeModules = [
    catppuccin.homeModules.catppuccin
    nh.homeManagerModules.default
    nix-index-database.hmModules.nix-index
    nur.modules.homeManager.default
    nvf.homeManagerModules.nvf
    self.homeModules.default
    sops-nix.homeManagerModules.sops
    {
      nixpkgs = {
        overlays = [
          (import rust-overlay)
          nixpkgs-esp-dev.overlays.default
          nur-packages.overlays.default
        ];
        config = {
          allowUnfree = true;
          allowBroken = true;
        };
      };
    }
  ];
  lib = nixpkgs.lib;
  nixosSystem =
    {
      system,
      nixosModules ? [ ],
      homeModules ? [ ],
    }:
    let
      pkgs = self.lib.import_nixpkgs system;
      specialArgs = inputs // {
        inherit system;
      };
    in
    lib.nixosSystem {
      inherit system pkgs;
      specialArgs = specialArgs;
      modules = [
        arion.nixosModules.arion
        catppuccin.nixosModules.catppuccin
        discord_bot.nixosModules.discord_bot
        disko.nixosModules.disko
        home-manager.nixosModules.default
        nh.nixosModules.default
        nix-index-database.nixosModules.nix-index
        nixpkgs.nixosModules.notDetected
        nur.modules.nixos.default
        self.nixosModules.default
        sops-nix.nixosModules.sops
        {
          home-manager = {
            extraSpecialArgs = specialArgs;
            sharedModules =
              homeModules ++ sharedHomeModules ++ [ plasma-manager.homeManagerModules.plasma-manager ];
          };
        }
      ] ++ nixosModules;
    };
  darwinSystem =
    {
      system,
      darwinModules ? [ ],
      homeModules ? [ ],
    }:
    let
      pkgs = self.lib.import_nixpkgs system;
      specialArgs = inputs // {
        inherit system;
      };
    in
    nix-darwin.lib.darwinSystem {
      inherit pkgs;
      specialArgs = specialArgs;
      modules = [
        home-manager.darwinModules.default
        mac-app-util.darwinModules.default
        nh.nixDarwinModules.prebuiltin
        nix-index-database.darwinModules.nix-index
        self.darwinModules.default
        {
          home-manager = {
            extraSpecialArgs = specialArgs;
            sharedModules =
              [
                mac-app-util.homeManagerModules.default
              ]
              ++ homeModules
              ++ sharedHomeModules;
          };
        }
      ] ++ darwinModules;
    };
  homeConfiguration =
    {
      system,
      homeModules ? [ ],
    }:
    let
      pkgs = self.lib.import_nixpkgs system;
      specialArgs = inputs // {
        inherit system;
      };
    in
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = specialArgs;
      modules = homeModules ++ sharedHomeModules;
    };
in
{
  darwinConfigurations = {
    FQ-M-4CP7WX04 = darwinSystem {
      system = "aarch64-darwin";
      darwinModules = [ ./FQ-M-4CP7WX04 ];
    };
    MacBook-Pro = darwinSystem {
      system = "aarch64-darwin";
      darwinModules = [ ./MacBook-Pro.nix ];
    };
    MacMini-Intel = darwinSystem {
      system = "x86_64-darwin";
      darwinModules = [ ./MacMini-Intel.nix ];
    };
    MacMini-M1 = darwinSystem {
      system = "aarch64-darwin";
      darwinModules = [ ./MacMini-M1.nix ];
    };
  };
  homeConfigurations = {
    "deck@steamdeck" = homeConfiguration {
      system = "x86_64-linux";
      homeModules = [
        ./steamdeck.nix
        plasma-manager.homeManagerModules.plasma-manager
      ];
    };
  };
  nixosConfigurations = {
    HP-Envy = nixosSystem {
      system = "x86_64-linux";
      nixosModules = [ ./HP-Envy.nix ];
    };
    HP-ZBook = nixosSystem {
      system = "x86_64-linux";
      nixosModules = [ ./HP-ZBook.nix ];
    };
    MacBook-Pro-Nixos = nixosSystem {
      system = "aarch64-linux";
      nixosModules = [
        ./MacBook-Pro-Nixos
        apple-silicon-support.nixosModules.apple-silicon-support
      ];
    };
    nas = nixosSystem {
      system = "x86_64-linux";
      nixosModules = [ ./nas ];
    };
    oracle-cloud-nixos = nixosSystem {
      system = "aarch64-linux";
      nixosModules = [
        ./oracle-cloud-nixos.nix
        "${nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
      ];
    };
    PineBook-Pro = nixosSystem {
      system = "aarch64-linux";
      nixosModules = [
        ./PineBook-Pro.nix
        nixos-hardware.nixosModules.pine64-pinebook-pro
      ];
    };
    Protectli = nixosSystem {
      system = "x86_64-linux";
      nixosModules = [ ./Protectli.nix ];
    };
    router = nixosSystem {
      system = "x86_64-linux";
      nixosModules = [ ./router ];
    };
    rpi4b4a = nixosSystem {
      system = "aarch64-linux";
      nixosModules = [ ./rpi4b4a.nix ];
    };
    rpi4b8a = nixosSystem {
      system = "aarch64-linux";
      nixosModules = [ ./rpi4b8a.nix ];
    };
    rpi4b8b = nixosSystem {
      system = "aarch64-linux";
      nixosModules = [ ./rpi4b8b.nix ];
    };
    rpi4b8c = nixosSystem {
      system = "aarch64-linux";
      nixosModules = [ ./rpi4b8c.nix ];
    };
    steamdeck-nixos = nixosSystem {
      system = "x86_64-linux";
      nixosModules = [
        ./steamdeck-nixos.nix
        jovian.nixosModules.jovian
      ];
    };
    Thinkpad = nixosSystem {
      system = "x86_64-linux";
      nixosModules = [ ./Thinkpad.nix ];
    };
    utm = nixosSystem {
      system = "aarch64-linux";
      nixosModules = [
        ./utm.nix
        "${nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
      ];
    };
    wsl = nixosSystem {
      system = "x86_64-linux";
      nixosModules = [
        ./wsl.nix
        nixos-wsl.nixosModules.wsl
      ];
    };
  };
}
