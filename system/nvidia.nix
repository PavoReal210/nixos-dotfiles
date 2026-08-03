# system/nvidia.nix
# NVIDIA RTX 4060 (Ada Lovelace) — Wayland/Hyprland optimized
{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

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

    # Enable power management for suspend/resume support.
    # powerManagement.enable creates nvidia-suspend/resume services that
    # save/restore VRAM during sleep (required for high-memory GPUs).
    # finegrained enables RTD3 (Runtime D3) power management for Ada Lovelace.
    powerManagement.enable = true;
    powerManagement.finegrained = false;

    package = pkgs.nvidia_cachyos;
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
