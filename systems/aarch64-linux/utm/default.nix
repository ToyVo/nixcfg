{ lib, modulesPath ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  networking.hostName = "utm";
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [ "xhci_pci" "virtio_pci" "usbhid" "usb_storage" "sr_mod" ];
  };
  cd = {
    defaults.enable = true;
    users.toyvo.enable = true;
    fs.boot.enable = true;
    fs.ext4.enable = true;
    desktops.cosmic.enable = true;
  };
}
