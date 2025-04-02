{
  config,
  lib,
  ...
}: let
  cfg = config.containerPresets.portainer;
in {
  options.containerPresets.portainer = {
    enable = lib.mkEnableOption "Enable portainer";
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
      ports = ["8000:8000" "9443:9443"];
      volumes = [
        "${cfg.dataDir}:/data"
        "/var/run/podman/podman.sock:/var/run/docker.sock"
        "/etc/localtime:/etc/localtime"
      ];
      autoStart = true;
      extraOptions = [
        "--pull=always"
        "--restart=unless-stopped"
        "--rm=false"
      ];
    };
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [8000 9443];
  };
}
