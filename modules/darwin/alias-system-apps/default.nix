{ pkgs, lib, inputs, config, system, ... }:
let
  mkalias = inputs.mkAlias.outputs.apps.${system}.default.program;
  cfg = config.cd;
in
{
  options.cd.darwin.aliasSystemApplications = lib.mkEnableOption "Alias system applications";

  config = lib.mkIf cfg.darwin.aliasSystemApplications {
    system.activationScripts.applications.text = lib.mkForce ''
      ${pkgs.coreutils}/bin/echo "setting up /Applications/Nix Apps..." >&2
      app_path="/Applications/Nix Apps"
      tmp_path=$(mktemp -dt "nix-darwin-applications.XXXXXX") || exit 1
      if [[ -d "$app_path" ]]; then
        $DRY_RUN_CMD rm -rf "$app_path"
      fi
      ${pkgs.fd}/bin/fd -t l -d 1 . ${config.system.build.applications}/Applications -x $DRY_RUN_CMD ${mkalias} -L {} "$tmp_path/{/}"
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/mv "$tmp_path" "$app_path"
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/chmod -R 775 "$app_path"
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/chgrp -R staff "$app_path"
    '';
  };
}
