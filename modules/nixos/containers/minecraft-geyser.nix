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
        image = "docker.io/itzg/minecraft-server:java21";
        ports = [
          "${toString cfg.MCport}:25565"
          "${toString cfg.RCONPort}:25575"
          "${toString cfg.BedrockPort}:19132/udp"
        ];
        env_file = [ cfg.env_file ];
        environment = {
          EULA = "TRUE";
          TYPE = "FABRIC";
          VERSION = "1.21.4";
          MEMORY = "4g";
          OPS = "4cb4aff4-a0ed-4eaf-b912-47825b2ed30d, 2f3205e9-d01f-4b07-9f1c-6aa96bea8911, 921f3122-1b87-4727-9304-35960e038981";
          EXISTING_OPS_FILE = "MERGE";
          EXISTING_WHITELIST_FILE = "MERGE";
          MOTD = "ToyVo Geyser Server";
          MAX_TICK_TIME = "-1";
          SPAWN_PROTECTION = "0";
          MAX_PLAYERS = "10";
          CREATE_CONSOLE_IN_PIPE = "true";
          ALLOW_FLIGHT = "TRUE";
          DIFFICULTY = "hard";
          VIEW_DISTANCE = "8";
          SIMULATION_DISTANCE = "8";
          MAX_CHAINED_NEIGHBOR_UPDATES = "10000";
          MAX_WORLD_SIZE = "12500";
          RATE_LIMIT = "100";
          RCON_CMDS_STARTUP = "gamerule playersSleepingPercentage 0\ngamerule mobGriefing false\ngamerule doFireTick false\ngamerule doInsomnia false";
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
          BACKUP_INTERVAL = "2h";
          BACKUP_METHOD = "rclone";
          INITIAL_DELAY = 0;
          PAUSE_IF_NO_PLAYERS = "true";
          RCLONE_COMPRESS_METHOD = "zstd";
          RCLONE_DEST_DIR = "public/minecraft_geyser";
          RCLONE_REMOTE = "nas";
          RCON_HOST = "mc";
        };
        volumes = [
          "${cfg.dataDir}:/data:ro"
          "${config.sops.secrets."rclone.conf".path}:/config/rclone/rclone.conf:ro"
        ];
      };
    };
    systemd.services.arion-minecraft-geyser.wantedBy = lib.mkIf (!cfg.autoStart) (lib.mkForce [ ]);
    sops.secrets."rclone.conf" = { };
  };
}
