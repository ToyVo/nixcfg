{ lib, ... }: {
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  networking.hostName = "PineBook-Pro";
  boot.loader.systemd-boot.enable = true;
  cd = {
    defaults.enable = true;
    users.toyvo.enable = true;
    fs.boot.enable = true;
    fs.btrfs.enable = true;
    desktops.xfce.enable = true;
  };
}
