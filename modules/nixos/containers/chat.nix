{ config, lib, ... }:
let
  cfg = config.containerPresets.open-webui;
in
{
  options.containerPresets.open-webui = {
    enable = lib.mkEnableOption "Enable open-webui";
    port = lib.mkOption {
      type = lib.types.int;
      default = 11435;
      description = "Port to expose open-webui on";
    };
    datadir = lib.mkOption {
      type = lib.types.path;
      default = "/mnt/POOL/open-webui";
      description = "Path to store open-webui data";
    };
    openFirewall = lib.mkEnableOption "Enable open-webui firewall rules";
  };

  config = lib.mkIf cfg.enable {
    containerPresets.podman.enable = lib.mkDefault true;
    virtualisation.arion.projects.open-webui.settings.services.open-webui.service = {
      image = "ghcr.io/open-webui/open-webui:main";
      ports = [ "${toString cfg.port}:8080" ];
      volumes = [
        "${cfg.datadir}:/app/backend/data"
      ];
      environment = {
        OLLAMA_BASE_URL = "https://ollama.diekvoss.net";
      };
    };
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };
  };
}
