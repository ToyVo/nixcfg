{ lib, config, pkgs, ... }:
let
  cfg = config.cd;
in
{
  options.cd.fs.sd.enable = lib.mkEnableOption "root partition";

  config = lib.mkIf cfg.fs.sd.enable {
    fileSystems."/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };
}
