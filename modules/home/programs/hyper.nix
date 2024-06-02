{ config, lib, pkgs, system, ... }:
let
  cfg = config.programs.hyper;
in
{
  options.programs.hyper = {
    enable = lib.mkEnableOption "Hyper terminal emulator";
    program = lib.mkOption {
      type = lib.types.package;
      default = if (system == "x86_64-linux") then pkgs.hyper else pkgs.emptyDirectory;
    };
    config_file = lib.mkOption {
      type = lib.types.lines;
      default = ''
        module.exports = {
          config: {
            shell: '${pkgs.powershell}/bin/pwsh',
            shellArgs: ['-Nologo'],
            bell: false,
          },
        };
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [cfg.program];
    home.file.".hyper.js" = lib.mkIf pkgs.stdenv.isDarwin { text = cfg.config_file; };
    xdg.configFile."Hyper/.hyper.js" = lib.mkIf pkgs.stdenv.isLinux { text = cfg.config_file; };
  };
}
