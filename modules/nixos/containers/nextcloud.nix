{ lib, config, pkgs, ... }:
let
  cfg = config.cd.containers.nextcloud;
in
{
  options.cd.containers.nextcloud = {
    enable = lib.mkEnableOption "Enable nextcloud container";
  };

  config = lib.mkIf cfg.enable {
    virtualization.oci-containers.containers.nextcloud = {
      image = "nextcloud/all-in-one:latest";
      autoStart = true;
    };
  };
}
