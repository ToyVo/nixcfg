{ config, lib, ... }:
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
    minecraft-experimental = {
      enable = lib.mkEnableOption "Enable minecraft server";
      port = lib.mkOption {
        type = lib.types.int;
        default = 25564;
        description = "Port to expose minecraft server on";
      };
      RCONPort = lib.mkOption {
        type = lib.types.int;
        default = 25574;
        description = "Port to expose minecraft server on";
      };
      datadir = lib.mkOption {
        type = lib.types.path;
        description = "Path to store minecraft data";
      };
      openFirewall = lib.mkEnableOption "Open firewall for minecraft";
    };
  };

  config = lib.mkIf (cfg.minecraft.enable || cfg.minecraft-experimental.enable) {
    containerPresets.podman.enable = lib.mkDefault true;
    networking.firewall.allowedTCPPorts = [ ]
      ++ lib.optionals cfg.minecraft.openFirewall [ cfg.minecraft.port ]
      ++ lib.optionals cfg.minecraft-experimental.openFirewall [ cfg.minecraft-experimental.port ];
    virtualisation.oci-containers.containers = {
      minecraft = lib.mkIf cfg.minecraft.enable {
        image = "docker.io/itzg/minecraft-server:latest";
        # I plan to make a web interface that I want to be able to use RCON to get information but keep it internal
        ports = [ "${toString cfg.minecraft.port}:25565" "${toString cfg.minecraft.RCONPort}:25575" ];
        environment = {
          EULA = "TRUE";
          TYPE = "FTBA";
          FTB_MODPACK_ID = "119";
          MEMORY = "16g";
          OPS = "4cb4aff4-a0ed-4eaf-b912-47825b2ed30d";
          EXISTING_OPS_FILE = "MERGE";
        };
        volumes = [
          "${cfg.minecraft.datadir}:/data"
        ];
      };
      minecraft-experimental = lib.mkIf cfg.minecraft-experimental.enable {
        image = "docker.io/itzg/minecraft-server:latest";
        ports = [ "${toString cfg.minecraft-experimental.port}:25565" "${toString cfg.minecraft-experimental.RCONPort}:25575" ];
        environment = {
          EULA = "TRUE";
          TYPE = "MOHIST";
          VERSION = "1.20.1";
          MEMORY = "16g";
          OPS = "4cb4aff4-a0ed-4eaf-b912-47825b2ed30d";
          EXISTING_OPS_FILE = "MERGE";
          CF_API_KEY = "${builtins.readFile ./forgeapikey}";
          CURSEFORGE_FILES = ''|
            projecte
          '';
        };
        volumes = [
          "${cfg.minecraft-experimental.datadir}:/data"
        ];
      };
    };
  };
}

