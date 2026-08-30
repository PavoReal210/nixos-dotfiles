# home-manager/utilities/doom.nix
# Doom Emacs via nix-doom-emacs-unstraightened
{
  inputs,
  pkgs,
  ...
}: let
  aspellEnv = pkgs.aspellWithDicts (dicts: with dicts; [en es]);
in {
  programs.doom-emacs = {
    enable = true;
    doomDir = inputs.doomdir;
    emacs = pkgs.emacs-pgtk;
    extraBinPackages = with pkgs; [
      ripgrep
      fd
      git
      ispell
      aspellEnv
    ];
  };

  # Run emacs daemon on boot
  services.emacs.enable = true;

  # The Emacs daemon starts before Hyprland exports WAYLAND_DISPLAY to the
  # systemd user environment, so the daemon never inherits it.  Set both
  # variables at the service level so wl-paste / wl-copy work from the daemon
  # (needed for org-download clipboard paste of screenshots).
  systemd.user.services.emacs.Service.Environment = [
    "WAYLAND_DISPLAY=wayland-1"
    "XDG_SESSION_TYPE=wayland"
  ];
}
