# railgun's NixOS Config

This is my full desktop configuration managed as a NixOS flake. Everything — the OS, the desktop environment, every app, every keybind, every color — is declared in code. If I nuke my drive and run one command, I get my exact setup back.

If you're new to Nix: a **flake** is just a locked config file that pins every dependency to an exact version so the build is reproducible. A **module** is a `.nix` file that configures one thing (bluetooth, audio, etc.). They all get assembled together at rebuild time.

---

## What's running

| Category | What I use |
|----------|-----------|
| OS | NixOS 25.11 |
| Compositor | Hyprland |
| Bar | Waybar |
| Launcher | Bemenu |
| Terminal | Ghostty (Kitty kept as backup) |
| Editor | Doom Emacs + vanilla Neovim |
| Browser | Floorp |
| Theme | Stylix — auto-generates color scheme from wallpaper |
| Login screen | greetd + ReGreet |
| Notifications | Dunst |
| Audio | PipeWire |
| Secrets | SOPS-nix (encrypted with age) |
| Virtualization | libvirt/KVM + WinApps (Windows apps on Linux) |

---

## Why I made certain choices

### Why NixOS instead of Arch/Ubuntu/etc.?

Because everything is declared. On a normal distro you install things over time and slowly forget what you installed or why. Your config drifts. You reinstall and spend days getting everything back.

With NixOS, if it's not in these files, it doesn't exist on the system. Reinstalling is just `nh os switch`. Everything is reproducible and you can roll back any change with one command.

### Why Hyprland?

It's a modern Wayland compositor that actually works well with NVIDIA (which historically has been a nightmare on Wayland). It has blur, shadows, smooth animations, and a great config format. It's the sweet spot between "looks good" and "actually stable daily driver."

### Why Stylix for theming?

Manually theming every app (terminal, bar, browser, lockscreen...) separately is a pain and they never quite match. Stylix generates a 16-color palette from your wallpaper and automatically applies it to every app at once. Change the wallpaper, everything recolors. The wallpaper path is declared once in `system/stylix.nix` and everything else inherits from it.

### Why SOPS for secrets?

Nix configs go on GitHub. You can't put your WiFi password or API keys in a `.nix` file and push it. SOPS encrypts secrets with an age key that only your machine has. The encrypted file can be committed safely — only your machine can decrypt it at build time.

### Why greetd + ReGreet instead of GDM or SDDM?

GDM pulls in half of GNOME. SDDM is fine but X11-centric. greetd with ReGreet is a lightweight, Wayland-native login manager. It also picks up the Stylix theme, so the login screen matches the desktop and lockscreen.

### Why a custom suspend setup?

NVIDIA + Wayland + sleep is notoriously broken. Without the fixes in `system/suspend.nix`, waking from sleep often hangs or crashes the compositor. The fix: freeze Hyprland before the GPU suspends, unfreeze after it wakes. Also, the sched-ext scheduler (`scx_rustland`) needs to be stopped and restarted around sleep or it can deadlock. These workarounds are annoying but necessary.

### Why PipeWire instead of PulseAudio?

PipeWire is the modern replacement. It handles audio *and* video streams, has better Bluetooth support, and works well with JACK for pro audio. PulseAudio compatibility is included so nothing breaks.

### Why a custom CPU scheduler?

Linux 6.12+ supports "sched-ext" — a framework for loading custom CPU schedulers as BPF programs. `scx_rustland` is one such scheduler that prioritizes desktop interactivity, which helps with gaming and general smoothness. It's opt-in and completely safe to disable.

---

## How to rebuild

```bash
# Recommended (uses nh for nicer output)
nh os switch

# Or the manual way
sudo nixos-rebuild switch --flake .#railgun
```

Home Manager is baked into the NixOS build — there's no separate `home-manager switch` command needed.

---

## Folder structure

