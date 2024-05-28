{ config, lib, pkgs, ... }:
let
  cfg = config.programs.zellij;
in
{
  options.programs.zellij.restrictedVariables = lib.mkOption {
    description = "List of environment variables that will prevent zellij from starting if they are set. This is useful for preventing zellij from starting when it is not desired, such as when used as the shell within various ides.";
    default = {
      TERMINAL_EMULATOR = [ "JetBrains-JediTerm" ];
      TERM_PROGRAM = [ "vscode" "WarpTerminal" ];
      ZED_TERM = [ "true" ];
    };
    type = lib.types.attrsOf (lib.types.listOf lib.types.str);
  };
  config = lib.mkIf cfg.enable {
    programs.zellij = {
      settings = {
        theme = "catppuccin-${config.catppuccin.flavor}";
      };
    };
    programs = {
      # extension of zellij setup --generate-auto-start $SHELL because the code generated doesn't start zellij with a window with the shell that started it, but the default shell of the user. Additionally generation doesn't support nushell
      # Don't auto start zellij within zellij, when connected via ssh, or when used as the shell within vscode or any jetbrains ides
      bash.initExtra = ''
        if [ -z "$ZELLIJ" ] && [ -z "$SSH_CONNECTION" ] && ${lib.concatStringsSep " && " (lib.mapAttrsToList (name: values: lib.concatStringsSep " && " (map (v: "[ \"\$${name}\" != \"${v}\" ]") values)) cfg.restrictedVariables)}; then
          ${pkgs.zellij}/bin/zellij options --default-shell ${pkgs.bashInteractive}/bin/bash --session-name bash --attach-to-session true
        fi
      '';
      zsh.initExtra = ''
        if [ -z "$ZELLIJ" ] && [ -z "$SSH_CONNECTION" ] && ${lib.concatStringsSep " && " (lib.mapAttrsToList (name: values: lib.concatStringsSep " && " (map (v: "[ \"\$${name}\" != \"${v}\" ]") values)) cfg.restrictedVariables)}; then
          ${pkgs.zellij}/bin/zellij options --default-shell ${pkgs.zsh}/bin/zsh --session-name zsh --attach-to-session true
        fi
      '';
      fish.interactiveShellInit = ''
        if not set -q ZELLIJ && not set -q SSH_CONNECTION && ${lib.concatStringsSep " && " (lib.mapAttrsToList (name: values: lib.concatStringsSep " && " (map (v: "not test \"\$${name}\" = \"${v}\"") values)) cfg.restrictedVariables)}
          ${pkgs.zellij}/bin/zellij options --default-shell ${pkgs.fish}/bin/fish --session-name fish --attach-to-session true
        end
      '';
      nushell.configFile.text = ''
        if "ZELLIJ" not-in $env and "SSH_CONNECTION" not-in $env and ${lib.concatStringsSep " and " (lib.mapAttrsToList (name: values: lib.concatStringsSep " and " (map (v: "$env.${name}? != \"${v}\"") values)) cfg.restrictedVariables)} {
          ${pkgs.zellij}/bin/zellij options --default-shell ${pkgs.nushell}/bin/nu --session-name nu --attach-to-session true
        }
      '';
      powershell.profileExtra = ''
        if (-not [Environment]::GetEnvironmentVariable("ZELLIJ") -and -not [Environment]::GetEnvironmentVariable("SSH_CONNECTION") -and ${lib.concatStringsSep " -and " (lib.mapAttrsToList (name: values: lib.concatStringsSep " -and " (map (v: "[Environment]::GetEnvironmentVariable(\"${name}\") -ne \"${v}\"") values)) cfg.restrictedVariables)}) {
          ${pkgs.zellij}/bin/zellij options --default-shell ${pkgs.powershell}/bin/pwsh --session-name pwsh --attach-to-session true
        }
      '';
    };
  };
}
