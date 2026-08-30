{pkgs, ...}:
pkgs.writeShellScriptBin "pia-status" ''
  STATUS=$(${pkgs.pia}/bin/pia status --short 2>/dev/null)
  if echo "$STATUS" | ${pkgs.gnugrep}/bin/grep -qiw "connected"; then
    echo "{\"text\": \"\", \"class\": \"connected\"}"
  else
    echo "{\"text\": \"\", \"class\": \"disconnected\"}"
  fi
''
