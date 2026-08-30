# system/stylix.nix
# System-level Stylix: themes the ReGreet login greeter with the desktop wallpaper.
# This is the single source of truth for the wallpaper. Integrated Home Manager
# inherits `stylix.image` through its `osConfig` argument.
{pkgs, ...}: {
  stylix = {
    enable = true;

    image = ../home-manager/wallpapers/still_wallpapers/wallhaven-zpxjjo.jpg;
    # values: "center", "stretch", "fill", "fit", "tile"
    imageScalingMode = "fit";

    polarity = "dark";

    # Keep the greeter font in line with the desktop theme.
    # Packages are omitted here — all fonts are already in system/fonts.nix.
    fonts = {
      serif.name = "Tinos Nerd Font";
      sansSerif.name = "Overpass Nerd Font Mono";
      monospace.name = "Terminess Nerd Font Mono";
      emoji.name = "Noto Color Emoji";
    };

    targets.regreet.enable = true;
  };
}
