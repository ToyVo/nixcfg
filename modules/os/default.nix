{
  config,
  lib,
  self,
  pkgs,
  nixos-unstable,
  ...
}:
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
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [
        {
          nix.package = lib.mkForce config.nix.package;
        }
      ];
    };
    nix = {
      package = pkgs.nixVersions.nix_2_22;
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        substituters = config.nix.settings.trusted-substituters;
        trusted-substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://cosmic.cachix.org"
          "https://toyvo.cachix.org"
          "https://eigenvalue.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
          "toyvo.cachix.org-1:s++CG1te6YaS9mjICre0Ybbya2o/S9fZIyDNGiD4UXs="
          "eigenvalue.cachix.org-1:ykerQDDa55PGxU25CETy9wF6uVDpadGGXYrFNJA3TUs="
        ];
      };
      nixPath = [
        "nixpkgs=${nixos-unstable}"
        "nixos=${nixos-unstable}"
      ];
    };
  };
}
