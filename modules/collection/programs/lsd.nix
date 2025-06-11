{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption mkEnableOption mkPackageOption;

  yaml = pkgs.formats.yaml {};

  cfg = config.rum.programs.lsd;
in {
  options.rum.programs.lsd = {
    enable = mkEnableOption "LSD (LSDeluxe)";

    package = mkPackageOption pkgs "lsd" {nullable = true;};

    settings = mkOption {
      type = yaml.type;
      default = {};
      example = {
        classic = false;
        color = {
          theme = "default";
        };
      };
      description = ''
        Configuration written to {file}`$HOME/.config/lsd/config.yaml`, defining lsd settings.
        Please reference  [lsd's example configuration] to configure it accordingly.

        [lsd's example configuration]: https://github.com/lsd-rs/lsd#config-file-content
      '';
    };

    icons = mkOption {
      type = yaml.type;
      default = {};
      example = {
        filetype = {
          dir = "📂";
          file = "📄";
          pipe = "📩";
        };
      };
      description = ''
        Configuration written to {file}`$HOME/.config/lsd/icons.yaml`, defining the icons used by lsd.
        Please reference [lsd's icon theme example] to configure it accordingly.

        [lsd's icon theme example]: https://github.com/lsd-rs/lsd#icon-theme
      '';
    };

    colors = mkOption {
      type = yaml.type;
      default = {};
      example = {
        user = 230;
        group = 187;
        permission = {
          read = "dark_green";
          write = "dark_yellow";
        };
      };
      description = ''
        Configuration written to {file}`$HOME/.config/lsd/colors.yaml`, defining the colors used by lsd.
        Please reference [lsd's color theme example] to configure it accordingly.

        [lsd's color theme example]: https://github.com/lsd-rs/lsd#color-theme-file-content
      '';
    };
  };

  config = mkIf cfg.enable {
    packages = mkIf (cfg.package != null) [cfg.package];
    files.".config/lsd/config.yaml".source = mkIf (cfg.settings != {}) (
      yaml.generate "config.yaml" cfg.settings
    );
    files.".config/lsd/icons.yaml".source = mkIf (cfg.icons != {}) (
      yaml.generate "icons.yaml" cfg.icons
    );
    files.".config/lsd/colors.yaml".source = mkIf (cfg.colors != {}) (
      yaml.generate "colors.yaml" cfg.colors
    );
  };
}
