{ pkgs, ... }:
{
  ids.gids.nixbld = 350;
  profiles = {
    defaults.enable = true;
    dev.enable = true;
    gui.enable = true;
  };
  userPresets.toyvo.enable = true;
  environment.systemPackages = with pkgs; [
    # openscad
    ollama
    prismlauncher
    packwiz
    vlc-bin
  ];
  homebrew.casks = [
    {
      name = "freecad";
      greedy = true;
    }
    {
      name = "blender";
      greedy = true;
    }
    {
      name = "discord";
    }
    {
      name = "steam";
    }
    {
      name = "obs";
      greedy = true;
    }
    {
      name = "prusaslicer";
      greedy = true;
    }
    {
      name = "whisky";
      greedy = true;
    }
  ];
  homebrew.masApps = {
    "Yubico Authenticator" = 1497506650;
    "Wireguard" = 1451685025;
  };
}
