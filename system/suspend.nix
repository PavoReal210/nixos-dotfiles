# system/suspend.nix
# Suspend/resume coordination for NVIDIA + Hyprland + sched-ext.
#
# The NVIDIA package in use does not provide NixOS's nvidia-sleep.sh helper, so
# this module coordinates the userspace pieces directly. Fixes:
#   - SIGSTOP Hyprland before suspend and SIGCONT after resume, so the compositor
#     never races the GPU disappearing/reappearing.
#   - Stop the scx (sched-ext) userspace scheduler before suspend and restart it
#     after resume, since these schedulers are known to misbehave across CPU
#     hotplug/suspend-resume cycles.
{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # ── Pause/resume Hyprland around suspend ─────────────────────────────────────
  # Freezing the compositor before the GPU is suspended and thawing it only after
  # resume prevents the "dies on wake" hang with the NVIDIA driver on Wayland.

  systemd.services.hyprland-suspend = {
    description = "Pause Hyprland before suspend";
    before = ["systemd-suspend.service"];
    wantedBy = ["systemd-suspend.service"];
    serviceConfig = {
      Type = "oneshot";
      # A leading '-' tells systemd to ignore a nonzero exit status when
      # Hyprland is not running, without passing shell syntax to pkill.
      ExecStart = "-${pkgs.procps}/bin/pkill -STOP -x Hyprland";
    };
  };

  systemd.services.hyprland-resume = {
    description = "Resume Hyprland after suspend";
    after = ["systemd-suspend.service"];
    wantedBy = ["systemd-suspend.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "-${pkgs.procps}/bin/pkill -CONT -x Hyprland";
    };
  };

  # ── Stop/restart the sched-ext scheduler around suspend ──────────────────────
  # The userspace scheduler (scx_rustland) can wedge on CPU hotplug during
  # suspend/resume. Unloading it before sleep falls back to the kernel scheduler;
  # restarting it after wake brings the tuned scheduler back.

  systemd.services.scx-suspend = {
    description = "Stop SCX scheduler before suspend";
    before = ["systemd-suspend.service"];
    wantedBy = ["systemd-suspend.service"];
    serviceConfig = {
      Type = "oneshot";
      # Do not let an already-stopped scheduler block suspend.
      ExecStart = "-${pkgs.systemd}/bin/systemctl stop scx.service";
    };
  };

  systemd.services.scx-resume = {
    description = "Start SCX scheduler after resume";
    after = ["systemd-suspend.service"];
    wantedBy = ["systemd-suspend.service"];
    serviceConfig = {
      Type = "oneshot";
      # Do not let a scheduler restart failure prevent the system from waking.
      ExecStart = "-${pkgs.systemd}/bin/systemctl start scx.service";
    };
  };
}
