{ pkgs, ... }: {
  profiles.defaults.enable = true;
  userPresets.toyvo = {
    enable = true;
    name = "CollinDie";
    extraHomeManagerModules = [
      ./secrets.nix
      {
        programs = {
          ssh.matchBlocks."github-emu" = {
            hostname = "github.com";
            identitiesOnly = true;
            identityFile = "~/.ssh/emu_ed25519";
          };
          gpg.publicKeys = [{
            source = ../../../secrets/gpg_emu.pub;
            trust = 5;
          }];
          volta.enable = true;
        };
      }
    ];
  };
  environment.systemPackages = with pkgs; [
    ollama
    poetry
    awscli2
    (python3.withPackages (ps: with ps; [
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
