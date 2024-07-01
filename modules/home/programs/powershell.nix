{ config, lib, ... }:
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
    xdg.configFile."powershell/Microsoft.PowerShell_profile.ps1" = {
      text = lib.mkMerge [
        ''
          ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "[Environment]::SetEnvironmentVariable(\"${name}\", \"${toString value}\")") config.home.sessionVariables)}
          $pre_paths = [Environment]::GetEnvironmentVariable('PATH').split([IO.Path]::PathSeparator)
          $nix_paths = "${lib.concatStringsSep "\", \"" config.home.sessionPath}"
          $paths_to_export = @()
          foreach ($path in $pre_paths) {
              if (Test-Path $path -PathType Container) {
                  if ($nix_paths -notcontains $path) {
                      $paths_to_export += $path
                  }
              }
          }
          foreach ($path in $nix_paths) {
              if (Test-Path $path -PathType Container) {
                  $paths_to_export += $path
              }
          }
          [Environment]::SetEnvironmentVariable('PATH', $paths_to_export -join [IO.Path]::PathSeparator)
          ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "Function nixalias${name} { param([Parameter(ValueFromRemainingArguments=$true)] [string[]]$Arguments) ${value} $Arguments}\nSet-Alias -Name ${name} -Value nixalias${name}") config.home.shellAliases)}
          ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "Function nixalias${name} { param([Parameter(ValueFromRemainingArguments=$true)] [string[]]$Arguments) ${value} $Arguments}\nSet-Alias -Name ${name} -Value nixalias${name}") cfg.powershell.shellAliases)}
        ''
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
