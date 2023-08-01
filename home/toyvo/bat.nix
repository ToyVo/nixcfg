{ lib, config, pkgs, ... }:
let
  cfg = config.cdcfg.bat;
in
{
  options.cdcfg.bat.enable = lib.mkEnableOption "Enable bat" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    programs.bat = {
      enable = true;
      themes = {
        everforest-dark = builtins.readFile (pkgs.fetchFromGitHub
          {
            owner = "mhanberg";
            repo = "everforest-textmate";
            rev = "aa1850676e2c2908e7c5cf5ea7863b130fd65016";
            sha256 = "1rr2b08k95812nchr0c7a9s4qwlawykrh96zdfn55y6k7x5b2rz0";
          } + "/Everforest Dark/Everforest Dark.tmTheme");
      };
      config.theme = "everforest-dark";
    };
    home.sessionVariables = {
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    };
    home.shellAliases = {
      cat = "bat -pp";
    };
  };
}
