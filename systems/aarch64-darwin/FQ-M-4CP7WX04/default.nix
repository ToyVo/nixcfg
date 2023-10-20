{ pkgs, ... }: {
      cd.defaults.enable = true;
      cd.users.toyvo = {
        enable = true;
        name = "CollinDie";
        extraHomeManagerModules = [
          {
            cd.emu.enable = true;
          }
        ];
      };
      homebrew = {
        brews = [
          "mongosh"
          "mongodb-community@4.4"
          "mongodb-community-shell@4.4"
          "mongodb-database-tools"
        ];
        casks = [
          { name = "docker"; greedy = true; }
          { name = "mongodb-compass"; greedy = true; }
          { name = "slack"; greedy = true; }
        ];
        taps = [
          "mongodb/brew"
        ];
        masApps = {
          "Yubico Authenticator" = 1497506650;
        };
      };
    }