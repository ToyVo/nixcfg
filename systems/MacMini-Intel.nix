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
    nh_plus = {
      enable = true;
      name = "MacMini-Intel_nh_plus";
      tokenFile = "/var/secrets/gha_nh_plus";
      url = "https://github.com/toyvo/nh_plus";
      extraPackages = with pkgs; [
        nixVersions.nix_2_22
        cachix
      ];
    };
    nur-packages = {
      enable = true;
      name = "MacMini-Intel_nur";
      tokenFile = "/var/secrets/gha_nur";
      url = "https://github.com/toyvo/nur-packages";
      extraPackages = with pkgs; [
        nixVersions.nix_2_22
        cachix
      ];
    };
  };
}
