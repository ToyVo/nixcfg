{ config, lib, ... }:
let
  cfg = config.cd;
in
{
  options.cd.homer = lib.mkEnableOption "Enable Homer container";

  config = lib.mkIf cfg.homer {
    virtualisation = {
      podman = {
        enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };
      oci-containers.containers = {
        homer = {
          image = "b4bz/homer:latest";
          ports = [ "0.0.0.0:8080:8080" ];
          volumes = [ "/var/lib/homer/assets:/www/assets" ];
        };
      };
    };
  };
}
