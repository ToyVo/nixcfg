{ config, pkgs, ... }:
let
  cfg = config.userPresets;
in
{
  profiles = {
    defaults.enable = true;
    dev.enable = true;
    gui.enable = true;
  };
  userPresets.toyvo = {
    enable = true;
    name = "CollinDie";
  };
  home-manager.users.${cfg.toyvo.name} = import ./home.nix;
  environment.systemPackages = with pkgs; [
    awscli2
    llama-cpp
    ollama
    vlc-bin
  ];
  environment.pythonPackages = with pkgs.python312Packages; [
    boto3
    datasets
    huggingface-hub
    openai
    pymongo
    torch
    transformers
    typer
  ];
  homebrew = {
    brews = [
      "mongodb-community-shell@4.4"
      "mongodb-community@4.4"
      "mongodb-database-tools"
      "mongosh"
    ];
    casks = [
      {
        name = "keybase";
        greedy = true;
      }
      {
        name = "mongodb-compass";
        greedy = true;
      }
      {
        name = "obs";
        greedy = true;
      }
      {
        name = "slack";
        greedy = true;
      }
      {
        name = "docker";
        greedy = true;
      }
    ];
    taps = [
      "mongodb/brew"
    ];
    masApps = {
      "Yubico Authenticator" = 1497506650;
    };
  };
}
