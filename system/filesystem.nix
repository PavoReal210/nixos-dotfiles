# system/filesystem.nix
# Filesystem performance (BTRFS mount options)
{
  lib,
  ...
}:
{
  # ── Filesystem performance ───────────────────────────────────────────────────
  #
  # BTRFS optimizations for SSD + desktop workload:
  #   compress=zstd — reduces disk I/O by compressing data in RAM before writing;
  #                   zstd offers the best ratio/speed tradeoff and is built into
  #                   the kernel. Reads are decompressed on the fly, which is fast
  #                   on modern CPUs and effectively increases SSD read throughput.
  #   noatime       — skips writing access-time metadata on every file read,
  #                   eliminating a huge source of small random writes.
  #   ssd           — tells BTRFS the device is an SSD, enabling TRIM/discard
  #                   and disabling page-cache alignment hacks meant for HDDs.
  #   discard=async — queues TRIM commands asynchronously so they don't block
  #                   the submitting thread; the kernel batches them via kworker.
  fileSystems."/".options = lib.mkAfter [
    "compress=zstd"
    "noatime"
    "ssd"
    "discard=async"
  ];
  fileSystems."/home".options = lib.mkAfter [
    "compress=zstd"
    "noatime"
    "ssd"
    "discard=async"
  ];
}
