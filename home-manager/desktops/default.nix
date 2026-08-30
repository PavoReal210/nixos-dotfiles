{...}:
# settings for the desktop environment, window manager,
# compositor... y'know, the works.
# These values are set in home.nix
{
  imports = [
    ./hyprland
    ./utilities
    ./common-packages.nix
  ];
}
