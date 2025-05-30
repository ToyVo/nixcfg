{ pkgs, ... }:
{
  hardware.cpu.amd.updateMicrocode = true;
  networking.hostName = "Thinkpad";
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
    dev.enable = true;
    gaming.enable = true;
    gui.enable = true;
  };
  userPresets.toyvo.enable = true;
  fileSystemPresets.efi.enable = true;
  fileSystemPresets.btrfs.enable = true;
  services.desktopManager.cosmic.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.graphics = {
    extraPackages = with pkgs; [
      amdvlk
    ];
    extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
    enable = true;
    enable32Bit = true;
  };
  environment.systemPackages = with pkgs; [
    jetbrains.rider
    jetbrains.rust-rover
  ];
}
