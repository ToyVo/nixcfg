{ lib, pkgs, config, ... }:
let
  cfg = config.cd;
in
{
  options.cd.users.toyvo = {
    enable = lib.mkEnableOption "toyvo user";
    name = lib.mkOption {
      type = lib.types.str;
      default = "toyvo";
    };
    extraHomeManagerModules = lib.mkOption {
      type = lib.types.listOf lib.types.raw;
      default = [ ];
    };
  };

  config =
    let
      homeDirectory = "/home/${cfg.users.toyvo.name}";
      key = lib.fileContents ../../home/ssh/ssh_yubikey.pub;

    in
    lib.mkIf cfg.users.toyvo.enable {
      users.users.${cfg.users.toyvo.name} =
        {
          name = cfg.users.toyvo.name;
          description = "Collin Diekvoss";
          home = homeDirectory;
          shell = pkgs.zsh;
          openssh.authorizedKeys.keys = [ key ];
        };
      home-manager.users.${cfg.users.toyvo.name} = {
        home.username = cfg.users.toyvo.name;

        home.homeDirectory = homeDirectory;
        home.stateVersion = "23.05";
        home.sessionVariables = {
          EDITOR = "nvim";
        };
        home.sessionPath = [ "$HOME/.local/bin" ];
        xdg.configFile."ideavim/ideavimrc".source = ./ideavimrc;
        xdg.configFile."nix/nix.conf".text = ''
          experimental-features = nix-command flakes
        '';
        programs.home-manager.enable = true;
        programs.starship.enable = true;
        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
        };

        imports = [
          ../../home/bat
          ../../home/eza
          ../../home/git
          ../../home/gpg
          ../../home/ssh
          ../../home/wezterm
          ../../home/zellij
          ../../home/zsh
          ../../home/vscode
          ../../home/helix
          ../../home/rio
        ] ++ cfg.users.toyvo.extraHomeManagerModules;
      };
    };
}