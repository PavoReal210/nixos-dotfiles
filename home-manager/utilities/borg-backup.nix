# home-manager/utilities/borg-backup.nix
# BorgBackup configuration
{pkgs, ...}: {
  home.packages = with pkgs; [
    borgbackup
  ];
}
