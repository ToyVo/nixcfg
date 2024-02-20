{ pkgs, ... }: {
  profiles.defaults.enable = true;
  users.presets.toyvo.enable = true;
  environment.systemPackages = with pkgs; [
    openscad
  ];
  homebrew.casks = [
    { name = "prusaslicer"; greedy = true; }
  ];
  homebrew.masApps = {
    "Yubico Authenticator" = 1497506650;
    "Wireguard" = 1451685025;
  };
}
