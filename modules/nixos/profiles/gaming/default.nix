{ pkgs, lib, config, ... }:
let
  cfg = config.profiles.gaming;
in
{
  options.profiles.gaming.enable = lib.mkEnableOption "Enable various gaming programs";

  config = lib.mkIf cfg.enable {
    profiles.defaults.enable = true;
    programs = {
      steam = {
        enable = true;
        gamescopeSession.enable = true;
      };
      gamemode.enable = true;
    };
    environment.systemPackages = with pkgs; [
      discord
      heroic
      lutris
      mangohud
      prismlauncher
      protonup
      r2modman
      steam
      steamPackages.steamcmd
      (wrapOBS {
        plugins = with obs-studio-plugins; [
          obs-gstreamer
          obs-vaapi
          obs-vkcapture
        ];
      })
    ];
    home-manager.sharedModules = [{
      home.sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATH = "~/.steam/root/compatibilitytools.d";
    }];
  };
}
