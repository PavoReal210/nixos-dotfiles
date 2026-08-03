{
  pkgs,
  ...
}:
let
  powerMenuScript = pkgs.writeShellScriptBin "powermenu-bemenu" ''
    chosen=$(printf '⏻ Shutdown\n⏼ Restart\n󰤄 Suspend\n Lock\n󰍃 Logout' \
      | ${pkgs.bemenu}/bin/bemenu -p "Power" -l 5)

    case "$chosen" in
      "⏻ Shutdown") systemctl poweroff ;;
      "⏼ Restart")   systemctl reboot ;;
      "󰤄 Suspend")   systemctl suspend ;;
      " Lock")
        ${pkgs.hyprlock}/bin/hyprlock
        ;;
      "󰍃 Logout")
        hyprctl dispatch exit
        ;;
    esac
  '';
in
{
  home.packages = [ powerMenuScript ];
}
