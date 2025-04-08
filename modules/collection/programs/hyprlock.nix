{
  lib,
  config,
  pkgs,
  rumLib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption mkOption;
  inherit (rumLib.generators.hypr) toHyprconf;
  inherit (rumLib.types) hyprType;

  cfg = config.rum.programs.hyprlock;
in {
  options.rum.programs.hyprlock = {
    enable = mkEnableOption "hyprlock";

    package = mkPackageOption pkgs "hyprlock" {};

    settings = mkOption {
      type = hyprType;
      default = {};
      example = {
        general = {
          hide_cursor = true;
          no_fade_in = false;
        };

        background = [
          {
            path = "screenshot";
            blur_passes = 3;
            blur_size = 8;
          }
        ];
      };
      description = ''
        Is written to `''${config.directory}/hypr/hyprlock.conf`.

        Configuration options can be found on the [Hyprland Wiki](https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock).
      '';
    };
  };

  config = mkIf cfg.enable {
    packages = [cfg.package];
    files.".config/hypr/hyprlock.conf".text = mkIf (cfg.settings != {}) (toHyprconf {
      attrs = cfg.settings;
    });
  };
}
