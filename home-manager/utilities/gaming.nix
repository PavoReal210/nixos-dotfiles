# home-manager/utilities/gaming.nix
# User-level gaming packages and configuration
{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    goverlay # GUI for MangoHud

    # RetroArch — retro game emulation.
    # nixpkgs has no `programs.retroarch` module, so we wrap `retroarch-bare`.
    # `cores` bundles the libretro cores into the wrapper. All configuration is
    # managed by RetroArch itself via ~/.config/retroarch/retroarch.cfg (the
    # in-app menu / config file); no declarative settings are injected.
    (pkgs.retroarch-bare.wrapper {
      cores = with pkgs.libretro; [
        mesen # NES
        bsnes-hd # SNES (HD mode / supersampling)
        snes9x # SNES (fallback core)
        mupen64plus # Nintendo 64
        beetle-psx-hw # PlayStation 1
        pcsx2 # PlayStation 2
        dolphin # GameCube / Wii
        mgba # Game Boy / GBA
        flycast # Dreamcast
        beetle-saturn # Sega Saturn
      ];
      settings = { };
    })
  ];

  # RetroAchievements account credentials.
  # These must never end up in the nix store, so they come from sops like the
  # SSH keys (see ssh.nix). Decrypted to ~/.config/sops-nix/secrets/ at runtime
  # by the sops-nix user service, then seeded into retroarch.cfg below.
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    secrets.retroachievements-username.sopsFile = ../../system/secrets/secrets.yaml;
    secrets.retroachievements-password.sopsFile = ../../system/secrets/secrets.yaml;
  };

  home.activation = {
    # Seed per-core upscaling into retroarch-core-options.cfg, but ONLY if the
    # file does not exist yet (seed-if-absent). This gives a great first-run
    # experience without ever clobbering tweaks you make in the in-game
    # Quick Menu -> Options. Unknown keys are dropped harmlessly by cores that
    # don't use them.
    seedRetroArchCoreOptions = lib.hm.dag.entryAfter ["writeBoundary"] ''
      CORE_OPTIONS="$HOME/.config/retroarch/retroarch-core-options.cfg"
      if [[ ! -e "$CORE_OPTIONS" ]]; then
        mkdir -p "$(dirname "$CORE_OPTIONS")"
        for line in \
          'beetle_psx_hw_internal_resolution = "4x"' \
          'mupen64plus-next-ScreenSize = "6"' \
          'pcsx2_Internal_Resolution = "4x"' \
          'dolphin_InternalResolution = "4x"' \
          'flycast_rendering_resolution = "1440x1440"' \
          'beetle_saturn_resolution = "6"' \
          'bsnes_hd_supersampling = "true"'
        do
          echo "$line"
        done > "$CORE_OPTIONS"
      fi
    '';

    # Download the BIOS/system files the chosen cores actually need into
    # ~/Emulation/bios, but only the ones missing on disk (idempotent — a
    # manually-curated BIOS folder is never overwritten).
    #
    # Source: Abdess/retrobios, pinned to a commit for reproducibility.
    # The repo organizes BIOS under bios/<Manufacturer>/<System>/..., which is
    # NOT where RetroArch looks: cores want exact filenames at the top of the
    # system dir (or in pcsx2/bios/), so we place each file exactly where the
    # core will find it. NES/SNES/N64/GBA/GC need no BIOS at all.
    linkRetroArchBios = lib.hm.dag.entryAfter ["writeBoundary"] ''
      BIOS_DIR="$HOME/Emulation/bios"
      mkdir -p "$BIOS_DIR/pcsx2/bios"

      fetch_bios() {
        local url="$1" dest="$2"
        if [[ ! -e "$dest" ]]; then
          mkdir -p "$(dirname "$dest")"
          ${pkgs.curl}/bin/curl -fsSL "$url" -o "$dest"
          chmod 644 "$dest"
        fi
      }

      REV=e90095abd9417d78327bd0fe0666f6dc102eb06b
      BASE="https://raw.githubusercontent.com/Abdess/retrobios/$REV/bios"

      # PlayStation (beetle-psx-hw): JP / US / EU BIOS at system dir root.
      fetch_bios "$BASE/Sony/PlayStation/scph5500.bin" "$BIOS_DIR/scph5500.bin"
      fetch_bios "$BASE/Sony/PlayStation/scph5501.bin" "$BIOS_DIR/scph5501.bin"
      fetch_bios "$BASE/Sony/PlayStation/scph5502.bin" "$BIOS_DIR/scph5502.bin"
      # PlayStation 2 (pcsx2): the BIOS must live under pcsx2/bios/.
      # SCPH-39001 is the community-recommended NTSC-U dump; pcsx2 generates
      # its nvm/eeprom files on first boot.
      fetch_bios "$BASE/Sony/PlayStation%202/SCPH-39001.bin" "$BIOS_DIR/pcsx2/bios/SCPH-39001.bin"
      # Dreamcast (flycast): boot ROM + flash ROM at system dir root.
      fetch_bios "$BASE/Sega/Dreamcast/dc_boot.bin" "$BIOS_DIR/dc_boot.bin"
      fetch_bios "$BASE/Sega/Dreamcast/dc_flash.bin" "$BIOS_DIR/dc_flash.bin"
      # Sega Saturn (beetle-saturn): mpr-17933.bin is an accepted BIOS name.
      fetch_bios "$BASE/Sega/Saturn/mpr-17933.bin" "$BIOS_DIR/mpr-17933.bin"
    '';

    # Seed the RetroAchievements credentials from sops into retroarch.cfg,
    # since RetroArch reads these two keys from that file. Guarded so it only
    # runs once the sops-nix service has decrypted the secrets, and never
    # duplicates keys the UI may already have written.
    # Caveat: if the sops service hasn't decrypted yet at switch time, just
    # re-run the switch after login — this is idempotent.
    seedRetroArchCheevos = lib.hm.dag.entryAfter ["writeBoundary"] ''
      RA_CFG="$HOME/.config/retroarch/retroarch.cfg"
      USER_FILE="$HOME/.config/sops-nix/secrets/retroachievements-username"
      PASS_FILE="$HOME/.config/sops-nix/secrets/retroachievements-password"
      if [[ -f "$USER_FILE" && -f "$PASS_FILE" ]]; then
        mkdir -p "$(dirname "$RA_CFG")"
        [[ -e "$RA_CFG" ]] || touch "$RA_CFG"
        grep -q '^cheevos_username' "$RA_CFG" || echo "cheevos_username = \"$(cat "$USER_FILE")\"" >> "$RA_CFG"
        grep -q '^cheevos_password' "$RA_CFG" || echo "cheevos_password = \"$(cat "$PASS_FILE")\"" >> "$RA_CFG"
      fi
    '';
  };
}
