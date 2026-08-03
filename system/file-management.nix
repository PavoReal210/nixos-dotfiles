# system/file-management.nix
# Thunar file manager + archive support
{
  pkgs,
  ...
}:
{
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
}
