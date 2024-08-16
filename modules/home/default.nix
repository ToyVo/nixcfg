{ pkgs, lib, config, nix_home_files, system, ... }: {
  imports = [ ./alias-home-apps.nix ./users ./programs ];

  options.home = {
    symlinkPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.buildEnv { name = "home-symlink-packages"; paths = config.home.symlinkPackages; };
      description = "Package to be symlinked into the user's .local directory";
      internal = true;
    };
    symlinkPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Packages to be symlinked into the user's .local directory";
    };
  };

  config =
    let
      command = nix_home_files.packages.${system}.default;
      files = pkgs.runCommand "list_files" { } ''
        ${command}/bin/nix_home_files ${config.home.symlinkPackage} > $out
      '';
    in
    {
      home.file = builtins.fromJSON (builtins.unsafeDiscardStringContext (builtins.readFile files));
      sops = {
        defaultSopsFile = ../../secrets/secrets.yaml;
        age = {
          sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
        };
      };
    };
}
