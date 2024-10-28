{ config, ... }:
{
  profiles = {
    defaults.enable = true;
    dev.enable = true;
    gui.enable = true;
  };
  userPresets.toyvo.enable = true;
  homebrew.casks = [
    {
      name = "prusaslicer";
      greedy = true;
    }
    {
      name = "google-chrome";
      greedy = true;
    }
  ];
  services.github-runners = {
    nh_darwin = {
      enable = true;
      name = "MacMini-M1";
      tokenFile = "/var/secrets/gha_nh_darwin";
      url = "https://github.com/toyvo/nh_darwin";
    };
  };
}
