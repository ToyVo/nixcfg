{ nixpkgs, home-manager }:
let
  system = "x86_64-linux";
  user = "toyvo";
in
nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ../system/filesystem/btrfs.nix
    ../system/filesystem/efi.nix
    ../system/gnome.nix
    ({ pkgs, lib, ... }: {
      boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-amd" "amdgpu" ];
      boot.extraModulePackages = [ ];
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.efi.efiSysMountPoint = "/boot/efi";
      swapDevices = [ ];
      networking.hostName = "Thinkpad";
      networking.useDHCP = lib.mkDefault true;
      hardware.cpu.amd.updateMicrocode = true;
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      services.xserver.videoDrivers = [ "amdgpu" ];
      hardware.opengl = {
        extraPackages = with pkgs; [
          rocm-opencl-icd
          rocm-opencl-runtime
          amdvlk
        ];
        extraPackages32 = with pkgs; [
          driversi686Linux.amdvlk
        ];
        driSupport = true;
        driSupport32Bit = true;
      };
    })
    nixpkgs.nixosModules.notDetected
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = {
        home.username = user;
        home.homeDirectory = "/home/${user}";
        imports = [
          ../home
          ../home/neovim
          ../home/alacritty.nix
          ../home/kitty.nix
          ../home/git.nix
          ../home/gpg.nix
          ../home/ssh.nix
          ../home/starship.nix
          ../home/zsh.nix
        ];
      };
    }
  ];
}
