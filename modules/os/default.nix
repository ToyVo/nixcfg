{
  config,
  lib,
  self,
  ...
}@inputs:
let
  cfg = config.profiles;
in
{
  imports = [
    ./users
    ./podman.nix
    ./gui.nix
    ./dev.nix
    ./console.nix
  ];

  options.profiles.defaults.enable = lib.mkEnableOption "Enable Defaults";

  config = lib.mkIf cfg.defaults.enable {
    home-manager = {
      backupFileExtension = "${self.shortRev or self.dirtyShortRev}.old";
      useUserPackages = true;
      sharedModules = [
        {
          nix.package = lib.mkForce config.nix.package;
          home.sessionVariables.NIXPKGS_ALLOW_UNFREE = 1;
        }
      ];
    };
    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        substituters = config.nix.settings.trusted-substituters;
        trusted-substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://toyvo.cachix.org"
          "https://nixcache.diekvoss.net"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "toyvo.cachix.org-1:s++CG1te6YaS9mjICre0Ybbya2o/S9fZIyDNGiD4UXs="
          "nixcache.diekvoss.net:31yGqcL45nEZ73gLt569UoAopxWOfC5bactGqU9C9mI="
        ];
      };
      nixPath = [
        "nixpkgs=${inputs.nixpkgs}"
      ];
    };
    sops = {
      defaultSopsFile = ../../secrets/secrets.yaml;
      age.keyFile = "/var/sops/age/keys.txt";
    };
  };
}
