{ config, pkgs, ... }:
{
  home.stateVersion = "22.11";
  home.sessionVariables = {
    GPG_TTY = "$(tty)";
    SSH_AUTH_SOCK = "$(gpgconf --list-dirs agent-ssh-socket)";
    KEYID = "FAB3032CC9513440";
  };
  home.sessionPath = [
    "$HOME/.local/bin"
  ];
  home.shellAliases = {
    cat = "bat -pp";
    tree = "exa --tree";
    gpg-scan-card = ''gpg-connect-agent "scd serialno" "learn --force" /bye'';
  };
  home.packages = with pkgs; [
    git-crypt
    ripgrep
    fd
  ];
  xdg.configFile."ideavim/ideavimrc".source = ./assets/ideavimrc;
  xdg.configFile."nix/nix.conf".text = '' experimental-features = nix-command flakes '';
  programs.home-manager.enable = true;
  programs.bat.enable = true;
  programs.exa.enable = true;
  programs.exa.enableAliases = true;
}
