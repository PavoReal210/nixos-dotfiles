{pkgs, ...}: let
  piaSelectorScript = pkgs.writeShellScriptBin "pia-selector" ''
    refresh_waybar() {
      pid=$(pgrep -x waybar | head -1)
      [ -n "$pid" ] && kill -RTMIN+1 "$pid" 2>/dev/null || true
    }

    if STATUS=$(${pkgs.pia}/bin/pia status --short 2>/dev/null) && [ "$(echo "$STATUS" | cut -d: -f1)" = "connected" ]; then
      ${pkgs.pia}/bin/pia disconnect
      notify-send "PIA VPN" "Disconnected"
      refresh_waybar
    else
      regions=$(${pkgs.pia}/bin/pia list 2>/dev/null | awk 'NR>3 && /^[a-z]/ {id=$1; $1=""; $NF=""; gsub(/^ +| +$/, "", $0); print id" "$0}')
      if [ -z "$regions" ]; then
        notify-send -u critical "PIA VPN" "No regions available"
        exit 1
      fi

      chosen=$(echo "$regions" | bemenu-themed -p "VPN" -l 15 2>/dev/null)
      [ -z "$chosen" ] && exit 0

      region_id=$(echo "$chosen" | awk '{print $1}')
      ${pkgs.pia}/bin/pia connect "$region_id" 2>/dev/null

      for i in 1 2 3 4 5; do
        S=$(${pkgs.pia}/bin/pia status --short 2>/dev/null | tr -d '[:space:]' | cut -d: -f1)
        if [ "$S" = "connected" ]; then
          notify-send "PIA VPN" "Connected to $region_id"
          break
        fi
        sleep 1
      done
      refresh_waybar
    fi
  '';
in {
  home.packages = [piaSelectorScript];
}
