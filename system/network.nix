# system/network.nix
# Networking configuration
{ config, ... }:
{
  # Sops secrets
  # Add new secrets to this instead of declaring them further down.
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    age.keyFile = "/etc/sops/age/keys.txt";
    secrets."wifi" = { };
  };

  # Networking settings for wifi
  # Took FOREVER to get this right.
  # The main advantage of using networkmanager is that you can pass in secrets for the wifi password AND ssid.
  # Thank ShcokWave-1 on Nix discourse for setting me straight with this setup.
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # SSH
        5500 # live-server
        8081 # qbittorrent WebUI
      ];
    };
    hostName = "railgun-linux-desktop";
    networkmanager = {
      enable = true;
      # Push DNS via systemd-resolved instead of letting NetworkManager write
      # /etc/resolv.conf directly. Required so the PIA VPN CLI's resolvectl-based
      # DNS handling (system/vpn.nix) coexists with NetworkManager; otherwise the
      # two fight over resolv.conf, and when the VPN tunnel dies (e.g. suspend)
      # a stale PIA nameserver gets left in place, breaking DNS until resolv.conf
      # is regenerated.
      dns = "systemd-resolved";
      ensureProfiles = {
        environmentFiles = [
          config.sops.secrets."wifi".path
        ];
        profiles = {
          home-wifi = {
            connection = {
              id = "home-wifi";
              permissions = "";
              type = "wifi";
            };
            wifi = {
              mode = "infrastructure";
              ssid = "$ssid";
            };
            wifi-security = {
              auth-alg = "open";
              key-mgmt = "wpa-psk";
              psk = "$psk";
            };
          };
        };
      };
    };
  };

  # NetworkManager group
  users.groups.networkmanager = { };
}
