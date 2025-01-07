{ pkgs, lib, ... }:
{
  profiles = {
    defaults.enable = true;
    dev.enable = true;
    gui.enable = true;
  };
  userPresets.toyvo.enable = true;
  users.users._github-runner.home = lib.mkForce "/private/var/lib/github-runners";
  nix.settings.trusted-users = [ "_github-runner" ];
  services.github-runners = {
    nur-packages = {
      enable = true;
      name = "MacMini-Intel_nur";
      tokenFile = "/var/secrets/gha_nur";
      url = "https://github.com/toyvo/nur-packages";
      extraPackages = with pkgs; [
        cachix
        curl
      ];
    };
  };
}
