{
  pkgs,
  ...
}:
{
  config = {
    stylix = {
      enable = true;

      # Use a wallpaper from still_wallpapers to auto-generate a base16 color scheme.
      # The color scheme is generated via a genetic algorithm from the wallpaper image.
      # Mustache templates can also be used to generate custom theme files — see base16.nix docs.
      image = ../wallpapers/still_wallpapers/wallhaven-zpxjjo.jpg;
      # values: "center", "stretch", "fill", "fit", "tile"
      imageScalingMode = "fit";

      # base16Scheme is intentionally left unset so Stylix generates a color scheme from the wallpaper.
      # base16Scheme = "${pkgs.base16-schemes}/share/themes/atelier-forest.yaml";

      polarity = "dark";
      opacity = {
        applications = 0.7;
      };

      fonts = {
        serif = {
          package = pkgs.nerd-fonts.tinos;
          name = "Tinos Nerd Font";
        };
        sansSerif = {
          package = pkgs.nerd-fonts.overpass;
          name = "Overpass Nerd Font Mono";
        };
        monospace = {
          package = pkgs.nerd-fonts.terminess-ttf;
          name = "Terminess Nerd Font Mono";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
      };

      targets = {
        dunst.enable = false;
        gnome.enable = false;
        vesktop.enable = true;

        ghostty.enable = false;
        kitty.enable = true;
        alacritty.enable = true;

        vscode.enable = true;
        neovide.enable = true;
        anki.enable = true;

        # Stylix native engine hooks for Qt and KDE ecosystem apps
        qt.enable = true;
        kde.enable = true;

        waybar.enable = true;
        hyprlock.enable = true;
        neovim.enable = false;
      };
    };

    # GTK widgets are themed by stylix.targets.gtk (its default theme, no
    # custom theme derivation needed). Only the icon theme is set here.
    gtk = {
      enable = true;
      iconTheme = {
        package = pkgs.buuf-icon-theme;
        name = "buuf-icon-theme";
      };
    };

    dconf.settings."org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:none";
    };

    # Cursor theme
    home.pointerCursor = {
      enable = true;
      gtk.enable = true;
      x11.enable = false;
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 16;
    };
  };
}
