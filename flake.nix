{
  description = "Collin Diekvoss Nix Configurations";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://toyvo.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "toyvo.cachix.org-1:s++CG1te6YaS9mjICre0Ybbya2o/S9fZIyDNGiD4UXs="
    ];
  };

  inputs = {
    apple-silicon-support.url = "github:tpwrules/nixos-apple-silicon";
    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    discord_bot.url = "github:toyvo/discord_bot";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
    mac-app-util.url = "github:hraban/mac-app-util";
    nh.url = "github:toyvo/nh";
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-wsl.url = "github:nix-community/nixos-wsl";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-esp-dev.url = "github:mirrexagon/nixpkgs-esp-dev";
    nur-packages.url = "github:ToyVo/nur-packages";
    nur.url = "github:nix-community/nur";
    nvf.url = "github:NotAShelf/nvf";
    plasma-manager.url = "github:pjones/plasma-manager";
    rust-overlay.url = "github:oxalica/rust-overlay";
    sops-nix.url = "github:Mic92/sops-nix";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    inputs@{
      devshell,
      flake-parts,
      nixpkgs,
      nixpkgs-esp-dev,
      nur-packages,
      rust-overlay,
      treefmt-nix,
      self,
      ...
    }:
    let
      configurations = import ./systems inputs;
      import_nixpkgs =
        system:
        import nixpkgs {
          inherit system;
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
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = {
        lib = {
          inherit import_nixpkgs;
        };
        nixosModules.default = ./modules/nixos;
        darwinModules.default = ./modules/darwin;
        homeModules.default = ./modules/home;
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
      imports = [
        devshell.flakeModule
        flake-parts.flakeModules.easyOverlay
        treefmt-nix.flakeModule
      ];
      perSystem =
        {
          config,
          pkgs,
          lib,
          system,
          self',
          ...
        }:
        {
          _module.args = {
            pkgs = import_nixpkgs system;
          };

          treefmt = {
            programs = {
              nixfmt = {
                enable = true;
                excludes = [
                  "secrets/*.nix"
                ];
              };
              yamlfmt.enable = true;
              jsonfmt.enable = true;
            };
          };

          packages = {
            setup-sops = pkgs.writeShellScriptBin "setup-sops" ''
              destination="$HOME/${
                if pkgs.stdenv.isDarwin then "Library/Application Support" else ".config"
              }/sops/age"
              mkdir -p "$destination"
              echo "$(${pkgs.age}/bin/age-keygen)" > "$destination/keys.txt"
              sudo mkdir -p /var/sops/age
              sudo cp "$destination/keys.txt" /var/sops/age/keys.txt
            '';
          };

          devshells.default.commands = [
            {
              package = self'.packages.setup-sops;
              help = "create an age key and place it in the default sops location for editing";
            }
          ];

          checks =
            with nur-packages.legacyPackages.${system}.lib;
            derivationOutputs self'.packages
            // lib.mapAttrs' (n: lib.nameValuePair "devShells-${n}") (
              lib.filterAttrs (n: v: isCacheable v) self'.devShells
            )
            //
              lib.mapAttrs'
                (
                  n: v:
                  (lib.nameValuePair "homeConfigurations-${n}") (
                    self.homeConfigurations."${n}".config.home.activationPackage
                  )
                )
                (
                  lib.filterAttrs (
                    n: v: self.homeConfigurations."${n}".pkgs.stdenv.system == system
                  ) self.homeConfigurations
                )
            //
              lib.mapAttrs'
                (
                  n: v:
                  (lib.nameValuePair "nixosConfigurations-${n}") (
                    self.nixosConfigurations."${n}".config.system.build.toplevel
                  )
                )
                (
                  lib.filterAttrs (
                    n: v: self.nixosConfigurations."${n}".pkgs.stdenv.system == system
                  ) self.nixosConfigurations
                )
            //
              lib.mapAttrs'
                (
                  n: v:
                  (lib.nameValuePair "darwinConfigurations-${n}") (
                    self.darwinConfigurations."${n}".config.system.build.toplevel
                  )
                )
                (
                  lib.filterAttrs (
                    n: v: self.darwinConfigurations."${n}".pkgs.stdenv.system == system
                  ) self.darwinConfigurations
                );
        };
    };
}
