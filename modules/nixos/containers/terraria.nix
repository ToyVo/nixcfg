{
  lib,
  config,
  ...
}:
let
  cfg = config.containerPresets.terraria;
in
{
  options.containerPresets.terraria = {
    enable = lib.mkEnableOption "enable terraria server";
    autoStart = lib.mkEnableOption "start server at boot";
    port = lib.mkOption {
      type = lib.types.int;
      default = 7777;
      description = "Port to expose terraria server on";
    };
    RestPort = lib.mkOption {
      type = lib.types.int;
      default = 7878;
      description = "Port to expose terarria rest api on";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      description = "Path to store terraria data";
    };
    openFirewall = lib.mkEnableOption "Open firewall for terraria";
  };
  config = lib.mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = lib.optionals cfg.openFirewall [
        cfg.port
      ];
      allowedUDPPorts = lib.optionals cfg.openFirewall [
        cfg.port
      ];
    };
    virtualisation.arion.projects.terraria.settings.services.terraria.service = {
      image = "docker.io/ryshe/terraria:tshock-1.4.4.9-5.2.0-3";
      ports = [
        "${toString cfg.port}:7777"
        "${toString cfg.RestPort}:7878"
      ];
      volumes = [
        "${cfg.dataDir}/Worlds:/root/.local/share/Terraria/Worlds"
        "${cfg.dataDir}/ServerPlugins:/plugins"
      ];
      environment = {
        WORLD_FILENAME = "large_master_crimson.wld";
      };
    };
    systemd.services.arion-terraria.wantedBy = lib.mkIf (!cfg.autoStart) (lib.mkForce [ ]);
  };
}
