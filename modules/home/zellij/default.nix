{ lib, config, pkgs, ... }:
let
  cfg = config.cd;
in
{
  options.cd.zellij.enable = lib.mkEnableOption "Enable zellij" // {
    default = true;
  };

  config = lib.mkIf cfg.zellij.enable {
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
        theme = "gruvbox-dark";
      };
    };
  };
}
