# system/gaming.nix
# Gaming performance optimizations for AMD Ryzen 5800X + NVIDIA RTX 4060
#
# Includes:
#   - Gamescope (Valve's gaming compositor)
#   - Gamemode (Feral Interactive's performance optimizer)
#   - Lutris (game launcher)
#   - Kernel parameters for maximum gaming performance
{
  config,
  pkgs,
  ...
}: {
  # ── Steam Configuration ─────────────────────────────────────────────────────

  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraEnv = {STEAM_FORCE_DESKTOPUI_SCALING = "1.6";};
    };
    gamescopeSession.enable = true;
    protontricks.enable = true;
    extraPackages = with pkgs; [
      gamescope
      mangohud
    ];
  };

  # ── Gamemode ─────────────────────────────────────────────────────────────────

  programs.gamemode.enable = true;

  # ── System Packages ──────────────────────────────────────────────────────────

  environment.systemPackages = with pkgs; [
    # Game launchers
    lutris
    gamepad-tool # SDL2 gamepad mapping editor

    # Communication
    discord

    # Compatibility layers
    winetricks
    wineWow64Packages.stable

    # Vulkan tools
    vulkan-tools
  ];

  # ── Kernel Parameters ────────────────────────────────────────────────────────

  boot.kernelParams = [
    # Full preemption gives the kernel the ability to interrupt any task at
    # nearly any point, reducing worst-case scheduling latency for the game
    # thread and compositor.
    "preempt=full"
  ];

  # ── File Descriptor Limits ───────────────────────────────────────────────────
  #
  # Some games and Proton/Wine sessions open many file descriptors.

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "65536";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "65536";
    }
  ];

  # ── Kernel Sysctl Tuning ─────────────────────────────────────────────────────

  boot.kernel.sysctl = {
    # Keep swap usage low so games stay in physical RAM.
    "vm.swappiness" = 10;

    # Write dirty pages back sooner to avoid large I/O stalls under load.
    "vm.dirty_ratio" = 15;
    "vm.dirty_background_ratio" = 5;

    # Reduce pressure on dentry/inode caches so game asset reads stay fast.
    "vm.vfs_cache_pressure" = 50;
  };
}
