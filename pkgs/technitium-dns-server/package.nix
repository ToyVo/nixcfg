{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "technitium-dns-server";
  version = "13.6.0";

  # Self-contained Linux x64 tarball from Technitium.
  # Update version comment above when bumping; the URL serves the latest release.
  src = fetchurl {
    url = "https://download.technitium.com/dnsserver/TechnitiumDNSServerLinuxX64.tar.gz";
    hash = lib.fakeHash;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/technitium-dns-server
    cp -r * $out/share/technitium-dns-server/

    mkdir -p $out/bin
    # The tarball contains a self-contained dotnet executable named DnsServerApp.
    makeWrapper $out/share/technitium-dns-server/DnsServerApp $out/bin/technitium-dns-server \
      --chdir "$out/share/technitium-dns-server"

    runHook postInstall
  '';

  meta = {
    description = "Technitium DNS Server — self-hosted DNS server with ad blocking and threat detection";
    homepage = "https://technitium.com/dns/";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "technitium-dns-server";
  };
}
