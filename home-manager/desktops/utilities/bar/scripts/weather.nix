{pkgs, ...}:
pkgs.writeShellScriptBin "weather" ''
  if [ -z "$WEATHER_API_KEY_FILE" ] || [ ! -f "$WEATHER_API_KEY_FILE" ]; then
    WEATHER_API_KEY_FILE="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/secrets/weather-api-key"
  fi
  if [ -n "$WEATHER_API_KEY_FILE" ] && [ -f "$WEATHER_API_KEY_FILE" ]; then
    export WEATHER_API_KEY=$(cat "$WEATHER_API_KEY_FILE")
  fi
  output=$(${pkgs.wttrbar}/bin/wttrbar --location "San Antonio" --fahrenheit --nerd --custom-indicator '{ICON}|{temp_F}' 2>/dev/null)
  if [ -n "$output" ]; then
    echo "$output" | ${pkgs.jq}/bin/jq -c '
      .text as $t |
      ($t | split("|")) as $parts |
      ($parts[0] + " " + (if $parts[1] then $parts[1] else "N/A" end)) as $combined |
      {
        text: $combined,
        class,
        tooltip
      }
    '
  else
    echo '{"text":"󰖑 N/A","class":"error","tooltip":"Weather unavailable"}'
  fi
''
