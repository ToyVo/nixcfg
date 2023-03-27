{ pkgs, ... }: {
  imports = [ ./home-common.nix ];
  home.packages = with pkgs; [
    neovide
    firefox
    # yubico-authenticator
  ];
}
