{ lib, config, pkgs, ... }:
let
  cfg = config.cd;
in
{
  options.cd.packages.eza.enable = lib.mkEnableOption "Enable eza";

  config = lib.mkIf cfg.packages.eza.enable {
    programs.eza = {
      enable = true;
      enableAliases = true;
    };
  };
}
