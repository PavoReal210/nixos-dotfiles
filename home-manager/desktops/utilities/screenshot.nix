{
  pkgs,
  ...
}:
let
  grimshot = "${pkgs.sway-contrib.grimshot}/bin/grimshot";
  shotDir = "$HOME/Pictures/Screenshots";
  timestamp = "$(date +%Y-%m-%d_%H%M%S)";

  shot-full = pkgs.writeShellScriptBin "shot-full" ''
    mkdir -p ${shotDir}
    file="${shotDir}/${timestamp}.png"
    if ${grimshot} save screen "$file"; then
      notify-send "Screenshot" "Saved: $file"
    else
      notify-send -u critical "Screenshot" "Failed: $file"
    fi
  '';

  shot-area = pkgs.writeShellScriptBin "shot-area" ''
    mkdir -p ${shotDir}
    file="${shotDir}/${timestamp}.png"
    if ${grimshot} save area "$file" && [ -f "$file" ]; then
      ${pkgs.wl-clipboard}/bin/wl-copy < "$file"
      notify-send "Screenshot" "Saved: $file"
    else
      notify-send -u critical "Screenshot" "Failed: $file"
    fi
  '';
in
{
  home.packages = [
    shot-full
    shot-area
  ];
}
