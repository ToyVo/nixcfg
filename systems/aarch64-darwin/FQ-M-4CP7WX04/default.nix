{ pkgs, ... }: {
  profiles.defaults.enable = true;
  userPresets.toyvo = {
    enable = true;
    name = "CollinDie";
  };
  environment.systemPackages = with pkgs; [
    ollama
    poetry
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
    pipx
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
      # must be installed at /Applications, nix-darwin installs it at /Applications/nix apps
      { name = "1password"; greedy = true; }
    ];
    taps = [
      "mongodb/brew"
    ];
    masApps = {
      "Yubico Authenticator" = 1497506650;
    };
  };
}
