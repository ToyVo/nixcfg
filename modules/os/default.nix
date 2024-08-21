{ config, lib, self, pkgs, nixos-unstable, ... }:
let
  cfg = config.profiles;
in
{
  imports = [ ./users ./podman.nix ./gui.nix ./dev.nix ./console.nix ];

  options.profiles.defaults.enable = lib.mkEnableOption "Enable Defaults";

  config = lib.mkIf cfg.defaults.enable {
    home-manager = {
      backupFileExtension = "${toString self.sourceInfo.lastModified}.old";
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [{
        nix.package = lib.mkForce config.nix.package;
      }];
    };
    nix = {
      package = pkgs.nixVersions.nix_2_22;
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        substituters = config.nix.settings.trusted-substituters;
        trusted-substituters = [
          "https://nix-community.cachix.org"
          "https://cosmic.cachix.org/"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
        ];
      };
      nixPath = [ "nixpkgs=${nixos-unstable}" "nixos=${nixos-unstable}" ];
    };
  };
}
