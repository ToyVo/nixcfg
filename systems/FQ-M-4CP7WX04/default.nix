{ config, pkgs, ... }:
let
  cfg = config.userPresets;
in
{
  profiles.defaults.enable = true;
  userPresets.toyvo = {
    enable = true;
    name = "CollinDie";
  };
  home-manager.users.${cfg.toyvo.name} = import ./home.nix;
  environment.systemPackages = with pkgs; [
    ollama
    awscli2
    llama-cpp
  ];
  environment.pythonPackages = with pkgs.python311Packages; [
    boto3
    typer
    openai
    sagemaker
    huggingface-hub
    datasets
    transformers
    torch
    jax
    pymongo
  ];
  homebrew = {
    brews = [
      "mongosh"
      "mongodb-community@4.4"
      "mongodb-community-shell@4.4"
      "mongodb-database-tools"
    ];
    casks = [
      { name = "mongodb-compass"; greedy = true; }
      { name = "slack"; greedy = true; }
      { name = "keybase"; greedy = true; }
      # must be installed at /Applications, nix-darwin installs it at /Applications/nix apps
      { name = "1password"; greedy = true; }
      { name = "prusaslicer"; greedy = true; }
    ];
    taps = [
      "mongodb/brew"
    ];
    masApps = {
      "Yubico Authenticator" = 1497506650;
    };
  };
}
