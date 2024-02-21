{ lib, inputs,  ... }: {
  imports = [ inputs.nixos-hardware.nixosModules.pine64-pinebook-pro ];
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  networking.hostName = "PineBook-Pro";
  boot.loader.systemd-boot.enable = true;
  profiles.defaults.enable = true;
  userPresets.toyvo.enable = true;
  fileSystemPresets.boot.enable = true;
  fileSystemPresets.btrfs.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
}
