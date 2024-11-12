{ pkgs, config, ... }:
{
  boot = {
    loader.systemd-boot.enable = true;
    initrd.availableKernelModules = [
      "xhci_pci"
      "virtio_scsi"
    ];
  };
  containerPresets.podman.enable = true;
  networking = {
    hostName = "oracle-cloud-nixos";
    firewall = {
      allowedTCPPorts = [
        443
      ];
      allowedUDPPorts = [
        53
        443
      ];
    };
  };
  profiles.defaults.enable = true;
  environment.systemPackages = with pkgs; [
    packwiz
  ];
  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    remote-builds.server.enable = true;
  };
  userPresets.toyvo.enable = true;
}
