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
    programs = {
      git.enable = true;
      gpg.enable = true;
      ssh.enable = true;
    };
    catppuccin = {
      flavour = "latte";
      accent = "pink";
    };
  };
}


