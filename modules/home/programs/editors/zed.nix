{
  config,
  lib,
  ...
}:
{
  options.programs.zed.enable = lib.mkEnableOption "enable zed";

  config = lib.mkIf config.programs.zed.enable {
    xdg.configFile."zed/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixcfg/modules/home/programs/editors/zed-settings.json";
  };
}
