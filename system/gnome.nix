{ pkgs, ... }: {
  imports = [ ./gui.nix ];
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    libinput.enable = true;
  };
  programs.gnupg.agent.pinentryFlavor = "gnome3";
  environment.systemPackages = [ pkgs.gnome.gnome-tweaks ];
}
