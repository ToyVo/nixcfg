{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixcfg.darwin.android;

  # Pinned versions so emulator test env is reproducible.
  apiLevel = "34";
  systemImage = "system-images;android-${apiLevel};google_apis;arm64-v8a";
  avdName = "Pixel_7_API34_microG";
  cmdlineToolsUrl = "https://dl.google.com/android/repository/commandlinetools-mac-11076708_latest.zip";

  revanced-android-setup = pkgs.writeShellScriptBin "revanced-android-setup" ''
    set -euo pipefail
    SDK="$HOME/Library/Android/sdk"
    mkdir -p "$SDK/cmdline-tools"
    export ANDROID_HOME="$SDK"
    export ANDROID_SDK_ROOT="$SDK"
    export JAVA_HOME="${pkgs.temurin-bin-17}"
    export PATH="$SDK/cmdline-tools/latest/bin:$SDK/platform-tools:$SDK/emulator:$PATH"

    if [ ! -x "$SDK/cmdline-tools/latest/bin/sdkmanager" ]; then
      echo "==> downloading cmdline-tools (mac arm64)"
      TMP="$(mktemp -d)"
      trap 'rm -rf "$TMP"' EXIT
      curl -L -o "$TMP/tools.zip" "${cmdlineToolsUrl}"
      rm -rf "$SDK/cmdline-tools/latest"
      mkdir -p "$SDK/cmdline-tools/latest"
      ${pkgs.unzip}/bin/unzip -q "$TMP/tools.zip" -d "$TMP"
      # zip contains cmdline-tools/{bin,lib,...}
      cp -r "$TMP/cmdline-tools/"* "$SDK/cmdline-tools/latest/"
      rm -rf "$TMP"
      trap - EXIT
    fi

    echo "==> accepting licenses"
    yes | sdkmanager --licenses > /dev/null || true

    echo "==> installing: platform-tools emulator ${systemImage}"
    sdkmanager "platform-tools" "emulator" "${systemImage}"

    echo "==> creating AVD ${avdName}"
    if avdmanager list avd 2>/dev/null | grep -q "${avdName}"; then
      echo "AVD ${avdName} already exists, skipping"
    else
      echo "no" | avdmanager create avd -n "${avdName}" -k "${systemImage}" -d "pixel_7" --force
    fi

    echo "==> test keystore (emulator-only, NOT your phone key)"
    mkdir -p "$HOME/Clone/revanced/test"
    if [ ! -f "$HOME/Clone/revanced/test/test.keystore" ]; then
      "${pkgs.temurin-bin-17}/bin/keytool" -genkeypair -alias test \
        -keyalg RSA -keysize 2048 -validity 10000 \
        -keystore "$HOME/Clone/revanced/test/test.keystore" \
        -storepass android -keypass android \
        -dname "CN=ReVanced Test, OU=Emulator, O=Local"
      echo "created $HOME/Clone/revanced/test/test.keystore (storepass: android)"
    else
      echo "keystore exists, skipping"
    fi

    cat <<EOF
    Done. Next:
      1. revanced-avd-boot            # boots ${avdName}
      2. install GmsCore + patched apk (see revanced-patch-test --help)
      3. adb -s emulator-5554 logcat -s "revanced:*" | grep AUDIT
    EOF
  '';

  revanced-avd-boot = pkgs.writeShellScriptBin "revanced-avd-boot" ''
    set -euo pipefail
    SDK="$HOME/Library/Android/sdk"
    export ANDROID_HOME="$SDK"
    export ANDROID_SDK_ROOT="$SDK"
    export JAVA_HOME="${pkgs.temurin-bin-17}"
    export PATH="$SDK/emulator:$SDK/platform-tools:$PATH"
    echo "==> booting ${avdName} (HVF, no snapshot)"
    emulator -avd "${avdName}" -no-snapshot -writable-system -accel on &
    echo "==> waiting for boot"
    adb wait-for-device
    adb shell 'while [ "$(getprop sys.boot_completed)" != 1 ]; do sleep 2; done' < /dev/null
    adb shell settings put global window_animation_scale 0 || true
    adb shell settings put global transition_animation_scale 0 || true
    adb shell settings put global animator_duration_scale 0 || true
    echo "boot complete. Serial: $(adb get-serialno)"
  '';

  revanced-patch-test = pkgs.writeShellScriptBin "revanced-patch-test" ''
    set -euo pipefail
    echo "Usage:"
    echo "  # 1. build patched apk (from ~/Clone/revanced, needs revanced-cli jar):"
    echo "  #    java -jar revanced-cli.jar patch --keystore test/test.keystore \\"
    echo "  #      --keystore-password android --key-alias test --key-password android \\"
    echo "  #      -p revanced-patches -o test/youtube-patched.apk <your-20.40.45.apkm>"
    echo ""
    echo "  # 2. install microG + patched app on the emulator:"
    echo "  adb -s emulator-5554 install -r <gmscore.apk>   # ReVanced GmsCore, same version as your Manager"
    echo "  adb -s emulator-5554 install -r test/youtube-patched.apk"
    echo ""
    echo "  # 3. collect audit logs:"
    echo "  adb -s emulator-5554 logcat -s \"revanced:*\" | grep AUDIT"
    echo ""
    echo "Note: emulator uses test/test.keystore. Your phone Manager key is untouched;"
    echo "never install a CLI-signed apk over a Manager-signed one (or vice versa)."
  '';
in
{
  options.nixcfg.darwin.android.enable =
    lib.mkEnableOption "Android emulator + ReVanced test env (Temurin 17, adb, SDK/AVD helpers)";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.temurin-bin-17
      pkgs.android-tools
      pkgs.unzip
      revanced-android-setup
      revanced-avd-boot
      revanced-patch-test
    ];
  };
}
