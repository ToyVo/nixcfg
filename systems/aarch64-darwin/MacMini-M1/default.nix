{ pkgs, inputs, ... }: {
  profiles.defaults.enable = true;
  userPresets.toyvo.enable = true;
  homebrew.casks = [
    { name = "prusaslicer"; greedy = true; }
    { name = "google-chrome"; greedy = true; }
  ];
  environment.systemPackages = with pkgs; let
    pymobiledevice3 = python3Packages.buildPythonPackage {
      pname = "pymobiledevice3 ";
      version = "2.30.0";
      format = "wheel";
      src = inputs.pymobiledevice3;
    };
  in [
    openssl
    (python3.withPackages (ps: [
      pymobiledevice3
    ]))
  ];
}
