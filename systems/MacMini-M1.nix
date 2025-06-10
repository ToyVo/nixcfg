{ ... }:
{
  profiles = {
    defaults.enable = true;
    dev.enable = true;
    gui.enable = true;
  };
  userPresets.toyvo.enable = true;
  services.ollama = {
    enable = true;
    models = "/var/lib/ollama/models";
    host = "0.0.0.0";
  };
}
