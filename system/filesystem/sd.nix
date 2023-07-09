{ lib, config, ... }:
let
  cfg = config.cdcfg.fs.sd;
in
{
  options.cdcfg.fs.sd.enable = lib.mkEnableOption "nixos sd card partition";

  config = lib.mkIf cfg.enable {
    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
        options = [ "noatime" ];
      };
    };
  };
}
