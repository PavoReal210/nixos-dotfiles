# system/nvidia.nix
# NVIDIA RTX 4060 (Ada Lovelace) — Wayland/Hyprland optimized
{pkgs, ...}: {
  # ── Graphics stack ───────────────────────────────────────────────────────────

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # ── NVIDIA driver ────────────────────────────────────────────────────────────

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;

    open = false;

    nvidiaSettings = true;

    # The current CachyOS NVIDIA package does not ship the
    # `nvidia-sleep.sh` helper expected by NixOS's power-management module.
    # Enabling it would create broken nvidia-suspend/resume services and block
    # the entire suspend transaction. Suspend coordination is handled by
    # system/suspend.nix instead.
    powerManagement.enable = false;

    # finegrained enables RTD3 (Runtime D3) power management for Ada Lovelace.
    powerManagement.finegrained = false;

    # Use the kernel-matched nixpkgs driver. The Chaotic/CachyOS 610.x package
    # currently leaves a forbidden reference to the kernel -dev output in its
    # kernel modules, which fails Nix store purity checks.
    package = pkgs.linuxPackages_cachyos.nvidiaPackages.stable;
  };

  # ── Kernel modules ───────────────────────────────────────────────────────────
  # The CachyOS kernel itself is selected in system/scheduler.nix.

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];

  # ── Wayland environment variables ────────────────────────────────────────────

  environment.sessionVariables = {
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";
  };
}
