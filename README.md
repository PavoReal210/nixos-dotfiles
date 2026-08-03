# railgun's NixOS Configuration

Comprehensive NixOS flake configuration with home-manager for a complete Wayland desktop environment with gaming support.

## Overview

This flake manages:
- **System**: NixOS 25.11 with Lanzaboote (secure boot)
- **Wayland Compositor**: Hyprland
- **Bar**: Waybar
- **Launcher**: Bemenu
- **Terminal**: Ghostty / Kitty
- **Editor**: Doom Emacs (via nix-doom-emacs-unstraightened) + vanilla Neovim
- **Theme System**: Stylix (wallpaper-based)
- **Notifications**: Dunst
- **Secrets**: SOPS-nix for WiFi passwords, SSH keys, and other secrets
- **Gaming**: Gamescope, Gamemode, Lutris, Heroic, MangoHud, RetroArch (with RetroAchievements)

## Desktop

| Component | Choice |
|-----------|--------|
| Compositor | Hyprland (blur, shadows, animations) |
| Bar | Waybar |
| Launcher | Bemenu |
| Lockscreen | Hyprlock |
| Idle | Hypridle |
| Wallpaper | stylix |
| Screenshot | Grimshot |
| Clipboard | Cliphist + wl-clipboard |

### Utilities

Notifications: Dunst, Terminal: Ghostty/Kitty, Browser: Floorp, Editor: Doom Emacs + VSCode, Mail: Thunderbird, Spaced Rep: Anki, networkmanager-applet, blueman-applet, Maestral (Dropbox), PIA VPN.

### Screenshots

Screenshots use Grimshot through two scripts defined in `home-manager/desktops/utilities/screenshot.nix`:

| Action | Keybinding | Behavior |
|--------|-----------|----------|
| Full screen | `Print` | Saves to `~/Pictures/Screenshots/<timestamp>.png` |
| Area | `Super + Shift + S` | Saves to `~/Pictures/Screenshots/<timestamp>.png` and copies to clipboard |

Each script sends a Dunst notification on completion — normal urgency with the saved path on success, critical urgency on failure.

## Quick Start

```bash
# Build and switch system configuration
nh os switch

# Or manually
sudo nixos-rebuild switch --flake .#railgun

# Switch home-manager
home-manager switch --flake .#railgun-linux-desktop
```

## Structure

