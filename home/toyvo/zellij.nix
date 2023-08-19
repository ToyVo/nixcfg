{ lib, config, pkgs, ... }:
let
  cfg = config.cdcfg.zellij;
in
{
  options.cdcfg.zellij.enable = lib.mkEnableOption "Enable zellij" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    programs.zsh.initExtra = ''
      if [ -z "$SSH_TTY" ] && [ -z "$SSH_CLIENT" ] && [ -z "$SSH_CONNECTION" ] && \
          ([ -z "$TERMINAL_EMULATOR" ] || [ "$TERMINAL_EMULATOR" != "JetBrains-JediTerm" ]) && \
          ([ -z "$TERM_PROGRAM" ] || [ "$TERM_PROGRAM" != "vscode" ]); then
        eval "$(zellij setup --generate-auto-start zsh)"
      fi
    '';
    programs.zellij = {
      enable = true;
      settings = {
        themes = {
          everforest-dark = {
            bg = "#2b3339";
            fg = "#d3c6aa";
            black = "#4b565c";
            red = "#e67e80";
            green = "#a7c080";
            yellow = "#dbbc7f";
            blue = "#7fbbb3";
            magenta = "#d699b6";
            cyan = "#83c092";
            white = "#d3c6aa";
            orange = "#FF9E64";
          };
        };

        theme = "everforest-dark";
      };
    };
  };
}
