# system/nvidia.nix
# NVIDIA RTX 4060 (Ada Lovelace) — Wayland/Hyprland optimized
{
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # ── Graphics stack ───────────────────────────────────────────────────────────

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # ── NVIDIA driver ────────────────────────────────────────────────────────────

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;

    open = false;

    nvidiaSettings = true;

    # Enable power management for suspend/resume support.
    # powerManagement.enable creates nvidia-suspend/resume services that
    # save/restore VRAM during sleep (required for high-memory GPUs).
    # finegrained enables RTD3 (Runtime D3) power management for Ada Lovelace.
    powerManagement.enable = true;
    powerManagement.finegrained = false;

    package = pkgs.nvidia_cachyos;
  };

  # ── Kernel modules ───────────────────────────────────────────────────────────

  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];
  # sched-ext: use scx_rustland. scx_rusty 1.1.2 hits an intermittent BPF
  # kptr race in its init_task op ("kptr already had cpumask") on kernel 7.x
  # that aborts the scheduler and fails the unit on switch; scx_rustland has
  # been reliable on this machine.
  services.scx = {
    enable = true;
    scheduler = "scx_rustland";
  };

  # ── Suspend/resume support ─────────────────────────────────────────────────
  #
  # Suspend is now enabled via hardware.nvidia.powerManagement above.
  # If suspend causes black screens on resume, set powerManagement.enable = false
  # and re-add the systemd service disables below:
  #   systemd.services.systemd-suspend.enable = false;
  #   systemd.services.systemd-hibernate.enable = false;
  #   systemd.services.systemd-hybrid-sleep.enable = false;
  #   systemd.services.systemd-suspend-then-hibernate.enable = false;

  # ── Wayland environment variables ────────────────────────────────────────────

  environment.sessionVariables = {
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";
  };
}
