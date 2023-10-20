{ lib, config, pkgs, ... }:
let
  cfg = config.cd;
in
{
  options.cd.packages.ssh.enable = lib.mkEnableOption "Enable ssh" // {
    default = true;
  };

  config = lib.mkIf cfg.packages.ssh.enable {
    programs.ssh = {
      enable = true;
      matchBlocks."10.1.0.*" = {
        identitiesOnly = true;
        identityFile = "${./ssh_yubikey.pub}";
        extraOptions.AddKeysToAgent = "yes";
      };
      matchBlocks."github.com" = {
        identitiesOnly = true;
        identityFile = "${./ssh_yubikey.pub}";
        extraOptions.AddKeysToAgent = "yes";
      };
    };
  };
}
