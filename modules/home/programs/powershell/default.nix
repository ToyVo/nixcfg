{ lib, config, ... }:
let
  cfg = config.programs;
in
{
  options.programs = {
    powershell.enable = lib.mkEnableOption "Whether to enable PowerShell.";
    starship.enablePowerShellIntegration = lib.mkEnableOption "Whether to enable PowerShell integration." // {
      default = true;
    };
  };

  config = lib.mkIf cfg.powershell.enable {
    xdg.configFile."powershell/Microsoft.PowerShell_profile.ps1" = lib.mkIf (cfg.starship.enable && cfg.starship.enablePowerShellIntegration) {
      text = ''
        Invoke-Expression (&starship init powershell)
      '';
    };
  };
}