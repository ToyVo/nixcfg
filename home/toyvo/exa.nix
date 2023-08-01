{ lib, config, pkgs, ... }:
let
  cfg = config.cdcfg.exa;
in
{
  options.cdcfg.exa.enable = lib.mkEnableOption "Enable exa" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    programs.exa = {
      enable = true;
      enableAliases = true;
    };
    home.shellAliases = {
      tree = "exa --tree";
    };
  };
}
