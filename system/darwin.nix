{ pkgs, ... }: {
  imports = [ ./common.nix ];
  services.nix-daemon.enable = true;
  security.pam.enableSudoTouchIdAuth = true;
  fonts.fontDir.enable = true;
  system = {
    stateVersion = 4;
    keyboard.enableKeyMapping = true;
    keyboard.remapCapsLockToControl = true;
  };
  environment.systemPackages = with pkgs; [
    openssh
  ];
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
    "grammarly"
    # nix package doesn't provide an app bundle
    "neovide"
    # must be installed at /Applications, nix-darwin installs it at /Applications/nix apps
    "1password"
  ];
  homebrew.brews = [
    # required for neovide
    "libuv"
  ];
  homebrew.masApps = {
    "Yubico Authenticator" = 1497506650;
    "Wireguard" = 1451685025;
  };
}
