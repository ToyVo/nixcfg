{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    coreutils
  ];
  services.nix-daemon.enable = true;
  programs.zsh.enable = true;
  system.stateVersion = 4;
  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;
  homebrew = {
    enable = true;
    casks = [
      "firefox"
      "alacritty"
    ];
    masApps = {
      "1Password 7" = 1333542190;
      "Yubico Authenticator" = 1497506650;
      "Wireguard" = 1451685025;
    };
  };
}
