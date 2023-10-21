{ lib, ... }: {
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  networking.hostName = "rpi4b8a";
  boot = {
    loader.grub.enable = false;
    loader.generic-extlinux-compatible.enable = false;
    loader.systemd-boot.enable = true;
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
  };
  cd = {
    defaults.enable = true;
    users.toyvo.enable = true;
    fs.boot.enable = true;
    fs.btrfs.enable = true;
  };
  hardware.raspberry-pi."4".fkms-3d.enable = true;
}
