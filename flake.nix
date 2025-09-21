{
  description = "Collin Diekvoss Nix Configurations";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://toyvo.cachix.org"
      "https://nixcache.diekvoss.net"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "toyvo.cachix.org-1:s++CG1te6YaS9mjICre0Ybbya2o/S9fZIyDNGiD4UXs="
      "nixcache.diekvoss.net:31yGqcL45nEZ73gLt569UoAopxWOfC5bactGqU9C9mI="
    ];
  };

  inputs = {
    apple-silicon-support.url = "github:tpwrules/nixos-apple-silicon";
    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    catppuccin.url = "github:catppuccin/nix";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    discord_bot.url = "github:toyvo/discord_bot";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
    mac-app-util.url = "github:hraban/mac-app-util";
    nh.url = "github:toyvo/nh";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-wsl.url = "github:nix-community/nixos-wsl";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
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
      nixpkgs-unstable,
      nixpkgs-esp-dev,
      nur,
      nur-packages,
      rust-overlay,
      treefmt-nix,
      self,
      ...
    }:
    let
      configurations = import ./systems inputs;
      import_nixpkgs =
        system: nixpkgs:
        import nixpkgs {
          inherit system;
          overlays = [
            (import rust-overlay)
            nixpkgs-esp-dev.overlays.default
            nur-packages.overlays.default
            nur.overlays.default
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
        }
        // configurations.lib;
        nixosModules.default = ./modules/nixos;
        darwinModules.default = ./modules/darwin;
        homeModules.default = ./modules/home;
        nixosConfigurations = configurations.nixosConfigurations;
        darwinConfigurations = configurations.darwinConfigurations;
        homeConfigurations = configurations.homeConfigurations;
        nixPath = (builtins.map (n: "${n}=${inputs.${n}.outPath}") (builtins.attrNames inputs));
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
            pkgs = import_nixpkgs system nixpkgs-unstable;
          };

          treefmt = {
            programs = {
              nixfmt.enable = true;
              yamlfmt.enable = true;
              jsonfmt.enable = true;
            };
          };

          packages = {
            setup-sops = pkgs.callPackage ./pkgs/setup-sops.nix { };
            setup-git-sops = pkgs.callPackage ./pkgs/setup-git-sops.nix { };
            git-sops = pkgs.callPackage ./pkgs/git-sops.nix { };
            pre-commit = pkgs.callPackage ./pkgs/pre-commit.nix { };
          };

          devshells.default = {
            commands = [
              {
                package = self'.packages.setup-sops;
              }
              {
                package = self'.packages.setup-git-sops;
              }
            ];
            imports = [ "${devshell}/extra/git/hooks.nix" ];
            git.hooks = {
              enable = true;
              pre-commit.text = self'.packages.pre-commit.text;
            };
          };

          checks =
            with nixpkgs-unstable.lib;
            with nur-packages.lib;
            flakeChecks system self'.packages
            // mapAttrs' (n: nameValuePair "devShells-${n}") (filterAttrs (n: v: isCacheable v) self'.devShells)
            //
              mapAttrs'
                (
                  n: v:
                  (nameValuePair "homeConfigurations-${n}") (
                    self.homeConfigurations."${n}".config.home.activationPackage
                  )
                )
                (
                  filterAttrs (
                    n: v: self.homeConfigurations."${n}".pkgs.stdenv.system == system
                  ) self.homeConfigurations
                )
            //
              mapAttrs'
                (
                  n: v:
                  (nameValuePair "nixosConfigurations-${n}") (
                    self.nixosConfigurations."${n}".config.system.build.toplevel
                  )
                )
                (
                  filterAttrs (
                    n: v: self.nixosConfigurations."${n}".pkgs.stdenv.system == system
                  ) self.nixosConfigurations
                )
            //
              mapAttrs'
                (
                  n: v:
                  (nameValuePair "darwinConfigurations-${n}") (
                    self.darwinConfigurations."${n}".config.system.build.toplevel
                  )
                )
                (
                  filterAttrs (
                    n: v: self.darwinConfigurations."${n}".pkgs.stdenv.system == system
                  ) self.darwinConfigurations
                );
        };
    };
}
