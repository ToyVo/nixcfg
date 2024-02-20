{ lib, config, pkgs, ... }:
let
  cfg = config.fileSystemPresets;
in
{
  options.fileSystemPresets.boot.enable = lib.mkEnableOption "boot partition";

  config = lib.mkIf cfg.boot.enable {
    fileSystems."/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
    };
  };
}
