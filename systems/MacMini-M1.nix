{ ... }:
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
}
