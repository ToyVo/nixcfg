{ lib, config, pkgs, ... }:
let
  cfg = config.cd;
in
{
  config = lib.mkIf (cfg.gnome.enable || cfg.xfce.enable || cfg.hyprland.enable || cfg.plasma.enable || cfg.plasma.mobile.enable) {
    cd.packages.gui.enable = lib.mkDefault true;

    services.printing.enable = true;
    security.rtkit.enable = true;
    hardware.pulseaudio.enable = lib.mkForce false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    environment.systemPackages = with pkgs; [
      firefox
      neovide
      _1password
      _1password-gui
      yubikey-manager-qt
      yubioath-flutter
    ];
    fonts.packages = with pkgs; [ (nerdfonts.override { fonts = [ "FiraCode" ]; }) font-awesome ];
  };
}