```
nixos-dotfiles/
├── flake.nix                       # Main flake (all inputs)
├── system/                         # System-level NixOS config
│   ├── configuration.nix           # Main system config
│   ├── hardware-configuration.nix  # HW config (needs UUIDs)
│   ├── boot.nix                    # Lanzaboote + secure boot
│   ├── nvidia.nix                  # RTX 4060 Wayland config
│   ├── gaming.nix                  # Gamescope, Gamemode, Lutris, Heroic, kernel tuning
│   ├── audio.nix                   # PipeWire + pamixer, pavucontrol, playerctl
│   ├── bluetooth.nix               # Bluetooth + MT7921 fixes
│   ├── default-desktop.nix         # Hyprland, XDG portals, Wayland env vars
│   ├── desktop-manager.nix         # SDDM with Rose Pine theme
│   ├── fonts.nix                   # Nerd Fonts, Noto, Weather Icons (single source of truth)
│   ├── locale.nix                  # Locale + timezone
│   ├── network.nix                 # NetworkManager + SOPS WiFi
│   ├── nix-settings.nix            # Flakes, garbage collection, store optimization, Cachix
│   ├── power-management.nix        # amd_pstate=active, EPP, ZRAM, ananicy-cpp
│   ├── users.nix                   # User account + zsh
│   ├── vpn.nix                     # PIA VPN (WireGuard) + SOPS
│   └── secrets/                    # Encrypted SOPS secrets (age)
├── home-manager/                   # User-level config (home-manager)
│   ├── home.nix                    # Main entry + session vars
│   ├── theming/                    # Stylix, fonts, fastfetch
│   │   ├── stylix.nix             # Stylix configuration
│   ├── utilities/                  # Apps and tools
│   │   ├── common-packages.nix     # GUI + CLI packages
│   │   ├── development-tools.nix   # Rust, Python, C/C++, Nix, LaTeX
│   │   ├── devshells/              # Pinned dev environments (c-dev, py-dev, rs-dev)
│   │   ├── doom.nix                # Doom Emacs (nix-doom-emacs-unstraightened)
│   │   ├── gaming.nix              # goverlay, RetroArch + RetroAchievements, BIOS seeding
│   │   ├── firefox.nix             # Firefox with GPU accel
│   │   ├── ghostty.nix             # Ghostty terminal (Stylix)
│   │   ├── kitty.nix               # Kitty terminal (Stylix)
│   │   ├── vscode.nix              # VSCode with extensions
│   │   ├── zsh.nix                 # Zsh + Powerlevel10k
│   │   ├── dunst.nix               # Notification daemon
│   │   ├── ssh.nix                 # SSH + SOPS GitHub key
│   │   └── ...                     # Other app configs
│   ├── wallpapers/                 # Wallpaper assets
│   └── desktops/                   # Desktop environment modules
│       ├── common-packages.nix     # Shared compositor packages (grimshot, cliphist, etc.)
│       ├── hyprland/
│       │   ├── hyprland.nix        # Full Hyprland config + keybindings
│       │   ├── hyprlock.nix        # Hyprlock lockscreen with stylix colors
│       │   └── hypridle.nix        # Idle management (lock, dpms, suspend)
│       └── utilities/
│           ├── bar/waybar.nix      # Waybar + custom modules
│           ├── bemenu/             # Launcher, powermenu, VPN selector
│           └── screenshot.nix      # Grimshot scripts (shot-full, shot-area)
└── docs/                           # Documentation
    ├── devshells.md                # Development shell usage
    ├── secrets.md                  # SOPS secrets setup
    └── base16-reference.md         # Base16 color palette reference
```

## Editors

### Doom Emacs

