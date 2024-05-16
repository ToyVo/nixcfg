{ pkgs, lib, config, inputs, system, ... }:
let
  cfg = config.profiles;
in
{
  imports = [
    inputs.nixpkgs.nixosModules.notDetected
    inputs.catppuccin.nixosModules.catppuccin
    inputs.nh.nixosModules.default
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
    catppuccin.flavour = "frappe";
    console = {
      useXkbConfig = true;
      catppuccin = {
        enable = true;
        flavour = config.catppuccin.flavour;
      };
    };
    environment.systemPackages = with pkgs; [
      yubikey-manager
      yubikey-personalization
      yubico-piv-tool
    ]
    ++ lib.optionals cfg.gui.enable [
      floorp
      neovide
      yubikey-manager-qt
      yubioath-flutter
      element-desktop
    ];
    programs = {
      bash.blesh.enable = true;
      ssh.startAgent = false;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
      nix-ld = {
        enable = true;
        libraries = with pkgs; [
          nss
          pcre
          pcre2
          pcre16
          pcre-cpp
        ];
      };
      command-not-found.dbPath = inputs.flake-programs-sqlite.packages.${system}.programs-sqlite;
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
