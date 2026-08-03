# system/zram.nix
# ZRAM: compressed RAM swap
#
# Kept because it prevents OOM and doesn't cost significant performance.
# L4/L5 cache thrash avoidance may actually improve fps in memory-heavy games.
{...}: {
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };
}
