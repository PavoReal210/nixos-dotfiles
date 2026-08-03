{
  pkgs,
  ...
}:
{
  # ── Hypridle ──────────────────────────────────────────────────────────────
  # Idle manager for Hyprland.
  #   900s  (15 min) — turn off displays (DPMS)
  #   1800s (30 min) — lock screen
  #   3600s (60 min) — suspend
  #
  # Any active Wayland idle inhibitor (gamepad via wljoywake, media playback
  # via wayland-pipewire-idle-inhibit, or D-Bus inhibit from VLC/browsers)
  # pauses ALL timers.
  #
  # To change timeouts, edit the 'timeout' values below (in seconds).
  home.packages = [ pkgs.hypridle ];

  xdg.configFile."hypr/hypridle.conf".text = ''
    general {
        lock_cmd = pidof hyprlock || hyprlock
        before_sleep_cmd = loginctl lock-session
        after_sleep_cmd = sleep 1 && hyprctl dispatch dpms on
    }

    # Turn off displays after 15 minutes (900 seconds)
    # Displays turn back on automatically on mouse/keyboard activity
    listener {
        timeout = 900
        on-timeout = hyprctl dispatch dpms off
        on-resume = hyprctl dispatch dpms on
    }

    # Lock screen after 30 minutes (1800 seconds)
    listener {
        timeout = 1800
        on-timeout = hyprlock
    }

    # Suspend after 60 minutes (3600 seconds)
    listener {
        timeout = 3600
        on-timeout = systemctl suspend
    }
  '';
}
