{ writeShellScriptBin }: writeShellScriptBin "git-sops" (builtins.readFile ./git-sops.bash)
