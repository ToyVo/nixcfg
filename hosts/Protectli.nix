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
        vlans = {
          cdwifi = {
            id = 10;
            interface = "br0";
          };
          cdiot = {
            id = 20;
            interface = "br0";
          };
          cdguest = {
            id = 30;
            interface = "br0";
          };
        };
        interfaces = {
          enp1s0.useDHCP = true;
          enp2s0.useDHCP = true;
          enp3s0.useDHCP = true;
          enp4s0.useDHCP = true;
          br0.ipv4.addresses = [{
            address = "10.0.0.1";
            prefixLength = 24;
          }];
          cdwifi.ipv4.addresses = [{
            address = "10.0.10.1";
            prefixLength = 24;
          }];
          cdiot.ipv4.addresses = [{
            address = "10.0.20.1";
            prefixLength = 24;
          }];
          cdguest.ipv4.addresses = [{
            address = "10.0.30.1";
            prefixLength = 24;
          }];
        };
        nat.enable = true;
        nat.externalInterface = "enp1s0";
        nat.internalInterfaces = [ "br0" "cdwifi" "cdiot" "cdguest" ];
        firewall = {
          enable = true;
          trustedInterfaces = [ "br0" "cdwifi" "cdiot" ];
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
          interface = [ "br0" "cdwifi" "cdiot" "cdguest" ];
          dhcp-range = [
            "10.0.0.2,10.0.0.254"
            "10.0.10.2,10.0.10.254"
            "10.0.20.2,10.0.20.254"
            "10.0.30.2,10.0.30.254"
          ];
        };
      };
      services.avahi = {
        enable = true;
        reflector = true;
        allowInterfaces = [ "cdwifi" "cdiot" ];
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
