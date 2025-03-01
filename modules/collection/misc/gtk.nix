{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) listOf package lines;
  inherit (lib.modules) mkIf;
  inherit (lib.lists) optionals;
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.rum.generators.gtk) toGtk2Text toGtkINI;
  inherit (lib.rum.types) gtkType;
  inherit (lib.rum.attrsets) attrNamesHasPrefix;
  inherit (builtins) hasAttr;

  cfg = config.rum.gtk;
in {
  options.rum.gtk = {
    enable = mkEnableOption "GTK configuration";
    packages = mkOption {
      type = listOf package;
      default = [];
      example = [
        (pkgs.catppuccin-papirus-folders.override {
          accent = "rosewater";
          flavor = "mocha";
        })
        pkgs.bibata-cursors
      ];
      description = ''
        The list of packages to be installed for gtk themes.
        This list should consist of any packages that will be used
        by your GTK theme(s).
      '';
    };
    settings = mkOption {
      type = gtkType;
      default = {};
      example = {
        theme-name = "Arc-Dark";
        font-name = "Sans 11";
        application-prefer-dark-theme = true;
      };
      description = ''
        The settings that will be written to the various gtk files
        to configure the GTK theme. GTK documentation is perhaps
        nebulous, but the Arch Wiki entry and the official GTK
        documentation (https://docs.gtk.org/gtk3/class.Settings.html)
        are decent places to start.

        Please note that each option name will have "gtk-" prepended
        to it, so there is no need to include that on every single option.
      '';
    };
    css = {
      gtk3 = mkOption {
        type = lines;
        default = "";
        description = ''
          CSS to be written to '${config.directory}/.config/gtk-3.0/gtk.css'.
          You can either use this as lines or you can reference
          a CSS file from your theme's package (or both).
        '';
      };
      gtk4 = mkOption {
        type = lines;
        default = "";
        description = ''
          CSS to be written to '${config.directory}/.config/gtk-4.0/gtk.css'.
          You can either use this as lines or you can reference
          a CSS file from your theme's package (or both).
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    # We could also just automatically fix it, but for now, simply
    # check if the user accidentally included a 'gtk-' prefix.
    warnings = optionals (attrNamesHasPrefix "gtk-" cfg.settings) [
      "Each option in 'rum.gtk.settings' is automatically prefixed with 'gtk-' if it is not present already. You have added this to an option unnecessarily."
    ];

    inherit (cfg) packages;

    files = (
      optionalAttrs (cfg.settings != {}) {
        ".gtkrc-2.0".text = toGtk2Text {inherit (cfg) settings;};
        ".config/gtk-3.0/settings.ini".text = toGtkINI {Settings = cfg.settings;};
        ".config/gtk-4.0/settings.ini".text = toGtkINI {Settings = cfg.settings;};
      }
      // optionalAttrs (cfg.css.gtk3 != "") {
        ".config/gtk-3.0/gtk.css".text = cfg.css.gtk3;
      }
      // optionalAttrs (cfg.css.gtk4 != "") {
        ".config/gtk-4.0/gtk.css".text = cfg.css.gtk4;
      }
    );

    # Set sessionVariables to load
    environment.sessionVariables = {
      GTK2_RC_FILES = "${config.directory}/.gtkrc-2.0";
      GTK_THEME = mkIf (hasAttr "theme-name" cfg.settings) cfg.settings.theme-name;
    };
  };
}
