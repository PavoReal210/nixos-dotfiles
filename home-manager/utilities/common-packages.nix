# home-manager/utilities/common-packages.nix
# Common user packages
{ pkgs, ... }: {
  home.packages = with pkgs; [
    # GUI Applications
    (pidgin.override { plugins = [ pidginPackages.purple-discord ]; }) # Discord via Pidgin (no Electron)
    gimp # Image editing
    krita # Digital painting
    xournalpp # Handwritten notes and Org-mode figures
    libreoffice-qt6 # Office suite
    atril # PDF reader
    picard # Music metadata editor
    prismlauncher # Minecraft launcher
    goverlay # GUI for MangoHud
    vlc # Media player
    strawberry # Music player
    qbittorrent # Torrent client
    font-manager # Manually select bitmaps for special fonts
    maestral # FOSS Dropbox CLI
    maestral-gui # FOSS Dropbox client
    todoist-electron # Our favorite todo list app

    cpu-x # CPU info

    # CLI Tools
    bat # Better cat
    eza # Better ls
    fd # Better find
    ffmpeg # Media conversion
    fzf # Fuzzy finder
    imagemagick # Image manipulation
    libpng # PNG library
    librsvg # SVG rendering
    celluloid # GTK frontend for mpv
    mpv # Video player (no custom config — default NixOS mpv wrapper)
    killall # Process killer
    ripgrep # Better grep
    stress # CPU stress test
    yt-dlp # YouTube/m3u8 downloader
    fastfetch # System info
    base16-shell-preview # Base16 color scheme preview in terminal

    # Development
    docker_29 # At some point you'll have to manually switch this back to just Docker when it gets updated.
    lazygit # Git TUI

    # Fonts and themes
    calibre # Ebook management
    cozette # Custom font for status bars

    # System tools
    gparted
    hyprpolkitagent # Polkit auth agent (lets pkexec apps like gparted prompt for password)
  ];

  # Default file manager for directories (xdg-open): Thunar is enabled
  # system-wide in system/file-management.nix via programs.thunar.
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications."inode/directory" = [ "thunar.desktop" ];
}
