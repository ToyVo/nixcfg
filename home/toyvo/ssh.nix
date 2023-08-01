{ lib, config, pkgs, ... }:
let
  cfg = config.cdcfg.ssh;
in
{
  options.cdcfg.ssh.enable = lib.mkEnableOption "Enable ssh" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      matchBlocks."10.1.0.*" = {
        identitiesOnly = true;
        identityFile = "${./keys/ssh_yubikey.pub}";
        extraOptions.AddKeysToAgent = "yes";
      };
      matchBlocks."github.com" = {
        identitiesOnly = true;
        identityFile = "${./keys/ssh_yubikey.pub}";
        extraOptions.AddKeysToAgent = "yes";
      };
    };
  };
}
