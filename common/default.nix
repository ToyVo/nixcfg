{ pkgs, config, lib, inputs, ... }:
let
  cfg = config.cdcfg;
in
{
  imports = [ ./neovim.nix ];

  options.cdcfg.packages.gui.enable = lib.mkEnableOption "GUI Applications" // {
    default = true;
  };

  options.cdcfg.packages.rust.enable = lib.mkEnableOption "Rust toolchain" // {
    default = true;
  };

  config = {
    fonts.fonts = with pkgs; [ (nerdfonts.override { fonts = [ "FiraCode" ]; }) font-awesome ];
    programs.zsh.enable = true;
    nixpkgs.config.allowUnfree = true;
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
    environment.systemPackages = with pkgs; [
      coreutils
      curl
      wget
      lsof
      dig
      wasmer
      deno
      bun
      nodejs_20
      ripgrep
      fd
      openssh
    ]
    ++ lib.optionals cfg.packages.gui.enable [
      gimp
      element-desktop
    ]
    ++ lib.optionals cfg.packages.rust.enable [
      cargo-watch
      rust-analyzer
      (rust-bin.selectLatestNightlyWith
        (toolchain: toolchain.default.override {
          extensions = [ "rust-src" ];
        }))
    ];
    nixpkgs.overlays = [ ]
    ++ lib.optionals cfg.packages.rust.enable [
      inputs.rust-overlay.overlays.default
    ];
  };
}
