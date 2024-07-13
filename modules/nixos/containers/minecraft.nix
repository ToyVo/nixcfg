{ config, lib, pkgs, ... }:
let
  cfg = config.containerPresets;
in
{
  options.containerPresets = {
    minecraft = {
      enable = lib.mkEnableOption "Enable minecraft server";
      port = lib.mkOption {
        type = lib.types.int;
        default = 25565;
        description = "Port to expose minecraft server on";
      };
      RCONPort = lib.mkOption {
        type = lib.types.int;
        default = 25575;
        description = "Port to expose minecraft server on";
      };
      datadir = lib.mkOption {
        type = lib.types.path;
        description = "Path to store minecraft data";
      };
      openFirewall = lib.mkEnableOption "Open firewall for minecraft";
    };
    minecraft-ftb = {
      enable = lib.mkEnableOption "Enable minecraft server";
      port = lib.mkOption {
        type = lib.types.int;
        default = 25565;
        description = "Port to expose minecraft server on";
      };
      RCONPort = lib.mkOption {
        type = lib.types.int;
        default = 25575;
        description = "Port to expose minecraft server on";
      };
      datadir = lib.mkOption {
        type = lib.types.path;
        description = "Path to store minecraft data";
      };
      openFirewall = lib.mkEnableOption "Open firewall for minecraft";
    };
  };

  config = lib.mkIf (cfg.minecraft.enable || cfg.minecraft-ftb.enable) {
    sops.secrets."minecraft_docker.env" = { };
    containerPresets.podman.enable = lib.mkDefault true;
    networking.firewall.allowedTCPPorts = lib.optionals cfg.minecraft.openFirewall [ cfg.minecraft.port ]
      ++ lib.optionals cfg.minecraft-ftb.openFirewall [ cfg.minecraft-ftb.port ];
    virtualisation.oci-containers.containers = {
      minecraft-ftb = lib.mkIf cfg.minecraft-ftb.enable {
        image = "docker.io/itzg/minecraft-server:latest";
        # I plan to make a web interface that I want to be able to use RCON to get information but keep it internal
        ports = [ "${toString cfg.minecraft-ftb.port}:25565" "${toString cfg.minecraft-ftb.RCONPort}:25575" ];
        environment = {
          EULA = "TRUE";
          MEMORY = "20g";
          OPS = "4cb4aff4-a0ed-4eaf-b912-47825b2ed30d";
          EXISTING_OPS_FILE = "MERGE";
          MOTD = "ToyVo Direwolf20 Custom Server";
          TYPE = "FTBA";
          FTB_MODPACK_ID = "119";
          FTB_MODPACK_VERSION_ID = "11614";
          # FTB_FORCE_REINSTALL = "true";
          MAX_TICK_TIME = "-1";
          MAX_WORLD_SIZE = "128000";
          PATCH_DEFINITIONS = "/data/patches";
        };
        volumes = [
          "${cfg.minecraft-ftb.datadir}:/data"
        ];
      };
      minecraft = lib.mkIf cfg.minecraft.enable {
        image = "docker.io/itzg/minecraft-server:latest";
        # I plan to make a web interface that I want to be able to use RCON to get information but keep it internal
        ports = [ "${toString cfg.minecraft.port}:25565" "${toString cfg.minecraft.RCONPort}:25575" ];
        environment = {
          EULA = "TRUE";
          TYPE = "MOHIST";
          VERSION = "1.20.1";
          MEMORY = "20g";
          OPS = "4cb4aff4-a0ed-4eaf-b912-47825b2ed30d";
          EXISTING_OPS_FILE = "MERGE";
          MOTD = "ToyVo Custom Server";
          MAX_TICK_TIME = "-1";
          MAX_WORLD_SIZE = "100000";
          PACKWIZ_URL="https://mc.toyvo.dev/pack.toml";
        };
        volumes = [
          "${cfg.minecraft.datadir}:/data"
        ];
      };
    };
  };
}
