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
        bridges.br0 = { interfaces = [ "enp2s0" "enp3s0" "enp4s0" ]; };
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
          enp1s0.useDHCP = true;
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
        nat.externalInterface = "enp1s0";
        nat.internalInterfaces = [ "br0" ];
        # Temporary while testing
        firewall.interfaces.enp1s0.allowedTCPPorts = [ 22 ];
        firewall.interfaces.br0.allowedTCPPorts = [ 53 22 ];
        firewall.interfaces.br0.allowedUDPPorts = [ 53 ];
      };
      services.openssh.openFirewall = false;
      services.dnsmasq = {
        enable = true;
        servers = [ "1.1.1.1" ];
        extraConfig = ''
          domain-needed
          interface=br0
          interface=home
          interface=iot
          interface=guest
          dhcp-range=10.0.0.100,10.0.0.199,24h
          dhcp-range=10.10.0.100,10.10.0.199,24h
          dhcp-range=10.20.0.100,10.20.0.199,24h
          dhcp-range=10.30.0.10,10.30.0.199,24h
        '';
        interfaces = [ "br0" "home" "iot" "guest" ];
      };
      services.avahi = {
        enable = true;
        reflector = true;
        allowInterfaces = [ "home" "iot" ];
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
