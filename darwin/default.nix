{ pkgs, ... }: {
  imports = [ ../common ./alias-system-apps.nix ];
  services.nix-daemon.enable = true;
  security.pam.enableSudoTouchIdAuth = true;
  fonts.fontDir.enable = true;
  system = {
    stateVersion = 4;
    keyboard.enableKeyMapping = true;
    keyboard.remapCapsLockToControl = true;
  };
  environment.systemPackages = with pkgs; [
    rectangle
    utm
    wezterm
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
    "brave-browser"
  ];
  homebrew.brews = [
    # required for neovide
    "libuv"
  ];
  home-manager.sharedModules = [ ./alias-home-apps.nix ];
}
