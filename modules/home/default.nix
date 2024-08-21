{  ... }: {
  imports = [ ./alias-home-apps.nix ./users ./programs ];

  config = {
      sops = {
        defaultSopsFile = ../../secrets/secrets.yaml;
        age = {
          sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        };
      };
    };
}
