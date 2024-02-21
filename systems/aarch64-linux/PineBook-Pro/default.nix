{ lib, ... }: {
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  networking.hostName = "PineBook-Pro";
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 5;
  };
  profiles.defaults.enable = true;
  userPresets.toyvo.enable = true;
  fileSystemPresets.boot.enable = true;
  fileSystemPresets.btrfs.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
}
