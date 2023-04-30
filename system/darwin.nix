{ pkgs, ... }: {
  imports = [ ./common.nix ];
  environment.systemPackages = with pkgs; [ coreutils ];
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
    # nix package not available on darwin
    "firefox"
    "jetbrains-toolbox"
    "insomnia"
    "libreoffice"
    "keybase"
    # nix package doesn't provide an app bundle
    "neovide"
    # must be installed at /Applications, nix-darwin installs it at /Applications/nix apps
    "1password"
  ];
  homebrew.masApps = {
    "Yubico Authenticator" = 1497506650;
    "Wireguard" = 1451685025;
  };
}
