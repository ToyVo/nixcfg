{ config, lib, pkgs, ... }:
let
  cfg = config.profiles;
in
{
  options = {
    profiles.dev.enable = lib.mkEnableOption "Development Programs to be available outside of a devshell";
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


  config = lib.mkIf cfg.dev.enable {
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
    };
    environment = {
      systemPackages = with pkgs; [
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
        neovide
        nodejs
        pipenv
        pkg-config
        poetry
        rustup
        # esp-idf-full
        # zed-editor
      ]
      ++ lib.optionals stdenv.isLinux [
        gcc
        clang
      ]
      ++ lib.optionals stdenv.isDarwin [
        darwin.apple_sdk.frameworks.SystemConfiguration
        darwin.apple_sdk.frameworks.CoreServices
      ];
    };
  };
}
