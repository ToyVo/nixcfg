{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    coreutils
  ];
  services.nix-daemon.enable = true;
  programs.zsh.enable = true;
  system.stateVersion = 4;
  fonts.fontDir.enable = true;
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;
  homebrew = {
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
    enable = true;
    casks = [
      "firefox"
      "alacritty"
      "neovide"
      "1password"
    ];
    masApps = {
      "Yubico Authenticator" = 1497506650;
      "Wireguard" = 1451685025;
    };
  };
}
