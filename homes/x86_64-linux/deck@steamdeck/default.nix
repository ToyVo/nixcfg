{ pkgs, lib, ... }:
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
  catppuccin = {
    flavour = lib.mkForce "latte";
    accent = lib.mkForce "pink";
  };
  profiles = {
    toyvo.enable = true;
    gui.enable = true;
  };
}
