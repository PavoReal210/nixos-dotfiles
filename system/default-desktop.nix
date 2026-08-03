# system/default-desktop.nix
# Hyprland desktop: compositor, XDG portals, cursor, Wayland env vars
# (file management lives in file-management.nix, BTRFS options in filesystem.nix)
{
  lib,
  pkgs,
  ...
}:
{
  programs.dconf.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # NOTE: defaultSession is intentionally removed so SDDM remembers
  # whichever session you last selected.

  # ── XDG desktop portal ───────────────────────────────────────────────────────

  services.dbus.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config = {
      hyprland = {
        "org.freedesktop.impl.portal.ScreenCast" = "hyprland";
        "org.freedesktop.impl.portal.Screenshot" = "hyprland";
        default = [ "gtk" ];
      };
      common.default = [ "gtk" ];
    };
  };

  # ── Cursor ───────────────────────────────────────────────────────────────────

  environment.variables = {
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "16";
  };

  # ── Wayland application compatibility ────────────────────────────────────────

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland;xcb";

    # Disable driver vsync — gamescope handles its own presentation pipeline
    __GL_SYNC_TO_VBLANK = "0";
  };
}
