{ lib, config, pkgs, ... }:
let
  cfg = config.cdcfg.fs.boot;
in
{
  options.cdcfg.fs.boot.enable = lib.mkEnableOption "boot partition";

  config = lib.mkIf (pkgs.stdenv.isLinux && cfg.enable) {
    fileSystems."/boot" =
      {
        device = "/dev/disk/by-label/BOOT";
        fsType = "vfat";
      };
  };
}
