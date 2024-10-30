{ pkgs, ... }:
{
  profiles = {
    defaults.enable = true;
    dev.enable = true;
    gui.enable = true;
  };
  userPresets.toyvo.enable = true;
  users.users._github-runner.home = "/private/var/lib/github-runners";
  nix.settings.trusted-users = [ "_github-runner" ];
  services.github-runners = {
    nh_darwin = {
      enable = true;
      name = "MacMini-Intel";
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
      name = "MacMini-Intel";
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
