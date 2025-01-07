{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    ./users
    ./programs
  ];

  config = {
    sops = {
      defaultSopsFile = ../../secrets/secrets.yaml;
      age = {
        sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };
    };
    home.packages = lib.optionals (config.launchd.agents ? sops-nix) [
      (pkgs.writeShellScriptBin "sops-nix-user" "${config.launchd.agents.sops-nix.config.Program}")
    ];
  };
}
