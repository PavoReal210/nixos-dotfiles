# system/bluetooth.nix
# Bluetooth configuration
{
  pkgs,
  config,
  lib,
  ...
}: {
  # MediaTek (and some Intel/Realtek) Bluetooth chips need firmware blobs
  # from linux-firmware to initialize. Without this the chip will sometimes
  # fails with the message: "Failed to send wmt func ctrl (-22)"
  # and no adapter will be detected using Bluetooth Manager.
  hardware.enableRedistributableFirmware = true;

  # Fix MediaTek MT7921 BT "Failed to send wmt func ctrl (-22)" error.
  # USB autosuspend causes the chip to enter a low-power state it can't
  # recover from during initialization. Disabling it allows the firmware
  # to load correctly on every boot.
  boot.kernelParams = [
    "btusb.enable_autosuspend=0"
  ];
  # Keep this as a belt-and-suspenders fallback
  boot.extraModprobeConfig = ''
    options btusb enable_autosuspend=N
    options mt7921e disable_aspm=1
  '';

  # Workaround for kernel regression in btmtk driver (kernel >=6.12.88, <6.12.91)
  # was here. Removed in 6.12.91+ since the fix is now upstream.
  # See: e3ac0d9f1a20 / 0df9f4581114

  # Enable Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        # Shows battery charge of connected devices on supported
        # Bluetooth adapters. Defaults to 'false'.
        Experimental = true;
        # When enabled other devices can connect faster to us, however
        # the tradeoff is increased power consumption. Defaults to
        # 'false'.
        FastConnectable = true;
      };
      Policy = {
        # Enable all controllers when they are found. This includes
        # adapters present on start as well as adapters that are plugged
        # in later on. Defaults to 'true'.
        AutoEnable = true;
      };
    };
  };

  # Blueman applet
  services.blueman.enable = true;

  # Bluetooth packages
  environment.systemPackages = with pkgs; [
    bluez
    bluez-tools
    bluetui
  ];
}
