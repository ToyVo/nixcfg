{ lib, config, ... }:
let
  cfg = config.cdcfg;
in
{
  config = lib.mkIf (cfg.gnome.enable || cfg.xfce.enable || cfg.hyprland.enable) {
    services.printing.enable = true;
    security.rtkit.enable = true;
    hardware.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
