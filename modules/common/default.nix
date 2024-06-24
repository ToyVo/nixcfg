{ config, lib, nixos-unstable, pkgs, rust-overlay, self, ... }:
let
  cfg = config.profiles;
in
{
  imports = [ ./users ];

  options = {
    profiles = {
      gui.enable = lib.mkEnableOption "GUI Applications";
      defaults.enable = lib.mkEnableOption "Enable Defaults";
      dev.enable = lib.mkEnableOption "Development Programs to be available outside of a devshell";
    };
    environment.pythonPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.python311.withPackages (ps: with ps; [
        jupyter
        numpy
        pandas
        pip
        pipx
        pygraphviz
        python-dotenv
        virtualenv
      ] ++ config.environment.pythonPackages);
    };
    environment.pythonPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
    };
  };


  config = lib.mkMerge [
    (lib.mkIf (cfg.dev.enable || cfg.gui.enable) {
      profiles.defaults.enable = lib.mkDefault true;
    })
    (lib.mkIf cfg.defaults.enable {
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
        package = pkgs.nixVersions.nix_2_22;
        settings = {
          experimental-features = [ "nix-command" "flakes" ];
          substituters = config.nix.settings.trusted-substituters;
          trusted-substituters = [
            "https://nix-community.cachix.org"
          ];
          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
        };
        nixPath = [ "nixpkgs=${nixos-unstable}" "nixos=${nixos-unstable}" ];
      };
      home-manager = {
        backupFileExtension = "${toString self.sourceInfo.lastModified}.old";
        useGlobalPkgs = true;
        useUserPackages = true;
        sharedModules = [{
          nix.package = lib.mkForce config.nix.package;
        }];
      };
      nixpkgs.overlays = [ rust-overlay.overlays.default ];
      fonts.packages = with pkgs; [
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
      environment =
        let
          shells = with pkgs; [
            bashInteractive
            fish
            nushell
            powershell
            zsh
          ];
        in
        {
          inherit shells;
          systemPackages = with pkgs; [
            broot
            curl
            dig
            dogdns
            dotnet-sdk_8
            fd
            git-crypt
            gnutar
            gping
            graphviz
            gzip
            helix
            jq
            just
            kubectl
            lsof
            netcat
            nix-output-monitor
            nixpkgs-fmt
            nmap
            openssh
            openssl
            podman
            podman-compose
            ripgrep
            rsync
            sqlite
            tlrc
            unzip
            uutils-coreutils-noprefix
            wget
            xz
            zip
            zstd
          ]
          ++ shells
          ++ lib.optionals cfg.gui.enable [
            gimp
          ]
          ++ lib.optionals cfg.dev.enable [
            bison
            bun
            cargo-generate
            cargo-watch
            ccache
            cmake
            config.environment.pythonPackage
            deno
            dfu-util
            dioxus-cli
            flex
            gnumake
            gperf
            libffi
            libiconv
            libusb1
            ninja
            nodejs
            pipenv
            poetry
            (rust-bin.selectLatestNightlyWith (toolchain: toolchain.default.override {
              extensions = [ "rust-src" "rust-std" "rust-analyzer" "rustfmt" "clippy" ];
              targets = [
                "wasm32-unknown-unknown"
                "riscv32imc-unknown-none-elf"
              ];
            }))
          ]
          ++ lib.optionals (stdenv.isLinux && cfg.dev.enable) [
            # Having gcc or clang will also set cc, which breaks compiling rust on macos, to ivestigate
            gcc
            clang
          ]
          ++ lib.optionals stdenv.isLinux [
            aha
            clinfo
            fwupd
            glxinfo
            pciutils
            vulkan-tools
            wayland-utils
            yubico-piv-tool
            yubikey-manager
            yubikey-personalization
          ]
          ++ lib.optionals (stdenv.isLinux && cfg.gui.enable) [
            element-desktop
            floorp
            neovide
            yubikey-manager-qt
            yubioath-flutter
          ]
          ++ lib.optionals stdenv.isDarwin [
            appcleaner
            pinentry_mac
            rectangle
            utm
            warp-terminal
          ];
        };
    })
  ];
}
