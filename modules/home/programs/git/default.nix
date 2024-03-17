{ lib, config, pkgs, inputs, ... }:
let
  cfg = config.programs.git;
in
{
  config = lib.mkIf cfg.enable {
    programs.git = {
      lfs.enable = true;
      includes = [ { path = "${inputs.catppuccin-delta}/themes/frappe.gitconfig"; } ];
      delta.enable = true;
      delta.options.features = "catppuccin-frappe";
      extraConfig = {
        pull.rebase = "true";
        rebase.autostash = "true";
        core.editor = "nvim";
        core.eol = "lf";
        core.autocrlf = "input";
        init.defaultBranch = "main";
        url."git@github.com:".pushInsteadOf = "https://github.com/";
      };
      signing.signByDefault = true;
      userName = "Collin Diekvoss";
      userEmail = "Collin@Diekvoss.com";
      signing.key = "D18E177DD717DD88!";
      aliases = {
        a = "add";
        aa = "add -A";
        b = "branch";
        ba = "branch -a";
        c = "commit -m";
        ca = "commit -am";
        cam = "commit --amend --date=now";
        co = "checkout";
        cob = "checkout -b";
        sw = "switch";
        swc = "switch -c";
        s = "status -sb";
        po = "!git push -u origin $(git branch --show-current)";
        d = "diff";
        dc = "diff --cached";
        ignore = "update-index --assume-unchanged";
        unignore = "update-index --no-assume-unchanged";
        ignored = "!git ls-files -v | grep ^h | cut -c 3-";
        rbm = "!git fetch && git rebase origin/main";
        rbc = "-c core.editor=true rebase --continue";
      };
    };
  };
}
