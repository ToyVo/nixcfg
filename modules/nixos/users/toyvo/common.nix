{ lib, pkgs, config, ... }:
let
  cfg = config.userPresets.toyvo;
  homeDirectory = if pkgs.stdenv.isDarwin then 
    "/Users/${cfg.name}" else 
    "/home/${cfg.name}";
  enableGui = config.profiles.gui.enable;
in
{
  options.userPresets.toyvo = {
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

  config = lib.mkIf cfg.enable {
    users.users.${cfg.name} = {
      name = cfg.name;
      description = "Collin Diekvoss";
      home = homeDirectory;
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        (lib.fileContents ../../../../secrets/ykA_ed25519_sk.pub)
        (lib.fileContents ../../../../secrets/ykC_ed25519_sk.pub)
      ];
    };
    home-manager.users.${cfg.name} = {
      home.username = cfg.name;
      home.homeDirectory = homeDirectory;
      home.stateVersion = "24.05";
      home.sessionVariables = {
        EDITOR = "nvim";
      };
      home.sessionPath = [ "$HOME/.local/bin" ];
      home.packages = with pkgs; [
        lazygit
      ];
      xdg.configFile."ideavim/ideavimrc".source = ./ideavimrc;
      xdg.configFile."nix/nix.conf".text = ''
        experimental-features = nix-command flakes
      '';
      xdg.configFile."nixpkgs/config.nix".text = ''
        { allowUnfree = true; }
      '';
      programs.home-manager.enable = true;
      programs.starship = {
        enable = true;
        settings = {
          right_format = "$time";
          time.disabled = false;
        };
      };
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
      programs.zoxide.enable = true;
      programs.bat.enable = true;
      programs.eza.enable = true;
      programs.git.enable = true;
      programs.gpg.enable = true;
      programs.helix.enable = true;
      programs.rio.enable = enableGui;
      programs.ssh.enable = true;
      programs.vscode.enable = enableGui;
      programs.wezterm.enable = enableGui;
      programs.kitty.enable = enableGui;
      programs.zellij.enable = true;
      programs.zsh.enable = true;
      programs.bash.enable = true;
      programs.fish.enable = true;
      programs.nushell.enable = true;
      imports = [] ++ cfg.extraHomeManagerModules;
    };
  };
}
