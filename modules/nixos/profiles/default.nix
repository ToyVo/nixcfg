{ pkgs, lib, config, inputs, ... }:
let
  cfg = config.profiles;
in
{
  imports = [
    inputs.nixpkgs.nixosModules.notDetected
    ./common.nix
  ];

  config = lib.mkIf cfg.defaults.enable {
    networking.networkmanager.enable = true;
    time.timeZone = "America/Chicago";
    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_MEASUREMENT = "C.UTF-8";
        LC_TIME = "C.UTF-8";
      };
    };
    console.useXkbConfig = true;
    environment.systemPackages = with pkgs; [
      coreutils
      yubikey-manager
      yubikey-personalization
      yubico-piv-tool
    ]
    ++ lib.optionals cfg.gui.enable [
      firefox
      neovide
      _1password
      _1password-gui
      yubikey-manager-qt
      yubioath-flutter
      element-desktop
      papirus-icon-theme
      catppuccin-kde
      catppuccin-gtk
      catppuccin-cursors
      catppuccin-papirus-folders
    ];
    programs = {
      bash.blesh.enable = true;
      ssh.startAgent = false;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };
    services = {
      xserver.xkb = {
        layout = "us";
        options = "ctrl:nocaps";
      };
      pcscd.enable = true;
      udev.packages = with pkgs; [ yubikey-personalization ];
      printing.enable = cfg.gui.enable;
      pipewire = lib.mkIf cfg.gui.enable {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
    };
    sound.enable = cfg.gui.enable;
    system = {
      stateVersion = "24.05";
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
    security.rtkit.enable = true;
    hardware.pulseaudio.enable = lib.mkForce false;
    fonts.packages = with pkgs; lib.mkIf cfg.gui.enable [ monaspace (nerdfonts.override { fonts = [ "Monaspace" "NerdFontsSymbolsOnly" ]; }) ];
    nix.optimise.automatic = true;
    boot = {
      loader.systemd-boot.configurationLimit = lib.mkIf config.boot.loader.systemd-boot.enable 3;
      binfmt.registrations.appimage = {
        wrapInterpreterInShell = false;
        interpreter = "${pkgs.appimage-run}/bin/appimage-run";
        recognitionType = "magic";
        offset = 0;
        mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
        magicOrExtension = ''\x7fELF....AI\x02'';
      };
    };
  };
}
