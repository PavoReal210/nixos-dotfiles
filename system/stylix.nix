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

    # Keep the greeter font in line with the desktop theme
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

    targets.regreet.enable = true;
  };
}
