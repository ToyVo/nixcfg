{ pkgs, ... }: {
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];
  programs.zsh.enable = true;
  nixpkgs.config.allowUnfree = true;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
}
