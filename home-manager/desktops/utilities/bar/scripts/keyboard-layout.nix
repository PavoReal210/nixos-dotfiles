{pkgs, ...}:
pkgs.writeShellScriptBin "keyboard-layout" ''
  layout=$(hyprctl devices -j 2>/dev/null | ${pkgs.jq}/bin/jq -r '.keyboards[0].active_keymap' 2>/dev/null)

  cache="''${XDG_RUNTIME_DIR:-/tmp}/kbd-layout"

  if [ -f "$cache" ]; then
    prev=$(cat "$cache")
    if [ "$prev" != "$layout" ]; then
      :
    fi
  fi
  printf '%s' "$layout" > "$cache"

  if echo "$layout" | ${pkgs.gnugrep}/bin/grep -qi "english"; then
    echo '{"text": "en", "class": "en"}'
  else
    echo '{"text": "es", "class": "es"}'
  fi
''
