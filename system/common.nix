{pkgs, nixpkgs, ...}: {
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];
  nixpkgs.config = {
    allowUnfree = true;
  };
  nix.extraOptions = ''experimental-features = nix-command flakes'';
}
