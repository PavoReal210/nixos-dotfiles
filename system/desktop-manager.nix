# system/desktop-manager.nix
# SDDM display manager configuration

{ pkgs, ... }:

let
  rosePineSddm = pkgs.stdenv.mkDerivation {
    pname = "rose-pine-sddm";
    version = "1.0";

    src = pkgs.where-is-my-sddm-theme;

    installPhase = ''
            mkdir -p $out/share/sddm/themes

            cp -r \
              $src/share/sddm/themes/where_is_my_sddm_theme \
              $out/share/sddm/themes/rose-pine-moon

            THEME_DIR="$out/share/sddm/themes/rose-pine-moon"

            chmod -R +w "$THEME_DIR"

            #
            # Replace wallpaper
            #

             mkdir -p "$THEME_DIR/backgrounds"
             cp \
               "${../home-manager/wallpapers/still_wallpapers/wallhaven-zpxjjo.jpg}" \
               "$THEME_DIR/backgrounds/default.png"

            #
            # Rose Pine Moon colors
            #

            cat > "$THEME_DIR/theme.conf.user" <<EOF
      [General]
      background="backgrounds/default.png"

      accentColor="#c4a7e7"
      backgroundColor="#232136"
      mainColor="#e0def4"
      secondaryColor="#908caa"

      font="Terminess Nerd Font"
      showSessionsByDefault=true
      blur=true
      forceHideCompletePassword=false
      EOF
    '';
  };
in
{
  services.displayManager.sddm = {
    enable = true;

    package = pkgs.kdePackages.sddm;

    wayland.enable = true;

    theme = "rose-pine-moon";

    settings = {
      General = {
        DisplayServer = "wayland";
      };
    };

    extraPackages = [
      rosePineSddm
      pkgs.kdePackages.qt5compat
    ];
  };

  environment.systemPackages = [
    rosePineSddm
  ];
}
