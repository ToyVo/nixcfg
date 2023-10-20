{ lib, config, pkgs, ... }:
let
  cfg = config.cd;
in
{
  options.cd.packages.zsh.enable = lib.mkEnableOption "Enable zsh" // {
    default = true;
  };

  config = lib.mkIf cfg.packages.zsh.enable {
    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      syntaxHighlighting.enable = true;
      defaultKeymap = "viins";
      initExtra = ''
        setopt globdots
        zstyle ':completion:*' matcher-list ''' '+m:{a-zA-Z}={A-Za-z}' '+r:|[._-]=* r:|=*' '+l:|=* r:|=*'
      '';
    };
  };
}
