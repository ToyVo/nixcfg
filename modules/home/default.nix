{ pkgs, lib, ... }: {
  imports = [ ./alias-home-apps.nix ./users ./programs ];

  options.home.symlinkPackage = lib.mkOption {
    type = lib.types.package;
    default = pkgs.emptyDirectory;
    description = "Package to be symlinked into the user's .local directory";
    example = lib.literalExpression "pkgs.buildEnv { name = \"home-local-symlink\"; paths = [ pkgs.hello ]; }";
  };
}
