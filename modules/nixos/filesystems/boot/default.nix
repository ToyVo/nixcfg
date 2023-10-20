{ lib, config, pkgs, ... }:
let
  cfg = config.cd;
in
{
  options.cd.fs.boot.enable = lib.mkEnableOption "boot partition";

  config = lib.mkIf cfg.fs.boot.enable {
    fileSystems."/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
    };
  };
}
