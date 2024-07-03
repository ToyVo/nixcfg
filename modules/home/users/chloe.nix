{ config, lib, pkgs, ... }:
let
  cfg = config.profiles;
in
{
  options.profiles = {
    chloe.enable = lib.mkEnableOption "Enable chloe profile";
  };

  config = lib.mkIf cfg.chloe.enable {
    profiles.defaults.enable = lib.mkDefault true;
    home.packages = with pkgs; [
      spotify
    ];
    catppuccin = {
      flavor = "latte";
      accent = "pink";
    };
  };
}


