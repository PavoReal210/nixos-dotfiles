# system/gaming.nix
# Gaming performance optimizations for AMD Ryzen 5800X + NVIDIA RTX 4060
#
# Includes:
#   - Gamescope (Valve's gaming compositor)
#   - Gamemode (Feral Interactive's performance optimizer)
#   - Lutris + Heroic (game launchers)
#   - Kernel parameters for maximum gaming performance
{ config, pkgs, ... }:
{
  # ── Steam Configuration ─────────────────────────────────────────────────────

  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraEnv = { STEAM_FORCE_DESKTOPUI_SCALING = "1.6"; };
    };
    gamescopeSession.enable = true;
    protontricks.enable = true;
    extraPackages = with pkgs; [
      # Use git versions from Chaotic-Nyx for the latest gaming optimizations:
      # gamescope_git — latest SteamOS compositor with newest HDR/VRR fixes
      # mangohud_git — latest MangoHud with newest GPU monitoring features
      gamescope_git
      mangohud_git
      proton-cachyos
    ];
  };

  # ── Gamemode ─────────────────────────────────────────────────────────────────

  programs.gamemode.enable = true;

  # ── System Packages ──────────────────────────────────────────────────────────

  environment.systemPackages = with pkgs; [
    # Game launchers
    lutris
    heroic # Epic Games / GOG launcher

    # Communication
    discord-krisp

    # Compatibility layers
    winetricks
    wineWow64Packages.stable

    # Vulkan — use git versions from Chaotic-Nyx for latest validation and tools
    vulkanPackages_latest.vulkan-tools
    vulkanPackages_latest.vulkan-loader
    vulkanPackages_latest.vulkan-validation-layers
    low-latency-layer
  ];

  # ── Kernel Parameters ────────────────────────────────────────────────────────

  boot.kernelParams = [
    # Disable CPU mitigations for maximum single-thread performance.
    # Trade-off: reduced security against Spectre/Meltdown-class attacks.
    # On a desktop with untrusted code only from game binaries, this is
    # generally acceptable.
    "mitigations=off"

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
