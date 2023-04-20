{
  imports = [ ./gui.nix ];
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    desktopManager.xfce.enable = true;
    libinput.enable = true;
  };
}
