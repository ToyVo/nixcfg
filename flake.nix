{
  description = "Collin Diekvoss Nix Configurations";

  inputs = {
    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    apple-silicon-support.url = "github:tpwrules/nixos-apple-silicon";
    catppuccin.url = "github:catppuccin/nix";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    discord_bot.url = "github:toyvo/discord_bot";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
    mkAlias.url = "github:reckenrode/mkAlias";
    nh.url = "github:viperml/nh";
    nh_plus.url = "github:toyvo/nh_plus";
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    "nixos-24.11".url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos-wsl.url = "github:nix-community/nixos-wsl";
    nixpkgs-esp-dev.url = "github:mirrexagon/nixpkgs-esp-dev";
    nixvim.url = "github:nix-community/nixvim";
    nur.url = "github:nix-community/nur";
    nur-packages.url = "github:ToyVo/nur-packages";
    plasma-manager.url = "github:pjones/plasma-manager";
    rust-overlay.url = "github:oxalica/rust-overlay";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs =
    inputs@{
      flake-parts,
      rust-overlay,
      nixpkgs-esp-dev,
      nixos-unstable,
      devshell,
      ...
    }:
    let
      configurations = import ./systems inputs;
      import_nixpkgs =
        {
          system,
          nixpkgs ? nixos-unstable,
        }:
        import nixpkgs {
          inherit system;
          overlays = [
            (import rust-overlay)
            nixpkgs-esp-dev.overlays.default
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
        homeManagerModules.default = ./modules/home;
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
      ];
      perSystem =
        {
          config,
          pkgs,
          system,
          self',
          ...
        }:
        {
          _module.args = {
            pkgs = import_nixpkgs {
              inherit system;
            };
            pkgsStable = import_nixpkgs {
              inherit system;
              nixpkg = inputs.nixos;
            };
          };

          formatter = pkgs.nixfmt-rfc-style;

          packages = {
            sops-unlock = pkgs.writeShellScriptBin "sops-unlock" ''
              git config --local diff.sops-decrypt.textconv "sops decrypt"
              git config --local filter.sops-binary.smudge "sops decrypt --input-type binary --output-type binary --filename-override %f /dev/stdin"
              git config --local filter.sops-binary.clean "sops encrypt --input-type binary --output-type binary --filename-override %f /dev/stdin"
              git config --local filter.sops-binary.required "true"
              git config --local filter.sops-env.smudge "sops decrypt --input-type env --output-type env --filename-override %f /dev/stdin"
              git config --local filter.sops-env.clean "sops encrypt --input-type env --output-type env --filename-override %f /dev/stdin"
              git config --local filter.sops-env.required "true"
              git config --local filter.sops-ini.smudge "sops decrypt --input-type ini --output-type ini --filename-override %f /dev/stdin"
              git config --local filter.sops-ini.clean "sops encrypt --input-type ini --output-type ini --filename-override %f /dev/stdin"
              git config --local filter.sops-ini.required "true"
              git config --local filter.sops-json.smudge "sops decrypt --input-type json --output-type json --filename-override %f /dev/stdin"
              git config --local filter.sops-json.clean "sops encrypt --input-type json --output-type json --filename-override %f /dev/stdin"
              git config --local filter.sops-json.required "true"
              git config --local filter.sops-yaml.smudge "sops decrypt --input-type yaml --output-type yaml --filename-override %f /dev/stdin"
              git config --local filter.sops-yaml.clean "sops encrypt --input-type yaml --output-type yaml --filename-override %f /dev/stdin"
              git config --local filter.sops-yaml.required "true"
              rm secrets/secrets.nix
              git checkout secrets/secrets.nix
            '';
            sops-lock = pkgs.writeShellScriptBin "sops-lock" ''
              git config --local --unset diff.sops-decrypt.textconv
              git config --local --unset filter.sops-binary.smudge
              git config --local --unset filter.sops-binary.clean
              git config --local --unset filter.sops-binary.required
              git config --local --unset filter.sops-env.smudge
              git config --local --unset filter.sops-env.clean
              git config --local --unset filter.sops-env.required
              git config --local --unset filter.sops-ini.smudge
              git config --local --unset filter.sops-ini.clean
              git config --local --unset filter.sops-ini.required
              git config --local --unset filter.sops-json.smudge
              git config --local --unset filter.sops-json.clean
              git config --local --unset filter.sops-json.required
              git config --local --unset filter.sops-yaml.smudge
              git config --local --unset filter.sops-yaml.clean
              git config --local --unset filter.sops-yaml.required
              rm secrets/secrets.nix
              git checkout secrets/secrets.nix
            '';
            sops-ssh-to-age = pkgs.writeShellScriptBin "sops-ssh-to-age" ''
              private_key="$(${pkgs.ssh-to-age}/bin/ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key)"
              public_key="$(${pkgs.ssh-to-age}/bin/ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub)"
              destination="$HOME/${
                if pkgs.stdenv.isDarwin then "Library/Application Support" else ".config"
              }/sops/age/keys.txt"
              echo "# created: $(date -I seconds)" > "$destination"
              echo "# public key: $public_key" >> "$destination"
              echo "$private_key" >> "$destination"
              echo "$public_key"
            '';
          };

          devshells.default.commands = [
            {
              package = self'.packages.sops-unlock;
              help = "unlock secrets that can be unencrypted on disk";
            }
            {
              package = self'.packages.sops-lock;
              help = "lock secrets that can be unencrypted on disk";
            }
            {
              package = self'.packages.sops-ssh-to-age;
              help = "convert ssh host key to age and place it in the default sops location for editing";
            }
          ];
        };
    };

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://cosmic.cachix.org"
      "https://toyvo.cachix.org"
      "https://eigenvalue.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
      "toyvo.cachix.org-1:s++CG1te6YaS9mjICre0Ybbya2o/S9fZIyDNGiD4UXs="
      "eigenvalue.cachix.org-1:ykerQDDa55PGxU25CETy9wF6uVDpadGGXYrFNJA3TUs="
    ];
  };
}
