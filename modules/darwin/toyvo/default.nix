{ lib, config, ... }:
let
  cfg = config.cd;
in
{
  imports = [
    ../../nixos/toyvo/common.nix
  ];

  config =
    let
      homeDirectory = "/Users/${cfg.users.toyvo.name}";
    in
    lib.mkIf cfg.users.toyvo.enable {
      users.users.${cfg.users.toyvo.name}.home = lib.mkForce homeDirectory;
      home-manager.users.${cfg.users.toyvo.name} = {
        home.homeDirectory = lib.mkForce homeDirectory;
        home.sessionPath = [ "$HOME/.local/bin" "/opt/homebrew/bin" ];
        home.file.".hushlogin".text = "";
      };
    };
}

