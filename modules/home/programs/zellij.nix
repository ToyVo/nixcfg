{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.zellij;
in
{
  options.programs.zellij.restrictedVariables = lib.mkOption {
    description = "List of environment variables that will prevent zellij from starting if they are set. This is useful for preventing zellij from starting when it is not desired, such as when used as the shell within various ides.";
    default = {
      TERMINAL_EMULATOR = [ "JetBrains-JediTerm" ];
      TERM_PROGRAM = [
        "vscode"
        "WarpTerminal"
      ];
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
      # Don't auto start zellij within zellij, when connected via ssh, or when used as the shell within ides
      bash.initExtra = ''
        if [ -z "$ZELLIJ" ] && [ -z "$SSH_CONNECTION" ] && ${
          lib.concatStringsSep " && " (
            lib.mapAttrsToList (
              name: values: lib.concatStringsSep " && " (map (v: "[ \"\$${name}\" != \"${v}\" ]") values)
            ) cfg.restrictedVariables
          )
        }; then
          ${lib.getExe pkgs.zellij} options --default-shell ${lib.getExe pkgs.bashInteractive} --session-name bash --attach-to-session true
        fi
      '';
      zsh.initExtra = ''
        if [ -z "$ZELLIJ" ] && [ -z "$SSH_CONNECTION" ] && ${
          lib.concatStringsSep " && " (
            lib.mapAttrsToList (
              name: values: lib.concatStringsSep " && " (map (v: "[ \"\$${name}\" != \"${v}\" ]") values)
            ) cfg.restrictedVariables
          )
        }; then
          ${lib.getExe pkgs.zellij} options --default-shell ${lib.getExe pkgs.zsh} --session-name zsh --attach-to-session true
        fi
      '';
      fish.interactiveShellInit = ''
        if not set -q ZELLIJ && not set -q SSH_CONNECTION && ${
          lib.concatStringsSep " && " (
            lib.mapAttrsToList (
              name: values: lib.concatStringsSep " && " (map (v: "not test \"\$${name}\" = \"${v}\"") values)
            ) cfg.restrictedVariables
          )
        }
          ${lib.getExe pkgs.zellij} options --default-shell ${lib.getExe pkgs.fish} --session-name fish --attach-to-session true
        end
      '';
      nushell.configFile.text = ''
        if "ZELLIJ" not-in $env and "SSH_CONNECTION" not-in $env and ${
          lib.concatStringsSep " and " (
            lib.mapAttrsToList (
              name: values: lib.concatStringsSep " and " (map (v: "$env.${name}? != \"${v}\"") values)
            ) cfg.restrictedVariables
          )
        } {
          ${lib.getExe pkgs.zellij} options --default-shell ${lib.getExe pkgs.nushell} --session-name nu --attach-to-session true
        }
      '';
      powershell.profileExtra = ''
        if (-not [Environment]::GetEnvironmentVariable("ZELLIJ") -and -not [Environment]::GetEnvironmentVariable("SSH_CONNECTION") -and ${
          lib.concatStringsSep " -and " (
            lib.mapAttrsToList (
              name: values:
              lib.concatStringsSep " -and " (
                map (v: "[Environment]::GetEnvironmentVariable(\"${name}\") -ne \"${v}\"") values
              )
            ) cfg.restrictedVariables
          )
        }) {
          ${lib.getExe pkgs.zellij} options --default-shell ${lib.getExe pkgs.powershell} --session-name pwsh --attach-to-session true
        }
      '';
      ion.initExtraEnd = ''
        if not exists -s ZELLIJ && not exists -s SSH_CONNECTION && ${
          lib.concatStringsSep " && " (
            lib.mapAttrsToList (
              # TODO: not checking if the variable is set to the right value because doing `test \$${name} != \"${value}\"` doesn't work because the variable might be undefined and ion doesn't seem to have order of operations with parenthese to protect it with `exists -s ${name}`
              name: values: "not exists -S ${name}"
            ) cfg.restrictedVariables
          )
        }
          ${lib.getExe pkgs.zellij} options --default-shell ${lib.getExe pkgs.ion} --session-name ion --attach-to-session true
        end
      '';
    };
  };
}
