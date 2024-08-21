{ config, lib, pkgs, ... }:
let
  cfg = config.profiles;
in
{
  options.profiles.chloe.enable = lib.mkEnableOption "Enable chloe profile";

  config = lib.mkIf cfg.chloe.enable {
    home.packages = with pkgs; [
      spotify
      discord
    ];
    catppuccin = {
      flavor = "latte";
      accent = "pink";
    };
  };
}


