# Right now, we only use this to pimp out our fastfetch
{config, ...}: {
  programs.hm-ricing-mode = {
    enable = true;
    apps = {
      fastfetch.dest_dir = ".config/fastfetch";
    };
  };
}
