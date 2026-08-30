{pkgs, ...}:
pkgs.writeShellScriptBin "system-temps" ''
  CPU=$(${pkgs.lm_sensors}/bin/sensors -u 2>/dev/null | ${pkgs.gawk}/bin/awk '
    /^  temp[0-9]+_input:/ { if ($2 > max) max = $2 }
    END { if (max != "") printf "%d", max + 0.5 }
  ')
  [ -z "$CPU" ] && CPU="N/A"

  GPU_OUT=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null)
  if [ "$?" -eq 0 ] && [ -n "$GPU_OUT" ] && [ "$GPU_OUT" -gt 0 ] 2>/dev/null; then
    GPU="$GPU_OUT"
  else
    GPU="N/A"
  fi

  echo "{\"text\":\"CPU: ''${CPU}°C  GPU: ''${GPU}°C\",\"tooltip\":\"CPU: ''${CPU}°C\\nGPU: ''${GPU}°C\"}"
''
