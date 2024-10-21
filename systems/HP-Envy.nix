{ pkgs, lib, ... }:
{
  hardware.cpu.amd.updateMicrocode = true;
  networking.hostName = "HP-Envy";
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "usb_storage"
      "sd_mod"
      "rtsx_pci_sdmmc"
    ];
    kernelModules = [
      "kvm-amd"
      "amdgpu"
    ];
    kernelPackages = pkgs.linuxPackages_latest;
  };
  profiles = {
    defaults.enable = true;
    gui.enable = true;
  };
  userPresets.toyvo.enable = true;
  userPresets.chloe.enable = true;
  fileSystemPresets.boot.enable = true;
  fileSystemPresets.btrfs.enable = true;
  services.desktopManager.cosmic.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.displayManager.cosmic-greeter.enable = lib.mkForce false;
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.graphics = {
    extraPackages = with pkgs; [
      rocm-opencl-icd
      rocm-opencl-runtime
      amdvlk
    ];
    extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
    enable = true;
    enable32Bit = true;
  };
  environment.systemPackages = with pkgs; [
    discord
    heroic
    lutris
    mangohud
    prismlauncher
    protonup
    r2modman
    steam
    steamPackages.steamcmd
    (wrapOBS {
      plugins = with obs-studio-plugins; [
        obs-gstreamer
        obs-vaapi
        obs-vkcapture
      ];
    })
  ];
}