Doom Emacs is managed via [nix-doom-emacs-unstraightened](https://github.com/marienz/nix-doom-emacs-unstraightened), which builds Doom from Nix and keeps everything reproducible. Your configuration lives in [railgun210/doom-emacs](https://github.com/railgun210/doom-emacs) and is pulled in as a flake input.

Key details:
- Uses `emacs-pgtk` for Wayland-native rendering
- Binary cache via [Cachix](https://app.cachix.org/cache/doom-emacs-unstraightened) for faster builds
- Theme: `doom-one` (configured in `config.el`)
- Transparency: 90% (configured in `config.el`)

### Vanilla Neovim

A minimal Neovim installation (no plugins) is available for quick terminal edits. `EDITOR` and `VISUAL` are set to `emacsclient -a ''`.

## Theme System (Stylix)

Colors are managed via Stylix, which generates a base16 palette from the current wallpaper:

```nix
stylix.image = ../wallpapers/still_wallpapers/wallhaven-1p5z29.jpg;
# base16Scheme is intentionally left unset so Stylix generates from wallpaper
```

Colors are applied to:
- Hyprland, Waybar, Bemenu, Hyprlock
- GTK, Qt, Ghostty, Kitty, Firefox, VSCode, Anki

GTK widgets are themed by Stylix's built-in GTK target (no custom theme derivation). The icon theme is set separately in `theming/stylix.nix`.

Fonts are managed at system level (`system/fonts.nix`) with Stylix font preferences set in `theming/stylix.nix` and `theming/font-settings.nix`. Primary fonts: Terminess Nerd Font Mono (monospace), Overpass (sans), Cozette (status bars), Symbols Nerd Font Mono, Weather Icons.

See [docs/base16-reference.md](docs/base16-reference.md) for the full color slot reference.

## Gaming

The configuration includes a dedicated gaming module (`system/gaming.nix`) with:

- **Gamescope**: Valve's gaming compositor for better frame pacing, HDR, and FSR upscaling
- **Gamemode**: Feral Interactive's automatic CPU/IO performance optimizer
- **Lutris + Heroic**: Game launchers for non-Steam games
- **Steam**: Full Steam integration with Proton support
- **Goverlay**: GUI for MangoHud (user-level)

### Kernel Optimizations

- `mitigations=off` — Disables CPU security mitigations for maximum single-thread performance
- `preempt=full` — Full preemption for better desktop responsiveness during gaming
- `vm.swappiness=10` — Keeps games in physical RAM
- `vm.vfs_cache_pressure=50` — Faster game asset reads

### NVIDIA

The RTX 4060 uses proprietary NVIDIA modules with:
- Wayland modesetting enabled
- VA-API hardware video decode
- 32-bit graphics support for Proton games

### RetroArch

RetroArch is built from `retroarch-bare` (nixpkgs has no `programs.retroarch` module) and configured in `home-manager/utilities/gaming.nix`.

- **Cores**: NES (`mesen`), SNES (`bsnes-hd` + `snes9x`), N64 (`mupen64plus`), PS1 (`beetle-psx-hw`), PS2 (`pcsx2`), GameCube/Wii (`dolphin`), GBA (`mgba`), Dreamcast (`flycast`), Sega Saturn (`beetle-saturn`)
- **Video**: Vulkan on the RTX 4060, fullscreen, nearest-neighbour scaling, vsync on
- **Upscaling**: seeded into `retroarch-core-options.cfg` on first run (only if the file is absent) — 4x internal resolution on PS1/PS2/GameCube, 6x Saturn, 1440x1440 Dreamcast, HD supersampling on SNES
- **BIOS**: the ~8 MB of BIOS/system files actually required (PS1, PS2, Dreamcast, Saturn) are downloaded into `~/Emulation/bios` from [Abdess/retrobios](https://github.com/Abdess/retrobios) (pinned to a commit) only if missing, placed in the layout RetroArch cores expect. NES/SNES/N64/GBA/GC need no BIOS.
- **RetroAchievements**: enabled globally (hardcore mode off, so rewind/savestates stay usable). Credentials are stored in sops (`retroachievements-username`/`retroachievements-password` in `system/secrets/secrets.yaml`) and seeded into RetroArch's config at activation, so they never land in the nix store.

## Rebuilding

```bash
# Using nh (recommended)
nh os switch

# Or manually
sudo nixos-rebuild switch --flake .#railgun
home-manager switch --flake .#railgun-linux-desktop
```

## Secrets

SOPS is configured for secrets management. Edit secrets with:

```bash
export EDITOR="emacsclient -a ''"
sops system/secrets/secrets.yaml
```

Secrets include WiFi, PIA VPN, and the RetroAchievements credentials (`retroachievements-username` / `retroachievements-password`). See [docs/secrets.md](docs/secrets.md) for setup instructions.

## Documentation

| Document | Description |
|----------|-------------|
| [docs/devshells.md](docs/devshells.md) | Development shell usage (c-dev, py-dev, rs-dev) |
| [docs/secrets.md](docs/secrets.md) | SOPS secrets setup and management |
| [docs/base16-reference.md](docs/base16-reference.md) | Base16 color palette slot reference |
| [docs/hyprland-animations.md](docs/hyprland-animations.md) | Hyprland animation system, bezier curves, and styles |

## Notes

- `hardware-configuration.nix` needs real btrfs UUIDs when deployed
- Update `users.nix` with the correct user UID
- SOPS requires `~/.config/sops/age.keys` or `~/.ssh/id_ed25519`
- Doom Emacs config is managed via the [railgun210/doom-emacs](https://github.com/railgun210/doom-emacs) repository, pulled in as a flake input
- Vanilla Neovim is available for quick terminal edits with no plugin overhead
