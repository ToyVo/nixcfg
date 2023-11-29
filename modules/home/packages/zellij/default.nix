{ lib, config, pkgs, ... }:
let
  cfg = config.cd;
in
{
  options.cd.packages.zellij.enable = lib.mkEnableOption "Enable zellij";

  config = lib.mkIf cfg.packages.zellij.enable {
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
    programs.nushell.configFile.text = ''
      if "ZELLIJ" not-in $env and "SSH_TTY" not-in $env and "SSH_CLIENT" not-in $env and "SSH_CONNECTION" not-in $env and $env.TERMINAL_EMULATOR? != "JetBrains-JediTerm" and $env.TERM_PROGRAM? != "vscode" {
        if $env.ZELLIJ_AUTO_ATTACH? == "true" {
          ${pkgs.zellij}/bin/zellij options --default-shell ${pkgs.nushell}/bin/nu attach -c 
        } else {
          ${pkgs.zellij}/bin/zellij options --default-shell ${pkgs.nushell}/bin/nu
        }

        if $env.ZELLIJ_AUTO_EXIT? == "true" {
          exit
        }
      }
    '';
  };
}
