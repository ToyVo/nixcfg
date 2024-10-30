{ pkgs, ... }:
{
  profiles = {
    defaults.enable = true;
    dev.enable = true;
    gui.enable = true;
  };
  userPresets.toyvo.enable = true;
  homebrew.casks = [
    {
      name = "prusaslicer";
      greedy = true;
    }
    {
      name = "google-chrome";
      greedy = true;
    }
  ];
  nix.settings.trusted-users = [ "_github-runner" ];
  users.users._github-runner.home = "/private/var/lib/github-runners";
  services.github-runners = {
    nh_darwin = {
      enable = true;
      name = "MacMini-M1";
      tokenFile = "/var/secrets/gha_nh_darwin";
      url = "https://github.com/toyvo/nh_darwin";
      extraPackages = with pkgs; [
        nixVersions.nix_2_22
        jq
        cachix
      ];
    };
    nur-packages = {
      enable = true;
      name = "MacMini-M1";
      tokenFile = "/var/secrets/gha_nur";
      url = "https://github.com/toyvo/nur-packages";
      extraPackages = with pkgs; [
        nixVersions.nix_2_22
        jq
        cachix
      ];
    };
  };
}
