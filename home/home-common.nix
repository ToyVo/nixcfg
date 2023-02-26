{ config, pkgs, ... }:
{
  home.stateVersion = "22.11";
  home.sessionVariables = {
    GPG_TTY = "$(tty)";
    SSH_AUTH_SOCK = "$(gpgconf --list-dirs agent-ssh-socket)";
  };
  home.shellAliases = {
    cat = "bat -pp";
    tree = "exa --tree";
    gpg-scan-card = ''gpg-connect-agent "scd serialno" "learn --force" /bye'';
  };
  home.packages = with pkgs; [
    neovide
  ];
  xdg.configFile."ideavim/ideavimrc".source = ./assets/ideavimrc;
  programs.home-manager.enable = true;
  programs.bat.enable = true;
  programs.exa.enable = true;
  programs.exa.enableAliases = true;
}
