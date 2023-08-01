{ lib, config, pkgs, ... }:
let
  cfg = config.cdcfg.zsh;
in
{
  options.cdcfg.zsh.enable = lib.mkEnableOption "Enable zsh" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
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
