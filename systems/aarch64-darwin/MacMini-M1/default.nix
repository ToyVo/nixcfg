{ ... }: {
      cd.defaults.enable = true;
      cd.users.toyvo.enable = true;
      homebrew.casks = [
        { name = "prusaslicer"; greedy = true; }
        { name = "google-chrome"; greedy = true; }
      ];
    }