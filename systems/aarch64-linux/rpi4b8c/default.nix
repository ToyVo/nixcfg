{ lib, pkgs, ... }: {
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  networking.hostName = "rpi4b8c";
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    loader.grub.enable = false;
    loader.generic-extlinux-compatible.enable = true;
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
  };
  cd = {
    defaults.enable = true;
    users.toyvo.enable = true;
    fs.sd.enable = true;
  };
}
