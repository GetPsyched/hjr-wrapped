{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;

  json = pkgs.formats.json {};

  cfg = config.rum.programs.atlauncher;
in {
  options.rum.programs.atlauncher = {
    enable = mkEnableOption "ATLauncher";

    package = mkPackageOption pkgs "atlauncher" {nullable = true;};

    settings = mkOption {
      type = json.type;
      default = {};
      example = {
        enableAnalytics = true;
        enableConsole = false;
        enableTrayMenu = false;
        firstTimeRun = false;
        keepLauncherOpen = false;
        theme = "com.atlauncher.themes.Dark";
      };
      description = ''
        Configuration written to {file}`$XDG_DATA_HOME/ATLauncher/configs/ATLauncher.json`.

        As of writing, there aren't any docs for the available configuration options,
        but please refer to the configuration types in [this file] for options.

        [this file]: https://github.com/ATLauncher/ATLauncher/blob/master/src/main/java/com/atlauncher/data/Settings.java
      '';
    };
  };

  config = mkIf cfg.enable {
    packages = mkIf (cfg.package != null) [cfg.package];
    xdg.data.files."ATLauncher/configs/ATLauncher.json" = mkIf (cfg.settings != {}) {
      source = json.generate "atlauncher-config.json" cfg.settings;
    };
  };
}
