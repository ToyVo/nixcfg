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
    awscli2
    llama-cpp
    ollama
  ];
  environment.pythonPackages = with pkgs.python311Packages; [
    boto3
    datasets
    huggingface-hub
    jax
    openai
    pymongo
    sagemaker
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
      # must be installed at /Applications, nix-darwin installs it at /Applications/nix apps
      { name = "1password"; greedy = true; }
      { name = "keybase"; greedy = true; }
      { name = "mongodb-compass"; greedy = true; }
      { name = "prusaslicer"; greedy = true; }
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
