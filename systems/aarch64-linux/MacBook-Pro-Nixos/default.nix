{ lib, inputs, ... }: {
  imports = [ inputs.apple-silicon-support.nixosModules.apple-silicon-support ];
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  networking.hostName = "MacBook-Pro-Nixos";
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = false;
    initrd.availableKernelModules = [ "usb_storage" "sdhci_pci" ];
  };
  profiles.defaults.enable = true;
  userPresets.toyvo.enable = true;
  fileSystemPresets.boot.enable = true;
  fileSystemPresets.btrfs.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  hardware.asahi.peripheralFirmwareDirectory = ./firmware;
}
