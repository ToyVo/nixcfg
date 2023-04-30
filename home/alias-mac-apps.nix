{ pkgs, lib, inputs, system, config, ... }:
let mkalias = inputs.mkAlias.outputs.apps.${system}.default.program;
in {

  disabledModules = [ "targets/darwin/linkapps.nix" ];
  home.activation.aliasApplications = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
    (let
      apps = pkgs.buildEnv {
        name = "home-manager-applications";
        paths = config.home.packages;
        pathsToLink = "/Applications";
      };
    in lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      echo "Linking Home Manager applications..."
      # only link per-user applications
      app_path="$HOME/Applications/Home Manager Apps"
      tmp_path=$(mktemp -dt "home-manager-applications.XXXXXX") || exit 1
      if [[ -d "$app_path" ]]; then
        $DRY_RUN_CMD rm -rf "$app_path"
      fi
      ${pkgs.fd}/bin/fd -t l -d 1 . ${apps}/Applications -x $DRY_RUN_CMD ${mkalias} -L {} "$tmp_path/{/}"
      $DRY_RUN_CMD mv "$tmp_path" "$app_path"
    '');
}

