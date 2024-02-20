{ lib, config, pkgs, ... }:
let
  cfg = config.programs.zsh;
in
{
  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enableAutosuggestions = true;
      syntaxHighlighting.enable = true;
      defaultKeymap = "viins";
      initExtra = ''
        setopt globdots
        zstyle ':completion:*' matcher-list ''' '+m:{a-zA-Z}={A-Za-z}' '+r:|[._-]=* r:|=*' '+l:|=* r:|=*'
      '';
    };
    home.file.".hushlogin".text = lib.mkIf pkgs.stdenv.isDarwin "";
  };
}
