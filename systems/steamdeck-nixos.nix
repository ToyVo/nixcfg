{ lib, pkgs, ... }: {
  hardware.cpu.amd.updateMicrocode = true;
  hardware.bluetooth.enable = true;
  networking.hostName = "steamdeck-nixos";
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
    kernelModules = [ "kvm-amd" ];
  };
  profiles.gaming.enable = true;
  profiles.dev.enable = true;
  userPresets.toyvo.enable = true;
  fileSystemPresets.efi.enable = true;
  fileSystemPresets.btrfs.enable = true;
  services = {
    openssh.enable = true;
    desktopManager.plasma6.enable = true;
    # remote-builds.client.enable = true;
    xserver.displayManager.gdm.enable = lib.mkForce false;
    displayManager.sddm.enable = lib.mkForce false;
  };
  fileSystems."/mnt/POOL" = {
    device = "/dev/disk/by-label/POOL";
    fsType = "btrfs";
    options = [ "nofail" "noatime" "lazytime" "compress-force=zstd" "space_cache=v2" "autodefrag" "ssd_spread" ];
  };
  jovian = {
    devices.steamdeck.enable = true;
    steam.enable = true;
    steam.autoStart = true;
    steam.user = "toyvo";
    steam.desktopSession = "plasma";
  };
  environment.systemPackages = with pkgs; [
    maliit-keyboard
    pwvucontrol
  ];
}
