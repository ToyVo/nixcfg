{ lib, config, pkgs, ... }:
let
  cfg = config.cd;
in
{
  options.cd.packages.bash.enable = lib.mkEnableOption "Enable bash";

  config = lib.mkIf cfg.packages.bash.enable {
    programs.bash = {
      enable = true;
    };
  };
}

