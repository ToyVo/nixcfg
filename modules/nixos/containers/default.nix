{ lib, config, ... }:
let
  cfg = config.cd.containers;
in
{
  imports = [ ./nextcloud.nix ];

  options.cd.containers = {
    enable = lib.mkEnableOption "Enable container runtime";
  };

  config = lib.mkIf cfg.enable {
    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };

      oci-containers.backend = "podman";
    };
  };
}
