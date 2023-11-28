{ lib, pkgs, config, ... }:
let
  cfg = config.cd;
  homeDirectory = "/home/${cfg.users.toyvo.name}";
  key = lib.fileContents ../../../home/packages/ssh/ssh_yubikey.pub;
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

  config = lib.mkIf cfg.users.toyvo.enable {
    users.users.${cfg.users.toyvo.name} = {
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
      xdg.configFile."nixpkgs/config.nix".text = ''
        { allowUnfree = true; }
      '';
      programs.home-manager.enable = true;
      programs.starship.enable = true;
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
      imports = [
        {
          options.cd.username = lib.mkOption {
            type = lib.types.str;
            default = cfg.users.toyvo.name;
          };
          config.cd.packages = {
            bat.enable = true;
            eza.enable = true;
            git.enable = true;
            gpg.enable = true;
            helix.enable = true;
            rio.enable = cfg.packages.gui.enable;
            ssh.enable = true;
            vscode.enable = cfg.packages.gui.enable;
            wezterm.enable = cfg.packages.gui.enable;
            zellij.enable = true;
            zsh.enable = true;
            bash.enable = true;
            nushell.enable = true;
          };
        }
      ] ++ cfg.users.toyvo.extraHomeManagerModules;
    };
  };
}
