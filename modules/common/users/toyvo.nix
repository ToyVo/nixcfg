{ config, lib, pkgs, ... }:
let
  cfg = config.userPresets;
  homePath =
    if pkgs.stdenv.isDarwin then
      "/Users" else
      "/home";
  enableGui = config.profiles.gui.enable;
in
{
  options.userPresets = {
    toyvo = {
      enable = lib.mkEnableOption "toyvo user";
      name = lib.mkOption {
        type = lib.types.str;
        default = "toyvo";
      };
    };
  };

  config = {
    users.users = {
      ${cfg.toyvo.name} = lib.mkIf cfg.toyvo.enable (lib.mkMerge [{
        name = cfg.toyvo.name;
        description = "Collin Diekvoss";
        home = "${homePath}/${cfg.toyvo.name}";
        shell = pkgs.fish;
        openssh.authorizedKeys.keys = [
          (lib.fileContents ./ykA_ed25519_sk.pub)
          (lib.fileContents ./ykC_ed25519_sk.pub)
        ];
      }
        (lib.mkIf
          pkgs.stdenv.isLinux
          {
            isNormalUser = true;
            extraGroups = [ "networkmanager" "wheel" ] ++ lib.optionals config.containerPresets.podman.enable [ "podman" ];
            initialHashedPassword = "$y$j9T$tkZ4b5vK1fCsRP0oWUb0e1$w0QbUEv9swXir33ivvM70RYTYflQszeLBi3vubYTqd8";
          })]);
    };
    nix.settings.trusted-users = [
      cfg.toyvo.name
    ];
    home-manager.users.${cfg.toyvo.name} = lib.mkIf cfg.toyvo.enable {
      home.username = cfg.toyvo.name;
      home.homeDirectory = "${homePath}/${cfg.toyvo.name}";
      profiles.toyvo.enable = true;
      profiles.gui.enable = enableGui;
    };
  };
}

