{ lib, config, pkgs, ... }:
let
  cfg = config.containerPresets.nextcloud;
in
{
  options.containerPresets.nextcloud = {
    enable = lib.mkEnableOption "Enable nextcloud container";
    openFirewall = lib.mkEnableOption "Open firewall for nextcloud";
    datadir = lib.mkOption {
      type = lib.types.path;
      default = "/mnt/POOL/nextcloud";
      description = "Path to store nextcloud data";
    };
  };

  config = lib.mkIf cfg.enable {
    containerPresets.podman.enable = lib.mkDefault true;
    virtualisation.oci-containers.containers."nextcloud-aio-mastercontainer" = {
      image = "docker.io/nextcloud/all-in-one:latest";
      volumes = [
        "nextcloud_aio_mastercontainer:/mnt/docker-aio-config"
        "/var/run/user/1000/podman/podman.sock:/var/run/docker.sock"
      ];
      ports = [
        "80:80"
        "8080:8080"
        "8443:8443"
      ];
      environment = {
        NEXTCLOUD_DATA_DIR = "${cfg.datadir}";
      };
    };
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ 8080 ];
    };
  };
}
