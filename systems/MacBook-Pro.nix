{pkgs, ...}: {
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
    }
    {
      name = "blender";
    }
    {
      name = "discord";
    }
    {
      name = "steam";
    }
    {
      name = "obs";
    }
    {
      name = "prusaslicer";
    }
    {
      name = "whisky";
    }
  ];
  homebrew.masApps = {
    "Yubico Authenticator" = 1497506650;
    "Wireguard" = 1451685025;
  };
}
