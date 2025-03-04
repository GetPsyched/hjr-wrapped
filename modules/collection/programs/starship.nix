{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;

  toml = pkgs.formats.toml {};

  cfg = config.programs.starship;
in {
  options.programs.starship = {
    enable = mkEnableOption "starship module.";
    package = mkPackageOption pkgs "starship" {};
    settings = mkOption {
      type = toml.type;
      default = {};
      example = {
        add_newline = false;
        format = lib.concatStrings [
          "$line_break"
          "$package"
          "$line_break"
          "$character"
        ];
        scan_timeout = 10;
        character = {
          success_symbol = "➜";
          error_symbol = "➜";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    packages = [cfg.package];
    files = {
      ".config/starship.toml".source = mkIf (cfg.settings != {}) (
        toml.generate "starship.toml" cfg.settings
      );
    };
  };
}
