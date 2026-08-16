{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.floorp = {
    enable = true;

    profiles.default = {
      settings = {
        # ── WebRender / GPU compositing ────────────────────────────────────────
        #
        # NOTE: gfx.webrender.compositor is deliberately DISABLED on NVIDIA+Wayland
        # because it causes flickering, black popups, and rendering corruption with
        # the proprietary driver. WebRender itself (gfx.webrender.all) works fine.

        "gfx.webrender.all" = true;
        "gfx.webrender.compositor" = false;
        "gfx.webrender.compositor.force-enabled" = false;
        "gfx.webrender.renderer" = "opengl";
        "layers.gpu-process.enabled" = true;
        "layers.gpu-process.force-enabled" = true;
        "layers.acceleration.force-enabled" = true;
        "webgl.out-of-process.enabled" = true;
        "media.gpu-process-decoder" = true;
        "gfx.canvas.accelerated" = true;

        # ── Hardware video decode (NVDEC via VA-API) ───────────────────────────
        #
        # NOTE: nvidia-vaapi-driver adds a GPU→RAM→GPU round-trip per frame.
        # If video feels stuttery, try setting this to false.

        "media.hardware-video-decoding.enabled" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.av1.enabled" = true;
        "media.mediasource.vp9.enabled" = true;

        # ── Network performance ────────────────────────────────────────────────

        "network.http.http3.enabled" = true;
        "network.http.max-persistent-connections-per-server" = 10;
        "network.dns.disablePrefetch" = false;
        "network.prefetch-next" = true;

        # ── Memory / process management ────────────────────────────────────────

        "browser.sessionstore.interval" = 60000;
        "browser.sessionstore.max_resumed_crashes" = 0;

        # ── Wayland ───────────────────────────────────────────────────────────

        "widget.wayland.fractional-scale.enabled" = true;
        "widget.wayland-native.enabled" = true;

        # ── Misc ───────────────────────────────────────────────────────────────

        "accessibility.force_disabled" = 1;
        "security.sandbox.content.level" = 3;
        "datareporting.healthreport.uploadEnabled" = false;
        "toolkit.telemetry.enabled" = false;
        "app.update.auto" = false;
      };

      userChrome = ''
        #tabbrowser-tabs {
          --tab-loading-fill: transparent;
        }
        .tab-throbber { display: none !important; }
      '';
    };

    policies = {
      DontCheckDefaultBrowser = true;
      DisableFirefoxStudies = true;
      DisableTelemetry = true;
    };
  };

  stylix.targets.floorp = {
    enable = true;
    profileNames = ["default"];
  };
}
