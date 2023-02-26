{ pkgs, ... }: {
  home.packages = with pkgs; [
    neovide
    firefox
  ];
}
