{ lib, config, pkgs, ... }:
let
  cfg = config.cd.containers.nextcloud;
in
{
  options.cd.containers.nextcloud = {
    enable = lib.mkEnableOption "Enable nextcloud container";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.nextcloud-aio-mastercontainer = {
      image = "nextcloud/all-in-one:latest";
      autoStart = true;
      ports = [ "80:80" "443:443" "3478:3478" "8443:8443" ];
      volumes = [
        "/mnt/POOL/nextcloud-aio-mastercontainer:/mnt/docker-aio-coinfig"
        "/run/docker.sock:/var/run/docker.sock:ro"
      ];
    };
  };
}
