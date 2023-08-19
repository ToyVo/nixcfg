{ lib, config, pkgs, ... }:
let
  cfg = config.cdcfg.vscode;
in
{
  options.cdcfg.vscode.enable = lib.mkEnableOption "Enable vscode" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        vscodevim.vim
        rust-lang.rust-analyzer
        tamasfe.even-better-toml
        dbaeumer.vscode-eslint
        esbenp.prettier-vscode
        jdinhlife.gruvbox
        usernamehw.errorlens
        eamodio.gitlens
        serayuzgur.crates
        github.copilot
        # Can be added to the above when merged https://github.com/NixOS/nixpkgs/pull/211321
        # vadimcn.vscode-lldb
      ];
    };
  };
}
