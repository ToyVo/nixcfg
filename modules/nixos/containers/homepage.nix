{ config, lib, ... }:
let
  cfg = config.containerPresets.homepage;
in
{
  options.containerPresets.homepage = {
    enable = lib.mkEnableOption "Enable Homepage dashboard";
    port = lib.mkOption {
      type = lib.types.int;
      default = 3000;
      description = "Port to expose Homepage dashboard on";
    };
    datadir = lib.mkOption {
      type = lib.types.path;
      default = "/mnt/POOL/homepage";
      description = "Path to store Homepage dashboard data";
    };
    openFirewall = lib.mkEnableOption "Enable Homepage dashboard";
  };

  config = lib.mkIf cfg.enable {
    containerPresets.podman.enable = lib.mkDefault true;
    virtualisation.arion.projects.homepage.settings.services.homepage.service = {
      image = "ghcr.io/gethomepage/homepage:latest";
      ports = [ "${toString cfg.port}:3000" ];
      volumes = [
        "${cfg.datadir}:/app/config"
        "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
      ];
    };
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };
  };
}
