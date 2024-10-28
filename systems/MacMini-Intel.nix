{ config, ... }:
{
  profiles = {
    defaults.enable = true;
    dev.enable = true;
    gui.enable = true;
  };
  userPresets.toyvo.enable = true;
  services.github-runners = {
    nh_darwin = {
      enable = true;
      name = "MacMini-Intel";
      tokenFile = "/var/secrets/gha_nh_darwin";
      url = "https://github.com/toyvo/nh_darwin";
    };
  };
}
