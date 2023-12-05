{ lib, config, pkgs, ... }:
let
  cfg = config.cd;
  # eza.enableAliases adds aliases to nushell which is unwanted
  aliases = {
    ls = "eza";
    ll = "eza -l";
    la = "eza -a";
    lt = "eza -T";
    lla = "eza -la";
  };
in
{
  options.cd.packages.eza.enable = lib.mkEnableOption "Enable eza";

  config = lib.mkIf cfg.packages.eza.enable {
    programs = {
      eza.enable = true;
      bash.shellAliases = aliases;
      zsh.shellAliases = aliases;
      fish.shellAliases = aliases;
      nushell.shellAliases = {
        ll = "ls -l";
        la = "ls -a";
        lla = "ls -la";
        lt = "eza -T";
      };
    };
  };
}
