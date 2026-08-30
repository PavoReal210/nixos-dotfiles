# home-manager/utilities/dunst.nix
# Dunst notification daemon configuration with Stylix theming
{
  config,
  lib,
  pkgs,
  ...
}: let
  c = config.lib.stylix.colors;
in {
  # Packages that are really only used by dunstrc
  home.packages = with pkgs; [libnotify];

  services.dunst = {
    enable = true;

    settings = {
      global = {
        monitor = 0;
        follow = "keyboard";
        width = "(250, 500)";
        height = "(0, 750)";
        origin = "top-right";
        offset = "(20, 20)";
        scale = 0;
        notification_limit = 20;

        progress_bar = true;
        progress_bar_height = 10;
        progress_bar_frame_width = 1;
        progress_bar_min_width = 150;
        progress_bar_max_width = 300;
        progress_bar_corner_radius = 5;
        progress_bar_corners = "all";

        icon_corner_radius = 0;
        icon_corners = "all";
        indicate_hidden = "yes";

        padding = 8;
        horizontal_padding = 8;
        text_icon_padding = 0;

        frame_width = 1;
        frame_color = "#${c.base0D}"; # accent blue

        gap_size = 3;
        separator_color = "frame";
        sort = "yes";

        font = "${config.stylix.fonts.monospace.name} ${toString config.stylix.fonts.sizes.popups}";
        line_height = 0;
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        vertical_alignment = "center";
        show_age_threshold = 60;
        ellipsize = "middle";
        ignore_newline = "no";

        icon_position = "left";
        icon_theme = "Buuf";
        min_icon_size = 32;
        max_icon_size = 64;
        corner_radius = 5;
        corners = "all";
        layer = "top";
      };

      urgency_low = {
        background = "#${c.base00}dd";
        foreground = "#${c.base04}";
        timeout = 3;
      };

      urgency_normal = {
        background = "#${c.base00}dd";
        foreground = "#${c.base05}";
        timeout = 5;
      };

      urgency_critical = {
        background = "#${c.base00}dd";
        foreground = "#${c.base05}";
        frame_color = "#${c.base08}"; # red
        timeout = 15;
      };
    };
  };

  # dunst is launched from the compositor's exec instead of systemd, because
  # the systemd service starts before WAYLAND_DISPLAY is exported and hits
  # start-limit-hit.
  systemd.user.services.dunst = {
    Unit = {
      After = lib.mkForce [];
      PartOf = lib.mkForce [];
    };
    Install.WantedBy = lib.mkForce [];
  };

  # Clear the stale start-limit-hit state from previous failed starts.
  home.activation.resetDunst = lib.hm.dag.entryAfter ["reloadSystemd"] ''
    $DRY_RUN_CMD systemctl --user reset-failed dunst.service 2>/dev/null || true
  '';
}
