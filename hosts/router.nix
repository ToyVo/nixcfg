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
          [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" "sdhci_pci" ];
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
      powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
      hardware.cpu.intel.updateMicrocode = true;
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      networking = {
        hostName = "router";
        useDHCP = false;
        nameservers = [ "1.1.1.1" "1.0.0.1" ];
        bridges.br0.interfaces = [ "enp3s0" "enp4s0" "enp5s0" ];
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
          enp2s0.useDHCP = true;
          enp3s0.useDHCP = true;
          enp4s0.useDHCP = true;
          enp5s0.useDHCP = true;
          br0.ipv4.addresses = [{
            address = "10.1.0.1";
            prefixLength = 24;
          }];
          cdwifi.ipv4.addresses = [{
            address = "10.1.10.1";
            prefixLength = 24;
          }];
          cdiot.ipv4.addresses = [{
            address = "10.1.20.1";
            prefixLength = 24;
          }];
          cdguest.ipv4.addresses = [{
            address = "10.1.30.1";
            prefixLength = 24;
          }];
        };
        nat.enable = true;
        nat.externalInterface = "enp2s0";
        nat.internalInterfaces = [ "br0" "cdwifi" "cdiot" "cdguest" ];
        firewall = {
          enable = true;
          trustedInterfaces = [ "br0" "cdwifi" "cdiot" ];
          interfaces.br0.allowedTCPPorts = [ 53 22 ];
          interfaces.br0.allowedUDPPorts = [ 53 ];
        };
      };
      services.openssh.openFirewall = false;
      services.dnsmasq = {
        enable = true;
        settings = {
          server = [ "10.1.0.6" "1.1.1.1" "1.0.0.1" ];
          domain-needed = true;
          interface = [ "br0" "cdwifi" "cdiot" "cdguest" ];
          dhcp-range = [
            "10.1.0.100,10.1.0.199"
            "10.1.10.100,10.1.10.199"
            "10.1.20.100,10.1.20.199"
            "10.1.30.2,10.1.30.254"
          ];
          dhcp-host = [
            # Omada Controller
            "10:27:f5:bd:04:97,10.1.0.2"
            # Proxmox
            "70:85:c2:8a:53:5b,10.1.10.3"
            # TrueNAS VM (Proxmox)
            "e2:8b:29:5e:56:ca,10.1.10.4"
            # Canon Printer
            "c4:ac:59:a6:63:33,10.1.10.5"
            # Docker VM (Proxmox)
            "7a:8d:bd:a3:66:ba,10.1.10.6"
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
