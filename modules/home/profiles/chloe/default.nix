{ lib, config, ... }:
let
  cfg = config.profiles;
in
{
  options.profiles = {
    chloe.enable = lib.mkEnableOption "Enable chloe profile";
  };

  config = lib.mkIf cfg.chloe.enable {
    profiles.defaults.enable = lib.mkDefault true;
    catppuccin = {
      flavor = "latte";
      accent = "pink";
    };
  };
}


