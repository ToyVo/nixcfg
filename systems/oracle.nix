{ pkgs, ... }: {
  networking.hostName = "instance-20240607-0002";
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_latest;
    initrd = {
      availableKernelModules = [ "virtio_pci" "virtio_scsi" "usbhid" ];
      kernelModules = [ "dm-snapshot" ];
    };
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
  profiles.defaults.enable = true;
  userPresets.toyvo.enable = true;
  fileSystemPresets.efi.enable = true;
  fileSystemPresets.btrfs.enable = true;
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/cdf6d48b-daa2-464d-9b2e-a41f7465299f";
      fsType = "xfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/662f7906-bb9b-4120-8c7a-0c25df008707";
      fsType = "xfs";
    };

    "/var/oled" = {
      device = "/dev/disk/by-uuid/939b4d81-2f26-4448-af0b-2624e3e05296";
      fsType = "xfs";
    };

    "/boot/efi" = {
      device = "/dev/disk/by-uuid/61A6-3EB9";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  };
}
