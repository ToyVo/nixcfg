{
  programs.zsh.enable = true;
  nixpkgs.config.allowUnfree = true;
  nix.extraOptions = ''experimental-features = nix-command flakes'';
}
