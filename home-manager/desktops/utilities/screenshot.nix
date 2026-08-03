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
    ${grimshot} save screen "${shotDir}/${timestamp}.png"
  '';

  shot-area = pkgs.writeShellScriptBin "shot-area" ''
    mkdir -p ${shotDir}
    file="${shotDir}/${timestamp}.png"
    ${grimshot} save area "$file"
    if [ -f "$file" ]; then
      ${pkgs.wl-clipboard}/bin/wl-copy < "$file"
    fi
  '';
in
{
  home.packages = [
    shot-full
    shot-area
  ];
}
