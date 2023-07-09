inputs:
let
  system = "x86_64-linux";
in inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    inputs.nixpkgs.nixosModules.notDetected
    inputs.nixvim.nixosModules.nixvim
    inputs.home-manager.nixosModules.home-manager
    ../system/nixos.nix
    ../home/toyvo.nix
    ({ lib, pkgs, ... }: {
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.efi.efiSysMountPoint = "/boot/efi";
      boot.initrd.availableKernelModules =
        [ "nvme" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-amd" "amdgpu" ];
      boot.extraModulePackages = [ ];
      swapDevices = [ ];
      networking.hostName = "HP-Envy";
      networking.useDHCP = lib.mkDefault true;
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.amd.updateMicrocode = true;
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
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs system; };
      cdcfg.users.toyvo.enable = true;
      cdcfg.fs.efi.enable = true;
      cdcfg.fs.btrfs.enable = true;
      cdcfg.gnome.enable = true;
    })
  ];
}
