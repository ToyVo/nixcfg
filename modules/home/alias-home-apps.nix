{ config, home-manager, lib, mkAlias, pkgs, system, ... }:
let
  cfg = config.targets.darwin;
  mkalias = mkAlias.outputs.apps.${system}.default.program;
  apps = pkgs.buildEnv {
    name = "home-manager-applications";
    paths = config.home.packages;
    pathsToLink = "/Applications";
  };
in
{
  options.targets.darwin.aliasHomeApplications = lib.mkEnableOption "Alias Home Manager Applications in ~/Applications/Home Manager Apps";

  config = lib.mkIf cfg.aliasHomeApplications {
    home.file."Applications/Home Manager Apps".enable = false;
    home.activation.aliasApplications = home-manager.lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      ${pkgs.coreutils}/bin/echo "setting up ~/Applications/Home Manager Apps..." >&2
      app_path="$HOME/Applications/Home Manager Apps"
      tmp_path=$(mktemp -dt "home-manager-applications.XXXXXX") || exit 1
      if [[ -d "$app_path" ]]; then
        $DRY_RUN_CMD rm -rf "$app_path"
      fi
      ${pkgs.fd}/bin/fd -t l -d 1 . ${apps}/Applications -x $DRY_RUN_CMD ${mkalias} -L {} "$tmp_path/{/}"
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/mv "$tmp_path" "$app_path"
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/chmod -R 775 "$app_path"
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/chgrp -R staff "$app_path"
    '';
  };
}