```
nixos-dotfiles/
├── flake.nix                       # Entry point — declares all inputs and the machine
│
├── system/                         # NixOS system config (requires root, survives reboots)
│   ├── configuration.nix           # Imports all system modules
│   ├── hardware-configuration.nix  # Auto-generated hardware config (UUIDs, kernel modules)
│   ├── boot.nix                    # Lanzaboote (Secure Boot) + systemd-boot
│   ├── nvidia.nix                  # RTX 4060 — proprietary drivers, Wayland modesetting
│   ├── gaming.nix                  # Steam, Gamescope, Gamemode, Lutris, kernel tweaks
│   ├── audio.nix                   # PipeWire (replaces PulseAudio) + playerctl
│   ├── bluetooth.nix               # Bluetooth + workarounds for the MediaTek MT7921 chip
│   ├── default-desktop.nix         # Enables Hyprland and sets Wayland environment variables
│   ├── desktop-manager.nix         # greetd login manager + ReGreet greeter
│   ├── stylix.nix                  # Declares the wallpaper — the single source of truth
│   ├── file-management.nix         # Thunar file manager + archive/thumbnail support
│   ├── filesystem.nix              # BTRFS mount options (compression, SSD optimizations)
│   ├── fonts.nix                   # Every font installed system-wide
│   ├── locale.nix                  # Language and timezone
│   ├── network.nix                 # NetworkManager + systemd-resolved for DNS
│   ├── nix-settings.nix            # Flakes, binary caches, garbage collection policy
│   ├── printing.nix                # CUPS + Avahi network printer discovery
│   ├── cpu-performance.nix         # AMD P-State active mode, EPP, CPU temperature monitoring
│   ├── zram.nix                    # Compressed RAM-based swap (faster than disk swap)
│   ├── ananicy.nix                 # Auto nice-level daemon (CachyOS rules) for smoother desktop
│   ├── scheduler.nix               # scx_rustland sched-ext scheduler for desktop responsiveness
│   ├── suspend.nix                 # Suspend/resume hooks to stop NVIDIA + Hyprland hanging on wake
│   ├── users.nix                   # User account definition
│   ├── virtualisation.nix          # libvirt/KVM + QEMU + TPM 2.0 for Windows VMs
│   ├── winapps.nix                 # WinApps packages (run Windows apps in your Linux DE)
│   ├── doas.nix                    # doas (lighter sudo replacement) — used for PIA VPN commands
│   ├── secrets.nix                 # Points SOPS at the age key file
│   └── vpn.nix                     # PIA VPN via WireGuard
│
└── home-manager/                   # User-level config (no root needed, per-user)
    ├── home.nix                    # Entry point — session variables, imports theming first
    │
    ├── theming/                    # Loaded before everything else so colors propagate correctly
    │   ├── stylix.nix              # Inherits wallpaper from system, applies theme to all apps
    │   ├── font-settings.nix       # Font sizes and per-context overrides
    │   └── fastfetch/              # System info display config
    │
    ├── utilities/                  # User applications and CLI tools
    │   ├── common-packages.nix     # The main list of installed apps (gimp, vlc, bat, eza, etc.)
    │   ├── development-tools.nix   # Dev tools: Rust, Python, C/C++, Nix LSP, LaTeX
    │   ├── devshells/              # Isolated dev environments (enter with `nix develop`)
    │   │   ├── c-general-devshell.nix
    │   │   ├── python-devshell.nix
    │   │   └── rust-devshell.nix
    │   ├── doom.nix                # Doom Emacs via nix-doom-emacs-unstraightened
    │   ├── ghostty.nix             # Primary terminal
    │   ├── kitty.nix               # Backup terminal (kept configured but not default)
    │   ├── floorp.nix              # Firefox fork browser config
    │   ├── vscode.nix              # VSCode with extensions
    │   ├── thunderbird.nix         # Email
    │   ├── anki.nix                # Spaced repetition flashcards
    │   ├── retroarch.nix           # Emulation with RetroAchievements support
    │   ├── borg-backup.nix         # Automated backups
    │   ├── dunst.nix               # Notification daemon
    │   ├── ssh.nix                 # SSH config + SOPS-managed GitHub key
    │   └── zsh.nix                 # Zsh shell + Powerlevel10k prompt
    │
    └── desktops/                   # Everything specific to the desktop environment
        ├── common-packages.nix     # Wayland tools: clipboard, screenshot, brightness
        ├── hyprland/               # Hyprland compositor config, split by concern
        │   ├── hyprland.nix        # Monitor layout, visuals, input settings
        │   ├── keybinds.nix        # All keyboard/mouse bindings
        │   ├── exec-once.nix       # Apps that launch at startup
        │   ├── window-rules.nix    # Which apps float, which workspace they land on
        │   ├── hyprlock.nix        # Lockscreen (same wallpaper as desktop)
        │   └── hypridle.nix        # Screen lock + sleep after idle timeout
        └── components/             # Desktop UI components
            ├── bar/                # Waybar config + custom widget scripts
            ├── bemenu/             # App launcher + power menu + VPN selector
            └── screenshot.nix      # Screenshot scripts (full screen and area select)
```

