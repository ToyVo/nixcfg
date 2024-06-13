{ config, lib, ... }:
let
  cfg = config.containerPresets.minecraft;
in
{
  options.containerPresets.minecraft = {
    enable = lib.mkEnableOption "Enable minecraft server";
    port = lib.mkOption {
      type = lib.types.int;
      default = 25565;
      description = "Port to expose minecraft server on";
    };
    datadir = lib.mkOption {
      type = lib.types.path;
      default = "/mnt/POOL/minecraft";
      description = "Path to store minecraft data";
    };
    openFirewall = lib.mkEnableOption "Open firewall for minecraft";
  };

  config = lib.mkIf cfg.enable {
    containerPresets.podman.enable = lib.mkDefault true;
    virtualisation.oci-containers.containers.minecraft = {
      image = "docker.io/itzg/minecraft-server:latest";
      ports = [ "${toString cfg.port}:25565" ];
      environment = {
        EULA = "TRUE";
        TYPE = "FTBA";
        FTB_MODPACK_ID = "119";
        MEMORY = "16g";
        OPS = "4cb4aff4-a0ed-4eaf-b912-47825b2ed30d";
        EXISTING_OPS_FILE = "MERGE";
      };
      volumes = [
        "${cfg.datadir}:/data"
      ];
    };
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };
  };
}

