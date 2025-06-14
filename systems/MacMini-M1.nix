{ config, ... }:
{
  profiles = {
    defaults.enable = true;
    dev.enable = true;
  };
  userPresets.toyvo.enable = true;
  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    port = config.homelab.${config.networking.hostname}.services.ollama.port;
  };
}
