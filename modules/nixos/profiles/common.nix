{ config, lib, inputs, system, ... }:
let
  pkgs = import inputs.nixpkgs {
    inherit system;
    overlays = [ (import inputs.rust-overlay) ];
  };
  myPython = pkgs.python311.withPackages (ps: with ps; [
    pip
    virtualenv
    python-dotenv
    jupyter
  ] ++ config.environment.pythonPackages);
in
{
  options = {
    profiles = {
      gui.enable = lib.mkEnableOption "GUI Applications";
      defaults.enable = lib.mkEnableOption "Enable Defaults";
    };
    environment.pythonPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
    };
  };

  config = lib.mkIf config.profiles.defaults.enable {
    programs = {
      zsh.enable = true;
      fish.enable = true;
      nh = {
        enable = true;
        flake = "${config.users.users.${config.userPresets.toyvo.name}.home}/nixcfg";
        clean.enable = true;
      };
    };
    nix = {
      package = pkgs.nixVersions.nix_2_19;
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        substituters = config.nix.settings.trusted-substituters;
        trusted-substituters = [
          "https://nix-community.cachix.org"
          "https://hyprland.cachix.org"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        ];
      };
      nixPath = [ "nixpkgs=${inputs.nixpkgs-unstable}" "nixos=${inputs.nixos-unstable}" ];
    };
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
    nixpkgs.overlays = [ inputs.rust-overlay.overlays.default ];
    environment = let
      shells = with pkgs; [
        bashInteractive
        zsh
        fish
        nushell
        powershell
      ];
    in {
      inherit shells;
      systemPackages = with pkgs; [
        uutils-coreutils-noprefix
        sqlite
        broot
        bun
        deno
        nodejs
        curl
        dig
        dogdns
        fd
        gping
        helix
        lsof
        openssh
        ripgrep
        rsync
        wget
        jq
        nixpkgs-fmt
        git-crypt
        (rust-bin.selectLatestNightlyWith (toolchain: toolchain.default.override {
          extensions = [ "rust-src" "rust-std" ];
          targets = [ "wasm32-unknown-unknown" ];
        }))
        dioxus-cli
        rust-analyzer
        cargo-watch
        cargo-generate
        xz
        zstd
        pipenv
        myPython
        dotnet-sdk_8
        podman
        podman-compose
        kubectl
      ]
      ++ lib.optionals config.profiles.gui.enable [
        gimp
      ]
      ++ shells;
    };
  };
}
