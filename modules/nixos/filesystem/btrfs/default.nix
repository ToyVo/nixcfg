{ lib, config, ... }:
let
  cfg = config.cd;
in
{
  options.cd.fs.btrfs.enable = lib.mkEnableOption "root btrfs partition";

  config = lib.mkIf cfg.fs.btrfs.enable {
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
