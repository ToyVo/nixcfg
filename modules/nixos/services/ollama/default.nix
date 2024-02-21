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
    port = lib.mkOption {
      type = lib.types.int;
      default = 11434;
      description = "The port on which the Ollama service listens.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.openFirewall) {
    services.ollama.listenAddress = "0.0.0.0:${toString cfg.port}";
    networking = {
      firewall = {
        allowedTCPPorts = [ cfg.port ];
      };
    };
  };
}