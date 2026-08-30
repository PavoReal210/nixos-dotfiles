# system/suspend.nix
# Suspend/resume coordination for NVIDIA + Hyprland + sched-ext.
{pkgs, ...}: {
  # systemd-suspend.service blocks while the machine is asleep. Services that
  # are ordered After=systemd-suspend.service therefore cannot reliably run as
  # resume handlers. system-sleep hooks run synchronously on both sides of the
  # sleep transition instead.
  environment.etc."systemd/system-sleep/nixos-suspend-hooks".source = pkgs.writeShellScript "nixos-suspend-hooks" ''
    set -u

    case "$1" in
      pre)
        ${pkgs.procps}/bin/pkill -STOP -x Hyprland || true
        ${pkgs.systemd}/bin/systemctl stop scx.service || true
        echo suspend > /proc/driver/nvidia/suspend || true
        ;;
      post)
        echo resume > /proc/driver/nvidia/suspend || true
        ${pkgs.procps}/bin/pkill -CONT -x Hyprland || true
        ${pkgs.systemd}/bin/systemctl start scx.service || true
        ;;
    esac
  '';
}
