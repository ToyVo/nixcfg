{ lib, config, pkgs, ... }:
let
  cfg = config.fileSystemPresets;
in
{
  options.fileSystemPresets.efi.enable = lib.mkEnableOption "efi partition";

  config = lib.mkIf cfg.efi.enable {
    fileSystems."/boot/efi" = {
      device = "/dev/disk/by-label/EFI";
      fsType = "vfat";
    };
    boot.loader.efi.efiSysMountPoint = "/boot/efi";
  };
}
