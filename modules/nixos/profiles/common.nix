{ config, lib, inputs, system, ... }:
let
  cfg = config.profiles;
  pkgs = import inputs.nixpkgs {
    inherit system;
    overlays = [ (import inputs.rust-overlay) ];
    config.allowUnfree = true;
  };
  myPython = pkgs.python311.withPackages (ps: with ps; [
    pip
    virtualenv
    python-dotenv
    jupyter
    pandas
    pipx
    numpy
  ] ++ config.environment.pythonPackages);
  fontPackages = with pkgs; [
    noto-fonts
    noto-fonts-lgc-plus
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    noto-fonts-emoji-blob-bin
    noto-fonts-monochrome-emoji
    monaspace
    (nerdfonts.override { fonts = [ "Monaspace" "NerdFontsSymbolsOnly" ]; })
  ];
in
{
  options = {
    profiles = {
      gui.enable = lib.mkEnableOption "GUI Applications";
      defaults.enable = lib.mkEnableOption "Enable Defaults";
    };
    environment.pythonPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.defaults.enable {
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
      backupFileExtension = "old";
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [{
        nix.package = lib.mkForce config.nix.package;
      }];
    };
    nixpkgs.overlays = [ inputs.rust-overlay.overlays.default ];
    fonts =
      if pkgs.stdenv.isLinux then {
        packages = fontPackages;
      } else {
        fontDir.enable = true;
        fonts = fontPackages;
      };
    environment =
      let
        shells = with pkgs; [
          bashInteractive
          zsh
          fish
          nushell
          powershell
        ];
      in
      {
        inherit shells;
        systemPackages = with pkgs; [
          # Utilities
          uutils-coreutils-noprefix
          curl
          wget
          dig
          dogdns
          fd
          gping
          jq
          ripgrep
          rsync
          lsof
          sqlite
          broot
          helix
          openssh
          openssl
          nixpkgs-fmt
          git-crypt
          nix-output-monitor
          dotnet-sdk_8
          ### Javascript
          bun
          deno
          nodejs
          ### Rust
          (rust-bin.selectLatestNightlyWith (toolchain: toolchain.default.override {
            extensions = [ "rust-src" "rust-std" "rust-analyzer" "rustfmt" "clippy" ];
            targets = [ "wasm32-unknown-unknown" ];
          }))
          dioxus-cli
          cargo-watch
          cargo-generate
          ### Python
          poetry
          pipenv
          myPython
          ### Containers
          podman
          podman-compose
          kubectl
          ### Compression
          xz
          zstd
          zip
          unzip
          gzip
          gnutar
        ]
        ++ lib.optionals cfg.gui.enable [
          gimp
        ]
        ++ shells
        ++ lib.optionals stdenv.isLinux [
          yubikey-manager
          yubikey-personalization
          yubico-piv-tool
          aha
          pciutils
          clinfo
          glxinfo
          vulkan-tools
          fwupd
        ]
        ++ lib.optionals (stdenv.isLinux && cfg.gui.enable) [
          floorp
          neovide
          yubikey-manager-qt
          yubioath-flutter
          element-desktop
        ]
        ++ lib.optionals stdenv.isDarwin [
          rectangle
          utm
          pinentry_mac
          warp-terminal
          appcleaner
        ];
      };
  };
}
