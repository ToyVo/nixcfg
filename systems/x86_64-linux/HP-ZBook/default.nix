{ inputs, ... }:
let
  system = "x86_64-linux";
in
inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    ({ lib, ... }: {
      imports = [
        ../../../modules/nixos/cd-nixos
        ../../../modules/nixos/users/toyvo
      ];
      home-manager.extraSpecialArgs = { inherit inputs system; };
      nixpkgs.hostPlatform = lib.mkDefault system;
      hardware.cpu.intel.updateMicrocode = true;
      powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
      networking.hostName = "HP-ZBook";
      boot = {
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
        initrd.availableKernelModules =
          [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
        kernelModules = [ "kvm-intel" ];
      };
      cd = {
        defaults.enable = true;
        users.toyvo.enable = true;
        fs.boot.enable = true;
        fs.btrfs.enable = true;
        desktops.gnome.enable = true;
      };
    })
  ];
}
