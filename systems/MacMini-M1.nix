{ homelab, ... }:
{
  profiles = {
    defaults.enable = true;
    dev.enable = true;
  };
  userPresets.toyvo.enable = true;
  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    port = homelab.MacMini-M1.services.ollama.port;
  };
}
