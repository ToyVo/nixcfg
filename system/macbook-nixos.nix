{ config, pkgs, lib, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  hardware.asahi.peripheralFirmwareDirectory = /boot/asahi;
  networking.hostName = "MacBook-Pro-Nixos";
  boot.initrd.availableKernelModules = [ "usb_storage" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/2905770d-0029-4fb7-8a98-644c484a084f";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };
  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/2905770d-0029-4fb7-8a98-644c484a084f";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };
  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/2905770d-0029-4fb7-8a98-644c484a084f";
      fsType = "btrfs";
      options = [ "subvol=@nix" ];
    };
  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/8182-1F1C";
      fsType = "vfat";
    };
  swapDevices = [ ];
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  hardware.video.hidpi.enable = lib.mkDefault true;
}
