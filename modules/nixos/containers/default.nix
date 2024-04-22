{ lib, config, pkgs, ... }:
let
  cfg = config.containerPresets;
in
{
  options.containerPresets = {
    docker.enable = lib.mkEnableOption "Enable docker runtime";
    podman.enable = lib.mkEnableOption "Enable podman runtime";
  };

  config = lib.mkIf (cfg.docker.enable || cfg.podman.enable) {
    environment.systemPackages = with pkgs; []
      ++ lib.optionals cfg.docker.enable [
        docker
        docker-compose
      ]
      ++ lib.optionals cfg.podman.enable [
        podman
        podman-compose
      ];
    virtualisation = {
      docker = lib.mkIf cfg.docker.enable {
        enable = true;
        rootless = {
          enable = true;
          setSocketVariable = true;
        };
        daemon.settings.dns = [ "10.1.0.1" ];
      };
      podman = lib.mkIf cfg.podman.enable {
        enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };

      oci-containers.backend = if cfg.podman.enable then "podman" else "docker";
    };
  };
}
