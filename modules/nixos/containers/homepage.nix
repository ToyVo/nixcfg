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
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/homepage";
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
        "${cfg.dataDir}:/app/config"
        "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
      ];
    };
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
  };
}
