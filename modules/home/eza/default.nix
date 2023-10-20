{ lib, config, pkgs, ... }:
let
  cfg = config.cd;
in
{
  options.cd.eza.enable = lib.mkEnableOption "Enable eza" // {
    default = true;
  };

  config = lib.mkIf cfg.eza.enable {
    programs.eza = {
      enable = true;
      enableAliases = true;
    };
  };
}
