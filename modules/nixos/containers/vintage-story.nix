{
  lib,
  config,
  vintage-story-arm-server,
  ...
}:
let
  cfg = config.containerPresets.vintage-story;
in
{
  options.containerPresets.vintage-story = {
    enable = lib.mkEnableOption "enable vintage story server";
    autoStart = lib.mkEnableOption "start server at boot";
    env_file = lib.mkOption {
      type = lib.types.path;
      description = "Path to the environment file";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 42420;
      description = "Port to expose vintage story server on";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      description = "Path to store vintage story data";
    };
    openFirewall = lib.mkEnableOption "Open firewall for vintage story";
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
    virtualisation.arion.projects.vintage-story.settings.services = {
      vs.service = {
        build.context = vintage-story-arm-server.outPath;
        build.dockerfile = "./Dockerfile";
        ports = [
          "${toString cfg.port}:42420"
          "${toString cfg.port}:42420/udp"
        ];
        volumes = [
          "${cfg.dataDir}:/home/app/.config/VintagestorData"
        ];
        restart = "on-failure";
        tty = true;
      };
    };
    systemd.services.arion-vintage-story.wantedBy = lib.mkIf (!cfg.autoStart) (lib.mkForce [ ]);
  };
}
