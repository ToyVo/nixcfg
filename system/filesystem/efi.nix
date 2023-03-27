{
  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-label/EFI";
      fsType = "vfat";
    };
}
