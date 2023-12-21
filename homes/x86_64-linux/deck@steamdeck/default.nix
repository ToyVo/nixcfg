{ pkgs, ... }:
{
    # Your configuration.
    home.username = "deck";
    home.homeDirectory = "/home/deck";
    home.stateVersion = "23.11";
    programs.home-manager.enable = true;
    home.packages = with pkgs; [
      obs-studio-plugins.obs-vkcapture
    ];
}
