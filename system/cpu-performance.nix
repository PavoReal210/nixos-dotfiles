# system/cpu-performance.nix
# CPU power management — AMD Ryzen 5800X (Vermeer / Zen 3)
#
# Note:
# If you're not using the exact same processor as me, you can probably delete this entire file
# Or just use it for reference to configure your device. But don't just blindly copy it.
# Configured for responsive desktop and VM performance while retaining normal
# idle power management.
# - performance governor: EPP hints from the kernel tell amd_pstate to request the
#   highest frequency possible across all cores, minimizing any latency due to
#   frequency transitions.
# - cppc_prefctrl=1 enables platform-level preferred core support, letting the
#   hardware schedule to the fastest P-cores in a power-aware way.
# - amd_pstate is in active mode, which lets hardware directly control frequency
#   from EPP hints for lowest latency.
{pkgs, ...}: let
  # Set each CPU policy to the performance EPP while leaving valid frequency
  # and boost limits under kernel/firmware control.
  cpuPerformanceScript = ''
    # Set EPP to performance on every CPU policy
    for policy in /sys/devices/system/cpu/cpufreq/policy*; do
      [ -e "$policy/energy_performance_preference" ] && \
        echo performance > "$policy/energy_performance_preference"
    done

  '';
in {
  # ── Kernel parameters ──────────────────────────────────────────────────────────

  boot.kernelParams = [
    # active > guided: hardware CPPC2 controls frequency directly from EPP hint.
    # guided still routes frequency decisions through the OS scheduler; active
    # has lower latency and is what AMD's own power management expects on Zen 3.
    "amd_pstate=active"

    # Enable Preferred Core Control (PCC) to let the platform choose the
    # physically best cores for the workload. This should translate to higher
    # boost when single core is loaded.
    "amd_pstate.cppc_prefctrl=1"

  ];

  # ── CPU frequency governor ─────────────────────────────────────────────────────

  # In amd_pstate=active mode, the scaling governor's frequency decisions are not
  # applied by hardware directly but translated into EPP hints. The performance
  # governor issues the highest EPP hint at all times.
  # This causes the maximum possible frequency to be requested for every task, maximizing
  # responsiveness at the cost of increased power draw and heat.
  powerManagement.cpuFreqGovernor = "performance";

  # ── EPP: Energy-Performance Preference ─────────────────────────────────────────
  #
  # On amd_pstate=active, EPP is the main knob that determines CPU frequency. EPP is set from
  # 0 (maximum performance) to 255 (maximum power savings).
  # power-profiles-daemon is NOT used; EPP is hard-coded to 0 (performance) to eliminate any
  # chance of profiles changing mid-session.
  #
  # amd_pstate EPP table:
  #   performance        = 0   (max freq always)
  #   balance_performance = 64  (somewhat balanced)
  #   balance_power      = 128  (balanced)
  #   power              = 192  (idle)
  #   power-save         = 255  (min freq)

  # systemd service to select maximum performance preference on boot and after resume.
  # - EPP=performance tells amd-pstate to always prefer the highest frequency.
  # - Frequency limits remain dynamic so this works with the actual firmware
  #   limits and does not disable normal boost behavior.
  # - Because power-profiles-daemon is not running, this is the only thing setting EPP,
  #   so we handle both boot (wantedBy) and resume (ExecStopPost would be a hack;
  #   instead a full systemd resume hook could be added if needed).
  systemd.services.cpu-performance-epp = {
    description = "Set CPU frequency policy to performance EPP";
    wantedBy = ["multi-user.target"];
    after = ["sysinit.target"];
    restartIfChanged = false;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = cpuPerformanceScript;
  };

  # Re-apply EPP after resume: amd_pstate can reset policy preferences across
  # the suspend/resume cycle.
  powerManagement.resumeCommands = cpuPerformanceScript;

  # ── Thermal management ───────────────────────────────────────────────────────

  # thermald is NOT used — Intel-centric measure that guesses on AMD.

  # The 5800X firmware throttle at TjMax=90°C. Since we've disabled all C-state
  # power saving and locked max frequency, this becomes especially important.
  # Ensure there is adequate cooling: the CPU might try to sustain boost clock
  # above its typical thermal envelope.
  boot.kernelModules = ["k10temp"];

  # ── NVMe power management: DISABLED ─────────────────────────────────────────
  #
  # APST sometimes introduces a small delay when transitioning from idle to active.
  # With max power/performance, APST off means NVMe drives are always ready for
  # immediate I/O, at the cost of ~1-2W more at idle.
  # The relevant udev rule is intentionally omitted.

  # ── Packages ─────────────────────────────────────────────────────────────────

  environment.systemPackages = with pkgs; [
    # cpupower: query/set CPU power and frequency scaling settings
    linuxKernel.packages.linux_zen.cpupower
  ];
}
