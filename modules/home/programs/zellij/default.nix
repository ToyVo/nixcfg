{ lib, config, pkgs, ... }:
let
  cfg = config.programs.zellij;
in
{
  config = lib.mkIf cfg.enable {
    programs.zellij = {
      settings = {
        theme = "gruvbox-dark";
      };
    };
    programs = {
      # extension of zellij setup --generate-auto-start $SHELL because the code generated doesn't start zellij with a window with the shell that started it, but the default shell of the user. Additionally generation doesn't support nushell
      # Don't auto start zellij within zellij, when connected via ssh, or when used as the shell within vscode or any jetbrains ides
      bash.initExtra = ''
        if [ -z "$ZELLIJ" ] && [ -z "$SSH_CONNECTION" ] && [ "$TERMINAL_EMULATOR" != "JetBrains-JediTerm" ] &&
           [ "$TERM_PROGRAM" != "vscode" ] && [ "$ZED_TERM" != "true" ] && [ "$TERM_PROGRAM" != "WarpTerminal" ]; then
          if [[ "$ZELLIJ_AUTO_ATTACH" == "true" ]]; then
            ${pkgs.zellij}/bin/zellij options --default-shell ${pkgs.zsh}/bin/bash attach -c
          else
            ${pkgs.zellij}/bin/zellij options --default-shell ${pkgs.zsh}/bin/bash
          fi

          if [[ "$ZELLIJ_AUTO_EXIT" == "true" ]]; then
            exit
          fi
        fi
      '';
      zsh.initExtra = ''
        if [ -z "$ZELLIJ" ] && [ -z "$SSH_CONNECTION" ] &&
           [ "$TERMINAL_EMULATOR" != "JetBrains-JediTerm" ] &&
           [ "$TERM_PROGRAM" != "vscode" ] &&
           [ "$ZED_TERM" != "true" ] &&
           [ "$TERM_PROGRAM" != "WarpTerminal" ]; then
          if [[ "$ZELLIJ_AUTO_ATTACH" == "true" ]]; then
            ${pkgs.zellij}/bin/zellij options --default-shell ${pkgs.zsh}/bin/zsh attach -c
          else
            ${pkgs.zellij}/bin/zellij options --default-shell ${pkgs.zsh}/bin/zsh
          fi

          if [[ "$ZELLIJ_AUTO_EXIT" == "true" ]]; then
            exit
          fi
        fi
      '';
      fish.interactiveShellInit = ''
        if not set -q ZELLIJ && not set -q SSH_CONNECTION &&
           not test "$TERMINAL_EMULATOR" = "JetBrains-JediTerm" &&
           not test "$TERM_PROGRAM" = "vscode" &&
           not test "$ZED_TERM" = "true" &&
           not test "$TERM_PROGRAM" = "WarpTerminal"
          if test "$ZELLIJ_AUTO_ATTACH" = "true"
            ${pkgs.zellij}/bin/zellij options --default-shell ${pkgs.fish}/bin/fish attach -c
          else
            ${pkgs.zellij}/bin/zellij options --default-shell ${pkgs.fish}/bin/fish
          end

          if test "$ZELLIJ_AUTO_EXIT" = "true"
            kill $fish_pid
          end
        end
      '';
      nushell.configFile.text = ''
        if "ZELLIJ" not-in $env and "SSH_CONNECTION" not-in $env and $env.TERMINAL_EMULATOR? != "JetBrains-JediTerm" and $env.TERM_PROGRAM? != "vscode" and $env.ZED_TERM? != "true" {
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
  };
}
