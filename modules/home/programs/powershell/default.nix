{ lib, config, system, ... }:
let
  cfg = config.programs;
  starship = config.programs.starship;
  zoxide = config.programs.zoxide;
in
{
  options.programs = {
    powershell = {
      enable = lib.mkEnableOption "Whether to enable PowerShell.";
      profileExtra = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Extra content to add to the PowerShell profile.";
      };
      shellAliases = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        example = { ll = "ls -l"; };
        description = ''
          An attribute set that maps aliases (the top level attribute names in
          this option) to command strings or directly to build outputs.
        '';
      };
    };
    starship.enablePowerShellIntegration = lib.mkEnableOption "Whether to enable PowerShell integration." // {
      default = true;
    };
    zoxide.enablePowerShellIntegration = lib.mkEnableOption "Whether to enable PowerShell integration." // {
      default = true;
    };
  };

  config = lib.mkIf cfg.powershell.enable {
    xdg.configFile."powershell/Microsoft.PowerShell_profile.ps1" = lib.mkIf (cfg.starship.enable && cfg.starship.enablePowerShellIntegration) {
      text = lib.mkMerge [
        (''
          $PATH = [Environment]::GetEnvironmentVariable("HOME") + "/.local/bin" + [IO.Path]::PathSeparator `
          + "/run/wrappers/bin" + [IO.Path]::PathSeparator `
          + [Environment]::GetEnvironmentVariable("HOME") + "/.nix-profile/bin" + [IO.Path]::PathSeparator `
          + "/nix/profile/bin" + [IO.Path]::PathSeparator `
          + [Environment]::GetEnvironmentVariable("HOME") + "/.local/state/nix/profile/bin" + [IO.Path]::PathSeparator `
          + "/etc/profiles/per-user/" + [Environment]::GetEnvironmentVariable("USER") + "/bin" + [IO.Path]::PathSeparator `
          + "/nix/var/nix/profiles/default/bin" + [IO.Path]::PathSeparator `
          + "/run/current-system/sw/bin" + [IO.Path]::PathSeparator `'')
        (lib.mkIf (system == "aarch64-darwin") ''
          + "/opt/homebrew/bin" + [IO.Path]::PathSeparator `
          + "/opt/homebrew/sbin" + [IO.Path]::PathSeparator `'')
        # TODO: should only be set if not nixos
        (''
          + "/usr/local/bin" + [IO.Path]::PathSeparator `
          + "/usr/bin" + [IO.Path]::PathSeparator `
          + "/usr/sbin" + [IO.Path]::PathSeparator `
          + "/bin" + [IO.Path]::PathSeparator `
          + "/sbin"
          [Environment]::SetEnvironmentVariable("PATH", $PATH)
        '')
        (lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "Function nixalias${name} {${value}}\nSet-Alias -Name ${name} -Value nixalias${name}") cfg.powershell.shellAliases))
        (lib.mkIf (starship.enable && starship.enablePowerShellIntegration) ''
          Invoke-Expression (&starship init powershell)
        '')
        (lib.mkIf (zoxide.enable && zoxide.enablePowerShellIntegration) ''
          Invoke-Expression (& { (zoxide init powershell | Out-String) })
        '')
        cfg.powershell.profileExtra
      ];
    };
  };
}