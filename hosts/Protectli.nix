{ nixpkgs, home-manager, ... }:
let
  system = "x86_64-linux";
  user = "toyvo";
in
nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ../system/filesystem/btrfs.nix
    ../system/filesystem/efi.nix
    ../system/nixos.nix
    ({ lib, ... }: {
      boot = {
        initrd.availableKernelModules = [ "ahci" "xhci_pci" "usb_storage" "usbhid" "sd_mod" ];
        initrd.kernelModules = [ ];
        kernelModules = [ "kvm-intel" ];
        extraModulePackages = [ ];
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
        loader.efi.efiSysMountPoint = "/boot/efi";
        kernel.sysctl = {
          net.ipv4.conf.all.forwarding = true;
          net.ipv6.conf.all.forwarding = true;
        };
      };
      swapDevices = [ ];
      hardware.cpu.intel.updateMicrocode = true;
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      networking = {
        hostName = "Protectli";
        useDHCP = false;
        usePredictableInterfaceNames = true;
        nameservers = [ "1.1.1.1" "1.0.0.1" ];
        bridges.br0 = {
          interfaces = [ "eth1" "eth2" "eth3" ];
        };
        vlans = {
          home = {
            id = 10;
            interface = "br0";
          };
          iot = {
            id = 20;
            interface = "br0";
          };
          guest = {
            id = 30;
            interface = "br0";
          };
        };
        interfaces = {
          eth0.useDHCP = true;
          br0.ipv4.addresses = [{
            address = "10.0.0.1";
            prefixLength = 24;
          }];
          home.ipv4.addresses = [{
            address = "10.0.10.1";
            prefixLength = 24;
          }];
          iot.ipv4.addresses = [{
            address = "10.0.20.1";
            prefixLength = 24;
          }];
          guest.ipv4.addresses = [{
            address = "10.0.30.1";
            prefixLength = 24;
          }];
        };
        nat.enable = true;
        nat.externalInterface = "eth0";
        nat.internalInterfaces = [ "br0" ];
        # Temporary while testing
        firewall.interfaces.eth0.allowedTCPPorts = [ 22 ];
        firewall.interfaces.br0.allowedTCPPorts = [ 53 22 ];
        firewall.interfaces.br0.allowedUDPPorts = [ 53 ];
      };
      services.openssh.openFirewall = false;
      services.dhcpd4 = {
        enable = true;
        extraConfig = ''
          subnet 10.0.0.0 netmask 255.255.255.0 {
            range 10.0.0.100 10.0.0.199
            option routers 10.0.0.1;
            option subnet-mask 255.255.255.0;
            option domain-name-servers 10.0.0.1 1.1.1.1;
            interface br0;
          }
          subnet 10.0.10.0 netmask 255.255.255.0 {
            range 10.0.10.100 10.0.10.199
            option routers 10.0.10.1;
            option subnet-mask 255.255.255.0;
            option domain-name-servers 10.0.0.1 1.1.1.1;
            interface home;
          }
          subnet 10.0.20.0 netmask 255.255.255.0 {
            range 10.0.20.100 10.0.20.199
            option routers 10.0.20.1;
            option subnet-mask 255.255.255.0;
            option domain-name-servers 10.0.0.1 1.1.1.1;
            interface iot;
          }
          subnet 10.0.30.0 netmask 255.255.255.0 {
            range 10.0.30.2 10.0.30.254
            option routers 10.0.30.1;
            option subnet-mask 255.255.255.0;
            option domain-name-servers 1.1.1.1;
            interface guest;
          }
        '';
        interfaces = [ "br0" "home" "iot" "guest" ];
      };
      services.avahi = {
        enable = true;
        reflector = true;
        interfaces = [ "home" "iot" ];
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
