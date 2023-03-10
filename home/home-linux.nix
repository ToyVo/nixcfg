{ pkgs, ... }: {
  home.packages = with pkgs; [
    neovide
    firefox
    # yubico-authenticator
  ];
}
