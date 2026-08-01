{
  config,
  pkgs,
  ...
}:

let
  c = config.lib.stylix.colors;
  bg = "#${c.base00}";
  fg = "#${c.base05}";
  dim = "#${c.base03}";
  accent = "#${c.base0D}";
  red = "#${c.base08}";
  yellow = "#${c.base09}";
  green = "#${c.base0B}";
  pia-status = import ./scripts/pia-status.nix { inherit pkgs; };
  keyboard-layout = import ./scripts/keyboard-layout.nix { inherit pkgs; };
  keyboard-toggle = import ./scripts/keyboard-toggle.nix { inherit pkgs; };
  system-temps = import ./scripts/system-temps.nix { inherit pkgs; };
  weather = import ./scripts/weather.nix { inherit pkgs; };

in
{
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    secrets.weather-api-key = {
      sopsFile = ../../../../system/secrets/weather-api-key.age;
      format = "binary";
    };
  };

  home.packages = with pkgs; [
    pia-status
    system-temps
    keyboard-layout
    keyboard-toggle
    gawk
    networkmanagerapplet
    blueman
    wttrbar
    weather
  ];

  programs.waybar = {
    enable = true;
    systemd.enable = false;

    settings = [
      {
        height = 0;
        position = "top";
        spacing = 0;

        modules-left = [
          "hyprland/workspaces"
        ];

        # Center: media info — built-in mpris module via playerctld
        modules-center = [
          "mpris"
        ];

        modules-right = [
          "custom/pia-status"
          "custom/keyboard-layout"
          "bluetooth"
          "network"
          "pulseaudio"
          "idle_inhibitor"
          "custom/system-temps"
          "custom/weather"
          "clock"
        ];

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "10" = "10";
          };
          all-outputs = true;
          on-click = "activate";
        };

        "custom/pia-status" = {
          exec = "${pia-status}/bin/pia-status";
          return-type = "json";
          interval = 10;
          exec-on-event = true;
          format = "<span foreground='${dim}'>vpn</span> {text}";
        };

        # Now-playing — built-in mpris module via playerctld
        # Displays current track from any MPRIS player (Firefox/YouTube, Strawberry, etc.)
        # Uses libplayerctl natively — no polling, no exec scripts needed
        "mpris" = {
          format = "{player_icon} {dynamic}";
          format-paused = "{player_icon} <i>{dynamic}</i>";
          dynamic-len = 60;
          dynamic-order = ["artist" "title" "album"];
          tooltip-format = "{player} ({status})\n{artist} - {title}\n{album}";
          player-icons = {
            "firefox" = "󰈹";
            "floorp" = "󰈹";
            "chromium" = "󰊯";
            "chrome" = "󰊯";
            "strawberry" = "";
            "vlc" = "";
            "mpv" = "";
            "default" = "";
          };
          status-icons = {
            "paused" = "";
          };
          on-click = "play-pause";
        };

        "custom/weather" = {
          exec = "WEATHER_API_KEY_FILE=${config.sops.secrets.weather-api-key.path} ${weather}/bin/weather";
          return-type = "json";
          interval = 1800;
          format = "<span foreground='${dim}'>weather</span> {text}";
          on-click = "${pkgs.floorp-bin}/bin/floorp 'https://wttr.in/San%20Antonio'";
        };

        "custom/keyboard-layout" = {
          exec = "${keyboard-layout}/bin/keyboard-layout";
          return-type = "json";
          interval = 0;
          exec-on-event = true;
          signal = 2;
          format = "<span foreground='${dim}'>α</span> {text}";
          on-click = "${keyboard-toggle}/bin/keyboard-toggle";
        };

        "custom/system-temps" = {
          exec = "${system-temps}/bin/system-temps";
          return-type = "json";
          interval = 5;
          exec-on-event = true;
          format = "<span foreground='${dim}'>temps</span> {text}";
          on-click = "${pkgs.ghostty}/bin/ghostty -e ${pkgs.btop}/bin/btop";
        };

        "memory" = {
          interval = 5;
          format = "<span foreground='${dim}'>mem</span> {percentage}%";
          on-click = "${pkgs.ghostty}/bin/ghostty -e ${pkgs.btop}/bin/btop";
          states = {
            warning = 70;
            critical = 90;
          };
        };

        "clock" = {
          interval = 60;
          format = "<span foreground='${dim}'>󰃰</span> {:%a %d %b   %H:%M}";
          tooltip-format = "{calendar}";
          calendar = {
            mode = "month";
            weeks-pos = "left";
            format = {
              months = "<span color='${fg}'><b>{}</b></span>";
              days = "<span color='${dim}'><b>{}</b></span>";
              weeks = "<span color='${fg}'><b>{:%V}</b></span>";
              weekdays = "<span color='${dim}'><b>{}</b></span>";
              today = "<span color='${accent}'><b>{}</b></span>";
            };
          };
          on-click = "${pkgs.thunderbird}/bin/thunderbird -calendar";
        };

        "network" = {
          interval = 2;
          format-wifi = "<span foreground='${dim}'>net</span> {signalStrength}%";
          format-ethernet = "<span foreground='${dim}'>net</span> on";
          format-disconnected = "<span foreground='${dim}'>net</span> off 󰤮";
          tooltip-format-wifi = "{essid} ({frequency} GHz)\n⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
          tooltip-format-ethernet = "⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
          tooltip-format-disconnected = "Disconnected";
          on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
        };

        "bluetooth" = {
          format = "<span foreground='${dim}'>bt</span> off";
          format-disabled = "";
          format-connected = "<span foreground='${dim}'>bt</span> {device_alias}";
          format-no-controller = "";
          tooltip-format = "{device_alias}";
          on-click = "${pkgs.blueman}/bin/blueman-manager";
        };

        "pulseaudio" = {
          format = "<span foreground='${dim}'>{icon}</span> {volume}%";
          format-muted = "<span foreground='${dim}'>󰝟</span>";
          format-source = "<span foreground='${dim}'></span> {volume}%";
          format-source-muted = "<span foreground='${dim}'></span>";
          format-icons = {
            headphone = "";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
          on-click-right = "${pkgs.pamixer}/bin/pamixer -t";
          scroll-step = 5;
        };

        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
            activated = "<span foreground='${dim}'>idle</span> <span foreground='${accent}'>on</span>";
            deactivated = "<span foreground='${dim}'>idle</span> <span foreground='${accent}'>off</span>";
          };
        };

        "tray" = {
          icon-size = 18;
          spacing = 5;
        };
      }
    ];

    style = ''
      @define-color background ${bg};
      @define-color foreground ${fg};
      @define-color dim        ${dim};
      @define-color accent     ${accent};
      @define-color red        ${red};
      @define-color yellow     ${yellow};
      @define-color green      ${green};

      * {
        border: none;
        border-radius: 0;
        font-family: "${config.utils.fonts.status.family}:style=${config.utils.fonts.status.style}";
        font-size: ${toString config.utils.fonts.status.size}px;
        font-weight: ${config.utils.fonts.status.weight};
      }

      window#waybar {
        background: @background;
        color: @foreground;
        font-size: 18px;
        transition-property: background-color;
        transition-duration: 0.5s;
        border-bottom: 2px solid alpha(@foreground, 0.1);
      }

      #waybar {
        font-size: 18px;
      }

      label {
        font-size: 18px;
      }

      #workspaces button {
        padding: 0 6px;
        background: transparent;
        color: @foreground;
        border-top: 2px solid transparent;
        border-bottom: 2px solid transparent;
        font-weight: 900;
      }

      #workspaces button.focused {
        border-bottom: 2px solid @green;
      }

      #workspaces button.urgent {
        border-bottom: 2px solid @yellow;
      }

      #workspaces button:hover {
        background: transparent;
        opacity: 0.75;
      }

      #workspaces button.empty {
        opacity: 0.4;
      }

      #mode {
        border-bottom: 2px solid @red;
      }

      #memory.warning,
      #cpu.warning {
        border-top: 2px solid transparent;
        border-bottom: 2px solid @yellow;
      }

      #memory.critical,
      #cpu.critical {
        border-top: 2px solid transparent;
        border-bottom: 2px solid @red;
      }

      #custom-pia-status,
      #custom-keyboard-layout,
      #custom-weather,
      #custom-system-temps,
      #mpris,
      #memory,
      #clock,
      #network,
      #bluetooth,
      #pulseaudio,
      #idle_inhibitor,
      #tray {
        padding: 0 8px;
        margin: 0 2px;
      }

      #tray {
        padding-top: 3px;
      }

      #idle_inhibitor.deactivated {
        opacity: 0.5;
      }

      #idle_inhibitor.activated {
        opacity: 1;
      }

      #custom-pia-status {
        min-width: 12px;
      }

      #mpris {
        margin-right: 24px;
      }

      #mpris.paused {
        opacity: 0.5;
      }

      tooltip {
        padding: 5px;
        background: @background;
        font-size: 13px;
        border: 2px solid alpha(@foreground, 0.6);
        border-radius: 10px;
      }

      tooltip label {
        color: @foreground;
        font-weight: normal;
      }
    '';
  };
}
