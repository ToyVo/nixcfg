{
  lib,
  config,
  ...
}:
let
  cfg = config.containerPresets.minecraft-geyser;
in
{
  options.containerPresets.minecraft-geyser = {
    enable = lib.mkEnableOption "enable minecraft geyser for java and bedrock players";
    autoStart = lib.mkEnableOption "start server at boot";
    env_file = lib.mkOption {
      type = lib.types.path;
      description = ''
        Path to the environment file, must include the following variables:
        RCON_PASSWORD
      '';
    };
    MCport = lib.mkOption {
      type = lib.types.int;
      default = 25566;
      description = "Port to expose minecraft server on";
    };
    BedrockPort = lib.mkOption {
      type = lib.types.int;
      default = 19132;
      description = "Port to expose minecraft server on";
    };
    RCONPort = lib.mkOption {
      type = lib.types.int;
      default = 25576;
      description = "Port to expose minecraft rcon on";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      description = "Path to store minecraft data";
    };
    backupDir = lib.mkOption {
      type = lib.types.path;
      description = "Path to store minecraft backups";
    };
    openFirewall = lib.mkEnableOption "Open firewall for minecraft";
  };
  config = lib.mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = lib.optionals cfg.openFirewall [
        cfg.MCport
      ];
      allowedUDPPorts = lib.optionals cfg.openFirewall [
        cfg.BedrockPort
      ];
    };
    virtualisation.arion.projects.minecraft-geyser.settings.services = {
      mc.service = {
        image = "docker.io/itzg/minecraft-server:java17";
        ports = [
          "${toString cfg.MCport}:25565"
          "${toString cfg.RCONPort}:25575"
          "${toString cfg.BedrockPort}:19132/udp"
        ];
        env_file = [ cfg.env_file ];
        environment = {
          EULA = "TRUE";
          TYPE = "PAPER";
          VERSION = "1.20.1";
          MEMORY = "4g";
          OPS = "4cb4aff4-a0ed-4eaf-b912-47825b2ed30d";
          EXISTING_OPS_FILE = "MERGE";
          EXISTING_WHITELIST_FILE = "MERGE";
          MOTD = "ToyVo Geyser Server";
          MAX_TICK_TIME = "-1";
          SPAWN_PROTECTION = "0";
          MAX_PLAYERS = "10";
          CREATE_CONSOLE_IN_PIPE = "true";
          ALLOW_FLIGHT = "TRUE";
          DIFFICULTY = "hard";
        };
        volumes = [
          "${cfg.dataDir}:/data"
        ];
      };
      backups.service = {
        image = "docker.io/itzg/mc-backup";
        depends_on.mc.condition = "service_healthy";
        env_file = [ cfg.env_file ];
        environment = {
          BACKUP_INTERVAL = "5m";
          RCON_HOST = "mc";
          INITIAL_DELAY = 0;
          PAUSE_IF_NO_PLAYERS = "false";
          RCLONE_REMOTE = "protondrive";
          RCLONE_COMPRESS_METHOD = "zstd";
        };
        volumes = [
          "${cfg.dataDir}:/data:ro"
          "${cfg.backupDir}:/backups:ro"
        ];
      };
    };
    systemd.services.arion-minecraft-geyser.wantedBy = lib.mkIf (!cfg.autoStart) (lib.mkForce [ ]);
  };
}
