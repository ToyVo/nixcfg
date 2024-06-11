{ ... }: {
  networking.hostName = "oracle-ampere-nixos";
  boot = {
    initrd = {
      availableKernelModules = [ "usbhid" ];
    };
  };
  profiles.defaults.enable = true;
  userPresets.toyvo.enable = true;
}
