# system/nvidia.nix
# NVIDIA RTX 4060 (Ada Lovelace) — Wayland/Hyprland optimized
{
  config,
  pkgs,
  ...
}: {
  # ── Graphics stack ───────────────────────────────────────────────────────────

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # ── NVIDIA driver ────────────────────────────────────────────────────────────

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Standard proprietary driver from nixpkgs, built against the configured
    # kernel (see system/scheduler.nix).
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    modesetting.enable = true;

    open = false;

    nvidiaSettings = true;

    # The standard nixpkgs driver ships `nvidia-sleep.sh`, so NixOS's
    # built-in nvidia-suspend/resume services can save and restore VRAM.
    powerManagement.enable = true;

    # finegrained enables RTD3 (Runtime D3) power management for Ada Lovelace.
    powerManagement.finegrained = false;
  };

  # ── Kernel modules ───────────────────────────────────────────────────────────
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
