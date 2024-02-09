{ pkgs, ... }: {
  cd.defaults.enable = true;
  cd.users.toyvo.enable = true;
  homebrew.casks = [
    { name = "prusaslicer"; greedy = true; }
    { name = "google-chrome"; greedy = true; }
  ];
  environment.systemPackages = with pkgs; let
    pymobiledevice3 = (buildPythonPackage {
      pname = "pymobiledevice3 ";
      version = "2.30.0";
      src = fetchPypi {
        inherit pname version;
        sha256 = "";
      });
  in; [
    (python3.withPackages ([
      pymobiledevice3
    ]))
  ];
}
