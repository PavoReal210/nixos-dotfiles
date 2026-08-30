{pkgs, ...}:
# Packages shared across the desktop environment.
# Compositor-specific tools (hyprlock, hypridle) live in their module files.
{
  home.packages = with pkgs; [
    # Screenshot (grimshot works on any wlroots compositor)
    sway-contrib.grimshot

    # Clipboard
    wl-clipboard
    cliphist

    # Media/audio controls
    brightnessctl

    # File manager + utilities
    loupe
    file-roller
    kdePackages.kate

    # Wallpaper (awww + waypaper)
    # Commented out for now so stylix can set the wallpaper.
    # waypaper
    # awww
  ];
}
