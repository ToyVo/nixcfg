{ config, lib, ... }: 
let 
  cfg = config.services.ollama;
in
{
  options.services.ollama.openFirewall = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Whether to open the firewall for the Ollama service.";
  };

  config = lib.mkIf cfg.enable {
    networking = lib.mkIf cfg.openFirewall {
      firewall = {
        allowedTCPPorts = [ 11434 ];
        allowedUDPPorts = [ 11434 ];
      };
    };
  };
}