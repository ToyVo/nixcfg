{ lib, config, pkgs, ... }:
let
  cfg = config.cdcfg.eza;
in
{
  options.cdcfg.eza.enable = lib.mkEnableOption "Enable eza" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    programs.eza = {
      enable = true;
      enableAliases = true;
    };
    home.shellAliases = {
      tree = "eza --tree";
    };
  };
}
