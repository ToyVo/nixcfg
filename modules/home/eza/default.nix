{ lib, config, pkgs, ... }:
let
  cfg = config.programs.eza;
  # eza.enableAliases adds aliases to nushell which is unwanted
  aliases = {
    ls = "eza";
    ll = "eza -l";
    la = "eza -a";
    lt = "eza -T";
    lla = "eza -la";
    lta = "eza -Ta";
  };
in
{
  config = lib.mkIf cfg.enable {
    programs = {
      bash.shellAliases = aliases;
      zsh.shellAliases = aliases;
      fish.shellAliases = aliases;
      nushell.shellAliases = {
        ll = "ls -l";
        la = "ls -a";
        lla = "ls -la";
        lt = "eza -T";
        lta = "eza -Ta";
      };
    };
  };
}
