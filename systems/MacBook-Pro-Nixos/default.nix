{ lib, ... }: {
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  networking.hostName = "MacBook-Pro-Nixos";
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = false;
    initrd.availableKernelModules = [ "usb_storage" "sdhci_pci" ];
  };
  profiles.dev.enable = true;
  userPresets.toyvo.enable = true;
  fileSystemPresets.boot.enable = true;
  fileSystemPresets.btrfs.enable = true;
  services.desktopManager.plasma6.enable = true;
  hardware.asahi.peripheralFirmwareDirectory = ./firmware;
}
