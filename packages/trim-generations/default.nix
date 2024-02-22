{ pkgs, inputs, ... }: 
pkgs.writeShellScriptBin "trim-generations" (builtins.readFile inputs.trim-generations)
