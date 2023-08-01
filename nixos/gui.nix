{ lib, config, pkgs, ... }:
let
  cfg = config.cdcfg;
in
{
  config = lib.mkIf (cfg.gnome.enable || cfg.xfce.enable || cfg.hyprland.enable) {
    cdcfg.gui.enable = lib.mkDefault true;
    services.printing.enable = true;
    security.rtkit.enable = true;
    hardware.pulseaudio.enable = false;
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
      yubikey-personalization-gui
      yubioath-flutter
    ]
    ++ lib.optionals (system == "x86_64-linux") [ keybase-gui ];
  };
}
