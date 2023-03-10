{ config, lib, ... }:

{
  imports = [
    ./common.nix
    ./nixos.nix
    ./gnome.nix
  ];
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  fileSystems."/" =
    { device = "/dev/disk/by-label/NIXOS";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-label/NIXOS";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-label/EFI";
      fsType = "vfat";
    };

  swapDevices = [ ];

  networking.hostName = "Collins-Thinkpad";
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
