{
  writeShellScriptBin,
  stdenv,
  age,
}:
writeShellScriptBin "setup-sops" ''
  destination="$HOME/${if stdenv.isDarwin then "Library/Application Support" else ".config"}/sops/age"
  mkdir -p "$destination"
  echo "$(${age}/bin/age-keygen)" > "$destination/keys.txt"
  sudo mkdir -p /var/sops/age
  sudo cp "$destination/keys.txt" /var/sops/age/keys.txt
''
// {
  meta.description = "create an age key and place it in the default sops location for editing";
}
