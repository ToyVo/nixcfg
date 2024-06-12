{ config, lib, ... }:
let
  cfg = config.services.ollama;
in
{
  config = lib.mkIf (cfg.enable && cfg.openFirewall) {
    services.ollama = {
      host = "0.0.0.0";
      openFirewall = true;
    };
    networking = {
      firewall = {
        allowedTCPPorts = [ cfg.port ];
      };
    };
  };
}
