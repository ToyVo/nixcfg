{ nixpkgs, home-manager, ... }@inputs:
let
  system = "x86_64-linux";
  user = "toyvo";
in nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ../system/filesystem/btrfs.nix
    ../system/filesystem/efi.nix
    ../system/nixos.nix
    ({ lib, ... }: {
      boot = {
        initrd.availableKernelModules =
          [ "ahci" "xhci_pci" "usb_storage" "usbhid" "sd_mod" ];
        initrd.kernelModules = [ ];
        kernelModules = [ "kvm-intel" ];
        extraModulePackages = [ ];
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
        loader.efi.efiSysMountPoint = "/boot/efi";
        kernel.sysctl = {
          "net.ipv4.conf.all.forwarding" = true;
          "net.ipv6.conf.all.forwarding" = true;
        };
      };
      swapDevices = [ ];
      hardware.cpu.intel.updateMicrocode = true;
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      networking = {
        hostName = "Protectli";
        useDHCP = false;
        nameservers = [ "1.1.1.1" "1.0.0.1" ];
        bridges.br0.interfaces = [ "enp2s0" "enp3s0" "enp4s0" ];
        interfaces = {
          enp1s0.useDHCP = true;
          enp2s0.useDHCP = true;
          enp3s0.useDHCP = true;
          enp4s0.useDHCP = true;
          br0 = {
            useDHCP = false;
            ipv4.addresses = [{address = "192.168.0.1"; prefixLength = 24;}];
          };
        };
        nat.enable = true;
        nat.externalInterface = "enp1s0";
        nat.internalInterfaces = [ "br0" ];
        firewall = {
          enable = true;
          trustedInterfaces = [ "br0" ];
          # Temporary while testing
          interfaces.enp1s0.allowedTCPPorts = [ 22 ];
          interfaces.br0.allowedTCPPorts = [ 53 22 ];
          interfaces.br0.allowedUDPPorts = [ 53 ];
        };
      };
      services.openssh.openFirewall = false;
      services.dnsmasq = {
        enable = true;
        settings = {
          server = [ "1.1.1.1" "1.0.0.1" ];
          domain-needed = true;
          dhcp-range = ["192.168.0.2,192.168.0.254"];
        };
      };
      services.avahi = {
        enable = true;
        reflector = true;
      };
    })
    nixpkgs.nixosModules.notDetected
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs system; };
      home-manager.users.${user} = {
        home.username = user;
        home.homeDirectory = "/home/${user}";
        imports = [
          ../home
          ../home/neovim
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
