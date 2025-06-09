{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles;
in
{
  options = {
    profiles.dev.enable = lib.mkEnableOption "Development Programs to be available outside of a devshell";
    environment.pythonPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.python312.withPackages (
        ps:
        with ps;
        [
          jupyter
          numpy
          pandas
          pip
          pipx
          pygraphviz
          python-dotenv
          virtualenv
        ]
        ++ config.environment.pythonPackages
      );
    };
    environment.pythonPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.dev.enable {
    virtualisation.podman.enable = true;
    environment = {
      systemPackages =
        with pkgs;
        [
          bison
          bruno
          bun
          cargo-generate
          cargo-watch
          ccache
          cmake
          config.environment.pythonPackage
          dfu-util
          dioxus-cli
          dotnet-sdk
          flex
          gnumake
          gperf
          icu
          libffi
          libiconv
          libusb1
          ninja
          nodejs
          nodePackages.prettier
          pipenv
          pkg-config
          poetry
          rustup
          systemfd
          # esp-idf-full
        ]
        ++ lib.optionals cfg.gui.enable [
          jetbrains-toolbox
          zed-editor
          code-cursor
        ]
        ++ lib.optionals stdenv.isLinux [
          gcc
          clang
        ]
        ++ lib.optionals stdenv.isDarwin [
          darwin.apple_sdk.frameworks.SystemConfiguration
          darwin.apple_sdk.frameworks.CoreServices
        ]
        ++
          lib.optionals
            (builtins.elem system [
              "aarch64-darwin"
              "aarch64-linux"
              "x86_64-linux"
            ])
            [
              deno
              neovide
            ];
    };
  };
}
