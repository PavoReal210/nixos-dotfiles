{
  config,
  lib,
  pkgs,
  ...
}:

let
  c = config.lib.stylix.colors;
  bemenuSettings = {
    tb = "#${c.base00}";
    tf = "#${c.base0D}";
    fb = "#${c.base00}";
    ff = "#${c.base05}";
    nb = "#${c.base00}";
    nf = "#${c.base05}";
    hb = "#${c.base0D}";
    hf = "#${c.base00}";
    fn = config.utils.fonts.describeFont config.utils.fonts.status;
  };
in
{
  programs.bemenu = {
    enable = true;

    # Integrated Home Manager does not expose its shell session variables to
    # the graphical NixOS session, so bmenu needs this environment.d entry to
    # receive the same colors and font when launched from Hyprland.
    settings = lib.mapAttrs (_: lib.mkForce) bemenuSettings;
  };

  xdg.configFile."environment.d/20-bemenu.conf".text =
    let
      bemenuOpts = lib.cli.toCommandLineShell (optionName: {
        option = if builtins.stringLength optionName > 1 then "--${optionName}" else "-${optionName}";
        sep = null;
        explicitBool = false;
      }) config.programs.bemenu.settings;
    in
    "BEMENU_OPTS=${bemenuOpts}\n";

  home.packages = with pkgs; [ bemoji ];
}
