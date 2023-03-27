{ ... }: {
  imports = [ ./home-common.nix ];
  home.file.".hushlogin".text = "";
  home.sessionPath = [
    "/opt/homebrew/bin"
  ];
}
