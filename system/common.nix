{ pkgs, config, inputs, ... }: {
  imports = [ ./neovim.nix ];
  fonts.fonts = with pkgs; [ (nerdfonts.override { fonts = [ "FiraCode" ]; }) font-awesome ];
  programs.zsh.enable = true;
  nixpkgs.config.allowUnfree = true;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  nix.settings = {
    trusted-substituters = ["https://hyprland.cachix.org" "https://nix-community.cachix.org"];
    substituters = config.nix.settings.trusted-substituters;
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
  };
  nixpkgs.overlays = [ inputs.fenix.overlays.default ];
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
    (fenix.complete.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
    ])
    rust-analyzer-nightly
  ];
}
