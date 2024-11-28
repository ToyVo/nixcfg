{
  lib,
  config,
  ...
}:
let
  cfg = config.containerPresets.minecraft-modded;
in
{
  options.containerPresets.minecraft-modded = {
    enable = lib.mkEnableOption "enable modded minecraft server";
    autoStart = lib.mkEnableOption "start server at boot" // {
      default = true;
    };
    env_file = lib.mkOption {
      type = lib.types.path;
      description = ''
        Path to the environment file, must include the following variables:
        RCON_PASSWORD
      '';
    };
    MCport = lib.mkOption {
      type = lib.types.int;
      default = 25565;
      description = "Port to expose minecraft server on";
    };
    RCONPort = lib.mkOption {
      type = lib.types.int;
      default = 25575;
      description = "Port to expose minecraft rcon on";
    };
    voicePort = lib.mkOption {
      type = lib.types.int;
      default = 24454;
      description = "Port to expose minecraft simple voice chat on";
    };
    datadir = lib.mkOption {
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
        cfg.voicePort
      ];
    };
    virtualisation.arion.projects.minecraft-modded.settings.services.mc.service = {
      image = "docker.io/itzg/minecraft-server:java17";
      ports = [
        "${toString cfg.MCport}:25565"
        "${toString cfg.RCONPort}:25575"
        "${toString cfg.voicePort}:24454/udp"
      ];
      env_file = [ cfg.env_file ];
      environment = {
        EULA = "TRUE";
        TYPE = "FORGE";
        FORGE_VERSION = "47.3.10";
        VERSION = "1.20.1";
        MEMORY = "20g";
        OPS = "4cb4aff4-a0ed-4eaf-b912-47825b2ed30d";
        EXISTING_OPS_FILE = "MERGE";
        EXISTING_WHITELIST_FILE = "MERGE";
        MOTD = "ToyVo Modded Server";
        MAX_TICK_TIME = "-1";
        PACKWIZ_URL = "https://packwiz.toyvo.dev/pack.toml";
        SPAWN_PROTECTION = "0";
        MAX_PLAYERS = "10";
        CREATE_CONSOLE_IN_PIPE = "true";
        JVM_DD_OPTS = "fml.queryResult=confirm";
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
        "${cfg.datadir}:/data"
      ];
    };
    systemd.services.arion-minecraft-modded.wantedBy = lib.mkIf (!cfg.autoStart) (lib.mkForce [ ]);
  };
}
