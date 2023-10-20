{ lib, config, ... }:
let
  cfg = config.cdcfg.helix;
in
{
  options.cdcfg.helix.enable = lib.mkEnableOption "Enable helix" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    programs.helix = {
      enable = true;
      settings = {
        theme = "gruvbox";
        editor = {
          line-number = "relative";
          bufferline = "always";
        };
      };
    };
  };
}
