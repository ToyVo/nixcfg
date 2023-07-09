{ lib, config, ... }:
let
  cfg = config.cdcfg.fs.efi;
in
{
  options.cdcfg.fs.efi.enable = lib.mkEnableOption "efi partition";

  config = lib.mkIf cfg.enable {
    fileSystems."/boot/efi" =
      {
        device = "/dev/disk/by-label/EFI";
        fsType = "vfat";
      };
  };
}
