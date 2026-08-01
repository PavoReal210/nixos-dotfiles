{
  pkgs,
  ...
}:
let
  windowSwitcher = pkgs.writeShellScriptBin "window-switcher" ''
    hyprctl clients -j 2>/dev/null | ${pkgs.jq}/bin/jq -r '
      .[] |
      "\(.address)\u0000\(.class)\u0000\(.title // "")"
    ' | while IFS=$'\0' read -r addr class title; do
      [ -z "$addr" ] && continue
      case "$class" in
        "floorp"|"Floorp")             icon="" ;;
        "Alacritty"|"Ghostty"|"kitty") icon="" ;;
        "thunar"|"Thunar")             icon="" ;;
        "code"|"Code"|"code-oss")      icon="" ;;
        "vlc"|"VLC")                   icon="󰕼" ;;
        "strawberry"|"Strawberry")     icon="" ;;
        "thunderbird"|"Thunderbird")   icon="" ;;
        "steam"|"Steam")               icon="" ;;
        "Anki")                        icon="" ;;
        *)                             icon="" ;;
      esac
      short=$(echo "$title" | head -c 60)
      echo -e "$icon $short\t$addr"
    done | ${pkgs.bemenu}/bin/bemenu -p "Window" -l 20 -n | awk '{print $NF}' | {
      read -r addr
      [ -n "$addr" ] && hyprctl dispatch focuswindow "address:0x$addr" 2>/dev/null
    }
  '';
in
{
  home.packages = [ windowSwitcher ];
}
