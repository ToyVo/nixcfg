{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    defaultKeymap = "viins";
    initExtra = ''
      setopt globdots
      zstyle ':completion:*' matcher-list ''' '+m:{a-zA-Z}={A-Za-z}' '+r:|[._-]=* r:|=*' '+l:|=* r:|=*'
      gpgconf --launch gpg-agent
      if [ -z "$SSH_TTY" ] && [ -z "$SSH_CLIENT" ] && [ -z "$SSH_CONNECTION" ]; then
        if [ -z "$TERMINAL_EMULATOR" ] || [ "$TERMINAL_EMULATOR" != "JetBrains-JediTerm" ]; then
          eval "$(zellij setup --generate-auto-start zsh)"
        fi
      fi
    '';
    profileExtra = ''
      export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    '';
    plugins = [{
      name = "zsh-nix-shell";
      file = "nix-shell.plugin.zsh";
      src = pkgs.fetchFromGitHub {
        owner = "chisui";
        repo = "zsh-nix-shell";
        rev = "v0.5.0";
        sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
      };
    }];
  };
}
