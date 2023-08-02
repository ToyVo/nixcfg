{ pkgs, ... }: {
  imports = [ ../common ./alias-system-apps.nix ];
  services.nix-daemon.enable = true;
  security.pam.enableSudoTouchIdAuth = true;
  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [ (nerdfonts.override { fonts = [ "FiraCode" ]; }) font-awesome ];
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
    { name = "firefox"; greedy = true; }
    { name = "brave-browser"; greedy = true; }
    { name = "jetbrains-toolbox"; greedy = true; }
    { name = "insomnia"; greedy = true; }
    { name = "libreoffice"; greedy = true; }
    { name = "keybase"; greedy = true; }
    { name = "grammarly"; greedy = true; }
    # nix package doesn't provide an app bundle
    { name = "neovide"; greedy = true; }
    # must be installed at /Applications, nix-darwin installs it at /Applications/nix apps
    { name = "1password"; greedy = true; }
  ];
  homebrew.brews = [
    # required for neovide
    "libuv"
  ];
  home-manager.sharedModules = [ ./alias-home-apps.nix ];
}
