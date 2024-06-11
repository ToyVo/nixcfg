{ lib, ... }: {
  networking.hostName = "oracle-ampere-nixos";
  boot = {
    initrd = {
      availableKernelModules = [ "usbhid" ];
    };
    loader.grub.splashImage = lib.mkForce null;
  };
  profiles.defaults.enable = true;
  userPresets.toyvo.enable = true;
}
