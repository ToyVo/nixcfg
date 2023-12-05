{ pkgs, config, lib, inputs, ... }:
let
  cfg = config.cd;
in
{
  options.cd = {
    packages.gui.enable = lib.mkEnableOption "GUI Applications";
    defaults.enable = lib.mkEnableOption "Enable Defaults";
  };

  config = lib.mkIf cfg.defaults.enable {
    programs.bash.enable = true;
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
      rustup
      cargo-watch
      cargo-generate
      xz
      zstd
    ]
    ++ lib.optionals cfg.packages.gui.enable [
      element-desktop
      gimp
    ];
    cd.packages.neovim.enable = true;
  };
}
