# system/scheduler.nix
# CPU scheduler: CachyOS kernel + sched-ext (scx) userspace scheduler
{pkgs, ...}: {
  # ── Kernel ───────────────────────────────────────────────────────────────────
  # CachyOS kernel: a performance-tuned kernel with extra scheduling patches,
  # built against the CachyOS branch of nixpkgs (hardened BORE scheduler, etc.).
  boot.kernelPackages = pkgs.linuxPackages_cachyos;

  # ── sched-ext scheduler ───────────────────────────────────────────────────────
  # sched-ext: use scx_rustland. scx_rusty 1.1.2 hits an intermittent BPF
  # kptr race in its init_task op ("kptr already had cpumask") on kernel 7.x
  # that aborts the scheduler and fails the unit on switch; scx_rustland has
  # been reliable on this machine.
  services.scx = {
    enable = true;
    scheduler = "scx_rustland";
  };
}
