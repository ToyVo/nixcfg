{ pkgs, lib, config, self, system, ... }: {
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

  config = {
    home.file = self.lib.${system}.getFiles config.home.symlinkPackage;
  };
}
