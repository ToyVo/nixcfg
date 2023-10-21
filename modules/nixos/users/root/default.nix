{ lib, pkgs, config, ... }: {
  options.cd.users.root = {
    enable = lib.mkEnableOption "root user";
    extraHomeManagerModules = lib.mkOption {
      type = lib.types.listOf lib.types.raw;
      default = [ ];
    };
  };

  config = lib.mkIf config.cd.users.root.enable {
    users.users.root = {
      name = "root";
      home = "/root";
      shell = pkgs.zsh;
    };
    home-manager.users.root = {
      home.username = "root";
      home.homeDirectory = "/root";
      home.stateVersion = "23.05";
      xdg.configFile."nix/nix.conf".text = ''
        experimental-features = nix-command flakes
      '';
      xdg.configFile."nixpkgs/config.nix".text = ''
        { allowUnfree = true; }
      '';
      programs.home-manager.enable = true;
      programs.starship.enable = true;

      imports = [
      ] ++ config.cd.users.root.extraHomeManagerModules;
    };
  };
}
