{
  pkgs,
  catppuccin_flavor ? "frappe",
}:
{
  imports = [
    ./keymaps.nix
    ./autocmd.nix
  ];
  extraPackages = with pkgs; [
    ripgrep
    lazygit
    fzf
    fd
  ];
  enableMan = false;
  luaLoader.enable = true;
  viAlias = true;
  vimAlias = true;
  wrapRc = true;
  clipboard.register = "unnamedplus";
  colorschemes.catppuccin = {
    enable = true;
    settings.flavor = catppuccin_flavor;
  };
  opts = {
    number = true;
    mouse = "a";
    showmode = false;
    breakindent = true;
    undofile = true;
    ignorecase = true;
    smartcase = true;
    signcolumn = "yes";
    updatetime = 250;
    timeoutlen = 300;
    splitright = true;
    splitbelow = true;
    list = true;
    listchars = "tab:» ,trail:·,nbsp:␣";
    inccommand = "split";
    cursorline = true;
    scrolloff = 10;
    hlsearch = true;
    foldenable = false;
  };
}
