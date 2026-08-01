{
  lib,
  pkgs,
  ...
}:
{
  programs.dconf.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # NOTE: defaultSession is intentionally removed so SDDM remembers
  # whichever session you last selected.

  # ── XDG desktop portal ───────────────────────────────────────────────────────

  services.dbus.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config = {
      hyprland = {
        "org.freedesktop.impl.portal.ScreenCast" = "hyprland";
        "org.freedesktop.impl.portal.Screenshot" = "hyprland";
        default = [ "gtk" ];
      };
      common.default = [ "gtk" ];
    };
  };

  # ── File manager (Thunar) ────────────────────────────────────────────────────

  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.tumbler.enable = true;

  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-vcs-plugin
      thunar-dropbox-plugin
      thunar-media-tags-plugin
      thunar-volman
    ];
  };

  # Archive right-click support: thunar-archive-plugin adds "Extract Here" /
  # "Extract To..." to the context menu; file-roller is the GUI backend that
  # performs the extraction. unrar + unar cover .rar (incl. RAR5) and other
  # formats that file-roller shells out to.
  environment.systemPackages = with pkgs; [
    file-roller
    unrar
    unar
  ];

  programs.xfconf.enable = true;

  environment.etc."udisks2/mount_options.conf".text = ''
    [defaults]
    ntfs_defaults=uid=$UID,gid=$GID
  '';

  # ── Filesystem performance ───────────────────────────────────────────────────
  #
  # BTRFS optimizations for SSD + desktop workload:
  #   compress=zstd — reduces disk I/O by compressing data in RAM before writing;
  #                   zstd offers the best ratio/speed tradeoff and is built into
  #                   the kernel. Reads are decompressed on the fly, which is fast
  #                   on modern CPUs and effectively increases SSD read throughput.
  #   noatime       — skips writing access-time metadata on every file read,
  #                   eliminating a huge source of small random writes.
  #   ssd           — tells BTRFS the device is an SSD, enabling TRIM/discard
  #                   and disabling page-cache alignment hacks meant for HDDs.
  #   discard=async — queues TRIM commands asynchronously so they don't block
  #                   the submitting thread; the kernel batches them via kworker.
  fileSystems."/".options = lib.mkAfter [
    "compress=zstd"
    "noatime"
    "ssd"
    "discard=async"
  ];
  fileSystems."/home".options = lib.mkAfter [
    "compress=zstd"
    "noatime"
    "ssd"
    "discard=async"
  ];

  # ── Cursor ───────────────────────────────────────────────────────────────────

  environment.variables = {
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "16";
  };

  # ── Wayland application compatibility ────────────────────────────────────────

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland;xcb";

    # Disable driver vsync — gamescope handles its own presentation pipeline
    __GL_SYNC_TO_VBLANK = "0";
  };
}
