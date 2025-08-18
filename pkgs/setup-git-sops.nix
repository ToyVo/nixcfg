{
  writeShellScriptBin,
  callPackage,
  lib,
}:
let
  git-sops = callPackage ./git-sops.nix { };
in
writeShellScriptBin "setup-git-sops" ''
  git config filter.git-sops.clean "${lib.getExe git-sops} clean %f"
  git config filter.git-sops.smudge "${lib.getExe git-sops} smudge %f"
  git config filter.git-sops.required true
  git config diff.git-sops.textconv cat
''
// {
  meta.description = "setup git repository with filter and diff for sops auto encryption";
}
