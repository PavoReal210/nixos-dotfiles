{pkgs, ...}:
pkgs.writeShellScriptBin "keyboard-toggle" ''
  kb_name=$(hyprctl devices -j 2>/dev/null | ${pkgs.jq}/bin/jq -r '.keyboards[0].name' 2>/dev/null)
  if [ -n "$kb_name" ]; then
    hyprctl switchxkblayout "$kb_name" next 2>/dev/null
  fi

  # Signal waybar to refresh the keyboard layout module
  ${pkgs.procps}/bin/pkill -x -RTMIN+2 waybar 2>/dev/null || true
''
