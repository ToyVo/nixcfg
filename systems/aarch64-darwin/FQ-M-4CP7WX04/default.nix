{ pkgs, ... }: {
  cd.defaults.enable = true;
  cd.users.toyvo = {
    enable = true;
    name = "CollinDie";
    extraHomeManagerModules = [
      ./secrets.nix
      {
        programs = {
          ssh.matchBlocks."github-emu" = {
            hostname = "github.com";
            identitiesOnly = true;
            identityFile = "~/.ssh/ykW_ed25519_sk";
          };
          gpg.publicKeys = [{
            source = ../../../secrets/gpg_emu.pub;
            trust = 5;
          }];
          zsh.profileExtra = ''
            export PATH="$VOLTA_HOME/bin:$PATH"
          '';
          fish.shellInit = ''
            set PATH $VOLTA_HOME/bin $PATH
          '';
          nushell.envFile.text = ''
            $env.VOLTA_HOME = $'($env.HOME)/.volta'
            $env.PATH = ($env.PATH | prepend $'($env.VOLTA_HOME)/bin')
          '';
        };
        home.packages = with pkgs;
          [
            awscli2
            volta
          ];
        home.sessionVariables = {
          VOLTA_HOME = "$HOME/.volta";
          NODE_ENV = "development";
          RUN_ENV = "local";
        };
      }
    ];
  };
  environment.systemPackages = with pkgs; [
    ollama
    (python3.withPackages(ps: with ps; [
      jupyter
      virtualenv
      pip
      openai
      python-dotenv
    ]))
  ];
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
