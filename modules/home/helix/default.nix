{ lib, config, ... }:
let
  cfg = config.cd;
in
{
  options.cd.helix.enable = lib.mkEnableOption "Enable helix" // {
    default = true;
  };

  config = lib.mkIf cfg.helix.enable {
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
