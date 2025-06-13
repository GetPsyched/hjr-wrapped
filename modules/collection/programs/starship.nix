{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkAfter mkIf;
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;

  toml = pkgs.formats.toml {};

  cfg = config.rum.programs.starship;
in {
  options.rum.programs.starship = {
    enable = mkEnableOption "starship module.";
    package = mkPackageOption pkgs "starship" {nullable = true;};
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

      description = ''
        The configuration converted to TOML and written to {file}`$HOME/.config/starship.toml`.
        Please reference [Starship's documentation] for configuration options.

        [Starship's documentation]: https://starship.rs/config
      '';
    };
    integrations = {
      nushell.enable = mkEnableOption "starship integration with nushell";
      zsh.enable = mkEnableOption "starship integration with zsh";
    };
  };

  config = mkIf cfg.enable {
    packages = mkIf (cfg.package != null) [cfg.package];
    files = {
      ".config/starship.toml".source = mkIf (cfg.settings != {}) (
        toml.generate "starship.toml" cfg.settings
      );

      /*
      Needs to be added to the end of ~/.zshrc, hence the `mkIf` and `mkAfter`.
      https://starship.rs/guide/#step-2-set-up-your-shell-to-use-starship
      */
      ".zshrc".text = mkIf (config.rum.programs.zsh.enable && cfg.integrations.zsh.enable) (
        mkAfter ''eval "$(${getExe cfg.package} init zsh)"''
      );
    };
    rum.programs.nushell.extraConfig = mkIf (config.rum.programs.nushell.enable && cfg.integrations.nushell.enable) (
      mkAfter ''
        use ${
          pkgs.runCommand "starship-init-nu" {} ''
            ${getExe cfg.package} init nu >> "$out"
          ''
        }
      ''
    );
  };
}
