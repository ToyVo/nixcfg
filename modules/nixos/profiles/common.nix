{ pkgs, config, lib, inputs, system, ... }:
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
      nvim.enable = true;
    };
    nix = {
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
      gc = {
        automatic = true;
        options = "--delete-older-than 30d";
      };
    };
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
    nixpkgs.overlays = [ inputs.rust-overlay.overlays.default ];
    environment = {
      shells = with pkgs; [
        bashInteractive
        zsh
        fish
        nushell
        powershell
      ];
      systemPackages = with pkgs; [
        broot
        bun
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
          extensions = [ "rust-src" ];
          targets = [ "wasm32-unknown-unknown" ];
        }))
        rust-analyzer
        cargo-watch
        cargo-generate
        xz
        zstd
        pipenv
        lazygit
        powershell
        myPython
      ]
      ++ lib.optionals config.profiles.gui.enable [
        gimp
      ];
    };
    home-manager.sharedModules = [
      {
        programs = {
          # Make sure that the python package provided by nix is used instead of the system one
          bash.initExtra = ''
            export PATH="${myPython}/bin:$PATH"
          '';
          zsh.initExtra = ''
            export PATH="${myPython}/bin:$PATH"
          '';
          fish.shellInit = ''
            set PATH ${myPython}/bin $PATH
          '';
          nushell.extraEnv = ''
            $env.PATH = ($env.PATH | prepend '${myPython}/bin')
          '';
          powershell.profileExtra = ''
            $PATH = "${myPython}/bin" + [IO.Path]::PathSeparator + [Environment]::GetEnvironmentVariable("PATH")
            [Environment]::SetEnvironmentVariable("PATH", $PATH)
          '';
        };
      }
    ];
  };
}
