{
  config,
  lib,
  ...
}: let
  cfg = config.containerPresets.portainer;
in {
  options.containerPresets.portainer = {
    enable = lib.mkEnableOption "Enable portainer";
    port = lib.mkOption {
      type = lib.types.int;
      default = 8000;
      description = "Port to expose portainer on";
    };
    sport = lib.mkOption {
      type = lib.types.int;
      default = 9443;
      description = "Port to expose portainer on with ssl";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/portainer";
      description = "Path to store portainer data";
    };
    openFirewall = lib.mkEnableOption "open firewall to portainer";
  };

  config = lib.mkIf cfg.enable {
    containerPresets.podman.enable = lib.mkDefault true;
    virtualisation.oci-containers.containers.portainer = {
      image = "docker.io/portainer/portainer-ce:latest";
      ports = ["${cfg.port}:8000" "${cfg.sport}:9443"];
      volumes = [
        "${cfg.dataDir}:/data"
        "/var/run/podman/podman.sock:/var/run/docker.sock"
        "/etc/localtime:/etc/localtime"
      ];
      autoStart = true;
      extraOptions = [
        "--restart=always"
        "--privileged"
      ];
    };
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port cfg.sport];
  };
}
