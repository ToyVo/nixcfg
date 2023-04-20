{ pkgs, ... }:
{
  imports = [
    ./common.nix
  ];
  environment.systemPackages = with pkgs; [
    coreutils
  ];
  services.nix-daemon.enable = true;
  security.pam.enableSudoTouchIdAuth = true;
  fonts.fontDir.enable = true;
  system = {
    stateVersion = 4;
    keyboard.enableKeyMapping = true;
    keyboard.remapCapsLockToControl = true;
  };
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
  };
  homebrew.casks = [
    "firefox"
    "neovide"
    "1password"
    "jetbrains-toolbox"
    "rectangle"
    "insomnia"
    "gimp"
    "wezterm"
    "libreoffice"
  ];
  homebrew.masApps = {
    "Yubico Authenticator" = 1497506650;
    "Wireguard" = 1451685025;
  };
}
