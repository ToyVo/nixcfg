{ pkgs, config, lib, inputs, system, ... }:
let
  cfg = config.cd;
  pkgs = import inputs.nixpkgs {
    inherit system;
    overlays = [ (import inputs.rust-overlay) ];
  };
in
{
  options.cd = {
    packages.gui.enable = lib.mkEnableOption "GUI Applications";
    defaults.enable = lib.mkEnableOption "Enable Defaults";
  };

  config = lib.mkIf cfg.defaults.enable {
    programs.zsh.enable = true;
    programs.fish.enable = true;
    environment.shells = with pkgs; [
      bashInteractive
      zsh
      fish
      nushell
    ];
    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';
    nix.settings = {
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
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    nixpkgs.overlays = [ inputs.rust-overlay.overlays.default ];
    environment.systemPackages = with pkgs; [
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
    ]
    ++ lib.optionals cfg.packages.gui.enable [
      element-desktop
      gimp
    ];
    cd.packages.neovim.enable = true;
  };
}
