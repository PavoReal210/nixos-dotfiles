# system/cpu-performance.nix
# CPU power management — AMD Ryzen 5800X (Vermeer / Zen 3)
#
# Note:
# If you're not using the exact same processor as me, you can probably delete this entire file
# Or just use it for reference to configure your device. But don't just blindly copy it.
# Configured for maximum CPU performance with no power-saving features.
# - performance governor: EPP hints from the kernel tell amd_pstate to request the
#   highest frequency possible across all cores, minimizing any latency due to
#   frequency transitions.
# - processor.max_cstate=1 prevents C2, C3, and higher sleep states that could
#   cause wake-up latency spikes on idle cores.
# - cppc_prefctrl=1 enables platform-level preferred core support, letting the
#   hardware schedule to the fastest P-cores in a power-aware way.
# - amd_pstate is in active mode, which lets hardware directly control frequency
#   from EPP hints for lowest latency.
{pkgs, ...}: let
  # Lock each CPU to EPP=performance and min=max=4600 MHz.
  # Shared between the boot service and the resume hook so both stay in sync.
  cpuPerformanceScript = ''
    # Set EPP to performance on every CPU policy
    for policy in /sys/devices/system/cpu/cpufreq/policy*; do
      [ -e "$policy/energy_performance_preference" ] && \
        echo performance > "$policy/energy_performance_preference"
    done

    # Lock min and max frequency to the maximum boost clock (4600 MHz)
    for cpu in /sys/devices/system/cpu/cpu*/online; do
      dir="$(dirname "$cpu")"
      [ -e "$dir/cpufreq/scaling_min_freq" ] && \
        echo 4600000 > "$dir/cpufreq/scaling_min_freq" 2>/dev/null || true
      [ -e "$dir/cpufreq/scaling_max_freq" ] && \
        echo 4600000 > "$dir/cpufreq/scaling_max_freq" 2>/dev/null || true
    done
  '';
in {
  imports = [
    ./hardware-configuration.nix
  ];

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

    # Limit the maximum C-state to C1. This prevents the CPU from entering deeper
    # sleep states (C2, C3, etc.) which have a noticable wake-up latency. Keeping
    # cores in C1 instead of C6 eliminates that latency at the cost of higher
    # idle power consumption.
    "processor.max_cstate=1"

    # Prevent PCIe Active State Power Management from fighting the MT7921e
    # WiFi/BT chip.
    "pcie_aspm=off"

    # Disable the legacy ACPI CPU frequency driver so amd-pstate wins cleanly.
    "initcall_blacklist=acpi_cpufreq_init"
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

  # systemd service to pin each CPU to maximum performance on boot and after resume.
  # - EPP=performance tells amd-pstate to always prefer the highest frequency.
  # - min=max=4600 MHz locks the frequency so no scaling decisions are made at all;
  #   this eliminates any latency from frequency transitions entirely.
  # - Because power-profiles-daemon is not running, this is the only thing setting EPP,
  #   so we handle both boot (wantedBy) and resume (ExecStopPost would be a hack;
  #   instead a full systemd resume hook could be added if needed).
  systemd.services.cpu-performance-epp = {
    description = "Lock CPU to max performance: EPP=performance, freq 4600 MHz";
    wantedBy = ["multi-user.target"];
    after = ["sysinit.target"];
    restartIfChanged = false;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = cpuPerformanceScript;
  };

  # Re-apply EPP and the frequency lock after resume: amd_pstate can reset the
  # scaling limits across the suspend/resume cycle, leaving the CPU untuned.
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
