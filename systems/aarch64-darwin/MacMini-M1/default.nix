{ pkgs, inputs, ... }: {
  profiles.defaults.enable = true;
  userPresets.toyvo.enable = true;
  homebrew.casks = [
    { name = "prusaslicer"; greedy = true; }
    { name = "google-chrome"; greedy = true; }
  ];
  environment.pythonPackages = [
    (pkgs.python311Packages.buildPythonPackage {
      pname = "pymobiledevice3 ";
      version = "2.30.0";
      format = "wheel";
      src = inputs.pymobiledevice3;
    })
  ];
  environment.systemPackages = with pkgs; [
    openssl
  ];
}
