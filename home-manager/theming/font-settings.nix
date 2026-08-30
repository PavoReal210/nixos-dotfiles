{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.stylix.customFonts;
in {
  options = {
    stylix.customFonts = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Custom font definitions for status bars, weather, etc.";
    };

    utils.fonts = let
      font = lib.types.submodule {
        options = {
          family = lib.mkOption {type = lib.types.str;};
          style = lib.mkOption {type = lib.types.str;};
          weight = lib.mkOption {type = lib.types.str;};
          size = lib.mkOption {type = lib.types.number;};
          package = lib.mkOption {type = lib.types.package;};
        };
      };
    in {
      describeFont = lib.mkOption {
        type = lib.types.functionTo lib.types.str;
      };
      primary = lib.mkOption {type = font;};
      secondary = lib.mkOption {type = font;};
      monospace = lib.mkOption {type = font;};
      status = lib.mkOption {type = font;};
      weather = lib.mkOption {type = font;};
      symbols = lib.mkOption {type = font;};
    };
  };

  config = {
    stylix.customFonts = {
      status = {
        family = "Terminess Nerd Font Mono";
        style = "Regular";
        weight = "100";
        size = 18;
        package = pkgs.nerd-fonts.terminess-ttf;
      };
      weather = {
        family = "Weather Icons";
        style = "Regular";
        weight = "Regular";
        size = 14;
        package = pkgs.weather-icons;
      };
      symbols = {
        family = "Symbols Nerd Font Mono";
        style = "Regular";
        weight = "Regular";
        size = 14;
        package = pkgs.nerd-fonts.symbols-only;
      };
    };

    utils.fonts = {
      describeFont = font: "${font.family}:style=${font.style} ${toString font.size}";

      primary = {
        family = config.stylix.fonts.sansSerif.name;
        style = "Regular";
        weight = "Regular";
        size = 14;
        package = config.stylix.fonts.sansSerif.package;
      };
      secondary = {
        family = config.stylix.fonts.monospace.name;
        style = "Bold";
        weight = "Bold";
        size = 14;
        package = config.stylix.fonts.monospace.package;
      };
      monospace = {
        family = config.stylix.fonts.monospace.name;
        style = "Regular";
        weight = "Regular";
        size = 14;
        package = config.stylix.fonts.monospace.package;
      };
      status = {
        family = cfg.status.family;
        style = cfg.status.style;
        weight = cfg.status.weight;
        size = cfg.status.size;
        package = cfg.status.package;
      };
      symbols = {
        family = cfg.symbols.family;
        style = cfg.symbols.style;
        weight = cfg.symbols.weight;
        size = cfg.symbols.size;
        package = cfg.symbols.package;
      };
      weather = {
        family = cfg.weather.family;
        style = cfg.weather.style;
        weight = cfg.weather.weight;
        size = cfg.weather.size;
        package = cfg.weather.package;
      };
    };

    # enabling fontconfig should regenerate cache when new font packages are added
    fonts.fontconfig = {
      enable = true;
      antialiasing = true;
      hinting = "full"; # other options include "medium" or "full"
      subpixelRendering = "vertical-rgb"; # "rgb" for most monitors, "bgr" for some monitors
      configFile = {
        # This is a custom fontconfig configuration that sets the default fonts for various categories.
        # It also enables bitmap fonts and sets some other options.
        status = {
          enable = true;
          label = "cozette-disable-antialiasing";
          text = ''
            <fontconfig>
              <match target="font">
                <test name="family">
                  <string>${cfg.status.family}</string>
                </test>
                <edit name="antialias" mode="assign">
                  <bool>false</bool>
                </edit>
                <edit name="hinting" mode="assign">
                  <bool>true</bool>
                </edit>
              </match>
            </fontconfig>
          '';
        };
      };
    };

    # for terminal and such, prefer monospace font followed by symbol font
    fonts.fontconfig.defaultFonts.monospace = [
      config.stylix.fonts.monospace.name
      cfg.symbols.family
    ];
  };
}
