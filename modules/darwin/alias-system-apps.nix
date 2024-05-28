{ config, lib, mkAlias, pkgs, system, ... }:
let
  cfg = config.system.defaults.finder;
  mkalias = mkAlias.outputs.apps.${system}.default.program;
  apps = config.system.build.applications;
in
{
  options.system.defaults.finder.AliasSystemApplications = lib.mkEnableOption "Alias system applications";

  config = lib.mkIf cfg.AliasSystemApplications {
    system.activationScripts.applications.text = lib.mkForce ''
      echo "setting up /Applications/Nix Apps..." >&2
      app_path="/Applications/Nix Apps"
      tmp_path=$(mktemp -dt "nix-darwin-applications.XXXXXX") || exit 1
      if [[ -d "$app_path" ]]; then
        $DRY_RUN_CMD rm -rf "$app_path"
      fi
      ${pkgs.fd}/bin/fd -t l -d 1 . ${apps}/Applications -x $DRY_RUN_CMD ${mkalias} -L {} "$tmp_path/{/}"
      $DRY_RUN_CMD mv "$tmp_path" "$app_path"
      $DRY_RUN_CMD chmod -R 775 "$app_path"
      $DRY_RUN_CMD chgrp -R staff "$app_path"
    '';
  };
}
