{
  autoCmd = [
    {
      event = "TextYankPost";
      command = "silent! lua vim.highlight.on_yank()";
      group = "YankHighlight";
    }
  ];
  autoGroups.YankHighlight.clear = true;
}
