{ lib, config, pkgs, ... }:
let
  cfg = config.cd;
in
{
  options.cd.fs.sd.enable = lib.mkEnableOption "root partition";
  options.cd.fs.ext4.enable = lib.mkEnableOption "root ext4 partition";
  options.cd.fs.ext4.label = lib.mkOption {
    type = lib.types.string;
    default = "NIXOS";
    internal = true;
  };

  config = {

    cd.fs.ext4 = lib.mkIf cfg.fs.sd.enable {
      enable = true;
      label = "NIXOS_SD";
    };

    fileSystems."/" = lib.mkIf cfg.fs.ext4.enable {
      device = "/dev/disk/by-label/${cfg.fs.ext4.label}";
      fsType = "ext4";
    };
  };
}
