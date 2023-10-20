{ lib, pkgs, ... }: {
      hardware.cpu.amd.updateMicrocode = true;
      networking.hostName = "HP-Envy";
      boot = {
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
        initrd.availableKernelModules =
          [ "nvme" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
        kernelModules = [ "kvm-amd" "amdgpu" ];
      };
      cd = {
        defaults.enable = true;
        users.toyvo.enable = true;
        fs.boot.enable = true;
        fs.btrfs.enable = true;
        desktops.gnome.enable = true;
      };
      services.xserver.videoDrivers = [ "amdgpu" ];
      hardware.opengl = {
        extraPackages = with pkgs; [
          rocm-opencl-icd
          rocm-opencl-runtime
          amdvlk
        ];
        extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
        driSupport = true;
        driSupport32Bit = true;
      };
    }