{ pkgs, ... }: {
  cd.defaults.enable = true;
  cd.users.toyvo.enable = true;
  homebrew.casks = [
    { name = "prusaslicer"; greedy = true; }
    { name = "google-chrome"; greedy = true; }
  ];
  environment.systemPackages = with pkgs; let
    pymobiledevice3 = python3Packages.buildPythonPackage {
      pname = "pymobiledevice3 ";
      version = "2.30.0";
      format = "wheel";
      src = fetchurl {
        url = "https://files.pythonhosted.org/packages/7c/f2/070be3672904106664d5048d52a709b4ef0204772179c202419c57365c59/pymobiledevice3-2.30.0-py3-none-any.whl";
        sha256 = "sha256-X9Gs7HM5N9KdyndO3+sROxyfp8PcCdN5N48cwLd0HR4=";
      };
    };
  in [
    openssl
    (python3.withPackages (ps: [
      pymobiledevice3
    ]))
  ];
}
