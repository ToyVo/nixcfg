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
      broot
      bun
      coreutils
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
    ]
    ++ lib.optionals cfg.packages.gui.enable [
      element-desktop
      gimp
    ]
    ++ lib.optionals cfg.packages.rust.enable [
      rustup
      cargo-watch
      cargo-generate
    ];
  };
}
