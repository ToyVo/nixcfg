{ config, lib, ... }:
let
  cfg = config.services.ollama;
in
{
  options.services.ollama = {
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to open the firewall for the Ollama service.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.openFirewall) {
    services.ollama.host = "0.0.0.0";
    networking = {
      firewall = {
        allowedTCPPorts = [ cfg.port ];
      };
    };
  };
}