---

## Editors

### Doom Emacs

Managed via [nix-doom-emacs-unstraightened](https://github.com/marienz/nix-doom-emacs-unstraightened), which builds Doom from Nix so it's reproducible and doesn't require a separate `doom sync` step. The actual Doom config (keybindings, packages, theme) lives in [railgun210/doom-emacs](https://github.com/railgun210/doom-emacs) and is pulled in as a flake input — so it rebuilds from that repo automatically.

Uses `emacs-pgtk` for native Wayland rendering. Fast builds come from the [nix-doom-emacs-unstraightened Cachix cache](https://app.cachix.org/cache/doom-emacs-unstraightened) so you don't have to compile everything from scratch.

### Vanilla Neovim

A minimal Neovim with zero plugins is always available for quick terminal edits. `EDITOR` and `VISUAL` both point to `emacsclient` so most tools open Emacs, but Neovim is there when you just need to edit something fast without starting a server.

---

## Theming (Stylix)

The idea: declare one wallpaper, get everything themed automatically.

```nix
# system/stylix.nix — the wallpaper lives here
stylix.image = ../home-manager/wallpapers/still_wallpapers/wallhaven-zpxjjo.jpg;

# home-manager/theming/stylix.nix — inherits from the system config
image = osConfig.stylix.image;
```

Stylix runs a genetic algorithm on the wallpaper to generate a 16-color base16 palette and applies it to: Hyprland, Waybar, Hyprlock, the ReGreet login screen, GTK apps, Qt apps, Ghostty, Kitty, Anki, and more. Desktop, lockscreen, and login screen all match automatically.

VSCode is excluded from Stylix on purpose — it uses the [Turbo C 3.0](https://marketplace.visualstudio.com/items?itemName=WatkinsLabs.turboc-3-0-theme) theme because I like it.

---

## Gaming

`system/gaming.nix` sets up:

- **Steam** with full Proton support (run Windows games natively)
- **Gamescope** — Valve's micro-compositor for games; gives you better frame pacing, HDR, and FSR upscaling even in windowed mode
- **Gamemode** — automatically cranks CPU/IO performance when a game launches, resets when you quit
- **Lutris** — for games not on Steam (GOG, Epic, etc.)
- **MangoHud + GOverlay** — in-game performance overlay with a GUI to configure it

Kernel tweaks: `preempt=full` (snappier desktop while gaming), low swappiness (keeps game data in RAM), and tuned VFS cache pressure (faster game asset reads).

### NVIDIA (RTX 4060)

Proprietary drivers with Wayland modesetting enabled. VA-API hardware video decode is configured so video playback doesn't murder the CPU. 32-bit graphics libraries are included for Proton/Wine compatibility.

Fine-grained power management is intentionally **disabled** — it's still experimental on Ada Lovelace GPUs and can cause stability issues on newer kernels.

### RetroArch

Built from `retroarch-bare` and configured in `home-manager/utilities/retroarch.nix`. Cores included:

| System | Core |
|--------|------|
| NES | Mesen |
| SNES | bsnes-hd + snes9x |
| N64 | mupen64plus |
| PS1 | beetle-psx-hw |
| PS2 | pcsx2 |
| GameCube/Wii | Dolphin |
| GBA | mGBA |
| Dreamcast | Flycast |
| Sega Saturn | beetle-saturn |

RetroAchievements is enabled globally (hardcore mode off so savestates still work). Credentials are stored in SOPS and seeded into RetroArch's config at activation — they never land in the Nix store in plaintext.

BIOS directories are created at activation but BIOS files aren't included — supply your own from legally obtained dumps.

---

## Virtualization and WinApps

`system/virtualisation.nix` enables libvirt/KVM with QEMU, TPM 2.0 (needed for Windows 11), Virt-Manager, SPICE tools, and FreeRDP 3.

WinApps lets you run individual Windows apps (Word, Outlook, etc.) from a headless Windows VM and have them appear as normal Linux windows in your taskbar. `system/winapps.nix` installs the WinApps packages.

The Nix config doesn't create the VM or store Windows credentials. You do that yourself in Virt-Manager. See [docs/virtualisation-winapps.md](docs/virtualisation-winapps.md) for the full setup walkthrough.

---

## Suspend & Power

NVIDIA + Wayland + sleep has historically been a mess. `system/suspend.nix` works around it:

- **Hyprland gets frozen before sleep** — the system sleep hook sends SIGSTOP to the compositor right before the GPU suspends, then SIGCONT after wake. Without this, Hyprland often races the GPU disappearing and hangs.
- **The sched-ext scheduler stops and restarts around sleep** — `scx_rustland` can deadlock on CPU state changes during resume, so it's stopped before sleep and reloaded after.
- **CPU performance settings re-applied on wake** — the AMD EPP setting gets reset by some firmware, so `powerManagement.resumeCommands` reapplies it.
- **Display re-enables with a 1 second delay** — Hypridle waits a beat after resume before turning DPMS back on, which prevents a blank screen race condition.

Locking: `Super + X` locks immediately with Hyprlock. `Super + Shift + X` opens the power menu (Lock / Suspend / Restart / Shutdown / Logout).

---

## Secrets

Secrets (WiFi, PIA credentials, RetroAchievements login, SSH keys) are encrypted with [SOPS](https://github.com/getsops/sops) using an age key that only your machine has.

Edit secrets:
```bash
export EDITOR="emacsclient -a ''"
sops system/secrets/secrets.yaml
```

See [docs/secrets.md](docs/secrets.md) for how to set up the age key on a new machine.

---

## Screenshots

| Action | Keybinding | What happens |
|--------|-----------|-------------|
| Full screen | `Print` | Saves to `~/Pictures/Screenshots/<timestamp>.png` |
| Area select | `Super + Shift + S` | Saves AND copies to clipboard |

Both scripts send a Dunst notification on completion — green on success, red on failure.

---

## Documentation

| Doc | What's in it |
|-----|-------------|
| [docs/devshells.md](docs/devshells.md) | How to use the isolated dev environments |
| [docs/secrets.md](docs/secrets.md) | SOPS age key setup on a new machine |
| [docs/base16-reference.md](docs/base16-reference.md) | Base16 color slot reference for theming |
| [docs/hyprland-animations.md](docs/hyprland-animations.md) | Hyprland animation system and bezier curves |
| [docs/virtualisation-winapps.md](docs/virtualisation-winapps.md) | Full Windows VM + WinApps setup walkthrough |

---

## Deploying on a fresh machine

1. Boot NixOS live ISO
2. Partition and format the disk (BTRFS recommended)
3. Clone this repo
4. Update `system/hardware-configuration.nix` with real UUIDs from `blkid`
5. Update `system/users.nix` with the correct user UID
6. Set up the SOPS age key at `/etc/sops/age/keys.txt` (see [docs/secrets.md](docs/secrets.md))
7. Run `sudo nixos-install --flake .#railgun`
8. Reboot, log in, done
