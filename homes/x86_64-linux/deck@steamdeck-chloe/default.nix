{ pkgs, ... }:
{
  home = {
    username = "deck";
    homeDirectory = "/home/deck";
    packages = with pkgs; [
      r2modman
      (pkgs.wrapOBS {
        plugins = with pkgs.obs-studio-plugins; [
          obs-gstreamer
          obs-vkcapture
          obs-vaapi
        ];
      })
    ];
  };
  programs.kde.catppuccin.link = true;
  gtk.catppuccin.link = true;
  profiles = {
    chloe.enable = true;
    gui.enable = true;
  };
}