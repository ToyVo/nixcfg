{ pkgs, lib, config, inputs, ... }:
let
  cfg = config.cd;
in
{
  imports = [
    ./common.nix
  ];

  config = lib.mkIf cfg.defaults.enable {
    networking.networkmanager.enable = true;
    time.timeZone = "America/Chicago";
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
    console.useXkbConfig = true;
    services.xserver = {
      layout = "us";
      xkbOptions = "ctrl:nocaps";
    };
    environment.systemPackages = with pkgs; [
      coreutils
      yubikey-manager
      yubikey-personalization
      yubico-piv-tool
    ]
    ++ lib.optionals cfg.packages.gui.enable [
      firefox
      neovide
      _1password
      _1password-gui
      yubikey-manager-qt
      yubioath-flutter
    ];
    programs.bash.blesh.enable = true;
    programs.ssh.startAgent = false;
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    services.openssh.enable = true;
    services.pcscd.enable = true;
    services.udev.packages = with pkgs; [ yubikey-personalization ];
    system = {
      stateVersion = "23.05";
      autoUpgrade = {
        enable = true;
        flake = inputs.self.outPath;
        persistent = true;
        allowReboot = true;
        rebootWindow = {
          lower = "01:00";
          upper = "05:00";
        };
        randomizedDelaySec = "45min";
          flags = [
          "--update-input"
          "nixpkgs"
        ];
      };
    };
    services.printing.enable = cfg.packages.gui.enable;
    security.rtkit.enable = true;
    hardware.pulseaudio.enable = lib.mkForce false;
    services.pipewire = {
      enable = cfg.packages.gui.enable;
      alsa.enable = cfg.packages.gui.enable;
      alsa.support32Bit = cfg.packages.gui.enable;
      pulse.enable = cfg.packages.gui.enable;
    };
    fonts.packages = with pkgs; lib.mkIf cfg.packages.gui.enable [ monaspace (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; }) ];
  };
}
