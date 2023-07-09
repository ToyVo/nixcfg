{ lib, config, ... }:
let
  cfg = config.cdcfg.fs.btrfs;
in
{
  options.cdcfg.fs.btrfs.enable = lib.mkEnableOption "root btrfs partition";

  config = lib.mkIf cfg.enable {
    fileSystems."/" =
      {
        device = "/dev/disk/by-label/NIXOS";
        fsType = "btrfs";
        options = [ "subvol=@" ];
      };

    fileSystems."/home" =
      {
        device = "/dev/disk/by-label/NIXOS";
        fsType = "btrfs";
        options = [ "subvol=@home" ];
      };

    fileSystems."/nix" =
      {
        device = "/dev/disk/by-label/NIXOS";
        fsType = "btrfs";
        options = [ "subvol=@nix" ];
      };
  };
}
