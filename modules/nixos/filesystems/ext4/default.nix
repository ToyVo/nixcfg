{ lib, config, pkgs, ... }:
let
  cfg = config.fileSystemPresets;
in
{
  options.fileSystemPresets = {
    sd.enable = lib.mkEnableOption "root partition";
    ext4 = {
      enable = lib.mkEnableOption "root ext4 partition";
      label = lib.mkOption {
        type = lib.types.str;
        default = "NIXOS";
        internal = true;
        visible = false;
      };
    };
  };

  config = {
    fileSystemPresets.ext4 = lib.mkIf cfg.sd.enable {
      enable = true;
      label = "NIXOS_SD";
    };

    fileSystems."/" = lib.mkIf cfg.ext4.enable {
      device = "/dev/disk/by-label/${cfg.ext4.label}";
      fsType = "ext4";
    };
  };
}
