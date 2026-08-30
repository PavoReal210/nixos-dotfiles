# Hyprland Animations

Most of the time you just want to tweak a speed or try a different feel. Jump to [Quick recipes](#quick-recipes) below for copy-paste examples. The rest of this doc is the full reference for when you want to understand how it all works.

> **Note:** This config uses the **hyprlang syntax** (pre-0.55). See the [official wiki](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/) for the newer Lua syntax if you've upgraded.

---

## Quick recipes

Hyprland reloads config instantly on save — just edit `hyprland/hyprland.nix` and watch it apply live.

**Make everything snappier** (lower numbers = faster):
```nix
animation = [
  "windows, 1, 3, easeOutQuint"
  "workspaces, 1, 3, default, slide"
  "fade, 1, 3, default"
];
```

**Make everything smoother** (higher numbers = slower, more cinematic):
```nix
animation = [
  "windows, 1, 10, easeOutQuint"
  "workspaces, 1, 10, default, slide"
  "fade, 1, 8, default"
];
```

**Add a bouncy/overshoot feel to windows**:
```nix
bezier = "easeOutBack, 0.34, 1.56, 0.64, 1";
animation = [
  "windows, 1, 5, easeOutBack"
  "windowsOut, 1, 5, default, popin 80%"
];
```

**Disable window open/close animations only** (keep workspace slide):
```nix
animation = [
  "windows, 0"
  "workspaces, 1, 6, default, slide"
  "fade, 1, 5, default"
];
```

**Disable all animations**:
```nix
animations.enabled = false;
```

> **Battery warning:** Don't use `loop` style on `borderangle`, `shadowangle`, or `glowangle` — it forces Hyprland to render new frames at your monitor's refresh rate 24/7, even when nothing is moving. This kills battery life on laptops.

---

## How the animation system works

Every animation entry follows this format:

```
NAME, ENABLED, SPEED, CURVE[, STYLE]
```

| Field | Description |
|-------|-------------|
| `NAME` | Which UI element this controls (see [Animation tree](#animation-tree)) |
| `ENABLED` | `1` = on, `0` = off. If `0`, you can omit the rest |
| `SPEED` | Duration in **deciseconds**. `1 ds = 100 ms`, so `5` = 0.5s, `8` = 0.8s |
| `CURVE` | Name of a bezier curve you defined, or `default` |
| `STYLE` | Optional. Varies per animation type |

---

## This config's animations

```nix
animations = {
  enabled = true;
  bezier = "easeOutQuint, 0.23, 1, 0.32, 1";
  animation = [
    "windows, 1, 5, easeOutQuint"
    "windowsOut, 1, 5, default, popin 80%"
    "border, 1, 8, default"
    "borderangle, 1, 8, default"
    "fade, 1, 5, default"
    "workspaces, 1, 6, default, slide"
  ];
};
```

| Line | What it does |
|------|-------------|
| `windows, 1, 5, easeOutQuint` | Windows open/resize — 0.5s, custom curve |
| `windowsOut, 1, 5, default, popin 80%` | Windows close — shrinks to 80% while fading out |
| `border, 1, 8, default` | Border color changes (active/inactive) — 0.8s |
| `borderangle, 1, 8, default` | Gradient angle on borders — 0.8s |
| `fade, 1, 5, default` | Opacity fade in/out — 0.5s |
| `workspaces, 1, 6, default, slide` | Workspace switch — 0.6s, horizontal slide |

---

## Animation tree

Animations are hierarchical. If you only set `windows`, then `windowsIn`, `windowsOut`, and `windowsMove` all inherit from it. You only need to set children if you want them different from the parent.

```
global
  ↳ windows          styles: slide, popin, gnomed
    ↳ windowsIn      window open
    ↳ windowsOut     window close
    ↳ windowsMove    moving, dragging, resizing
  ↳ layers           styles: slide, popin, fade
    ↳ layersIn
    ↳ layersOut
  ↳ fade
    ↳ fadeIn
    ↳ fadeOut
    ↳ fadeSwitch      active window changes
    ↳ fadeShadow
    ↳ fadeGlow
    ↳ fadeDim         dimming inactive windows
    ↳ fadeLayers
    ↳ fadePopups
    ↳ fadeDpms        screen on/off via DPMS
  ↳ border
  ↳ borderangle       ⚠ avoid "loop" style — see battery warning above
  ↳ shadowangle       ⚠ same
  ↳ glowangle         ⚠ same
  ↳ workspaces        styles: slide, slidevert, fade, slidefade, slidefadevert
    ↳ workspacesIn
    ↳ workspacesOut
    ↳ specialWorkspace
```

---

## Available styles per animation

| Animation | Available Styles |
|-----------|-----------------|
| `windows`, `windowsIn`, `windowsOut`, `windowsMove` | `slide`, `popin`, `gnomed` |
| `layers`, `layersIn`, `layersOut` | `slide`, `popin`, `fade` |
| `borderangle`, `shadowangle`, `glowangle` | `once` (default), `loop` |
| `workspaces` and children | `slide`, `slidevert`, `fade`, `slidefade`, `slidefadevert` |

**Style extras:**
- `popin N%` — starting size. `popin 80%` = window scales from 80% → 100% while opening
- `slide N%` — movement percentage. `slide 20%` = windows move 20% of screen width
- `slide left/right/top/bottom` — forces a direction for windows and layers

---

## Bezier curves

A bezier curve controls the *rate* of change — does the animation start fast and slow down, ease both ways, overshoot and settle? The curve name you define with `bezier =` is what you reference in animation entries.

```
bezier = NAME, X0, Y0, X1, Y1
```

Two control points `(X0, Y0)` and `(X1, Y1)` shape the curve between fixed start `(0,0)` and end `(1,1)`.

```
bezier = easeOutQuint, 0.23, 1, 0.32, 1
                          ↑   ↑   ↑   ↑
                          X0  Y0  X1  Y1
```

For `easeOutQuint`: the first point `(0.23, 1)` pulls the curve up fast (quick start), and the second point `(0.32, 1)` keeps it near the top (slow, smooth finish).

### Common patterns

| Pattern | Feel | Example |
|---------|------|---------|
| Ease-out | Fast start, slow end | `easeOutQuint: 0.23, 1, 0.32, 1` |
| Ease-in | Slow start, fast end | `easeInQuint: 0.755, 0.05, 0.855, 0.06` |
| Ease-in-out | Slow start and end | `easeInOutExpo: 0.87, 0, 0.13, 1` |
| Overshoot | Goes past, snaps back | `easeOutBack: 0.34, 1.56, 0.64, 1` |

### Finding curves visually

[easings.net](https://easings.net) shows a visual catalog. Click any curve, copy the `cubic-bezier(...)` values — those four numbers are what go into Hyprland:

- easeInOutExpo = `cubic-bezier(0.87, 0, 0.13, 1)` → use `0.87, 0, 0.13, 1` in Hyprland

To design your own curve visually: [cssportal.com/css-cubic-bezier-generator](https://www.cssportal.com/css-cubic-bezier-generator/)

### Using multiple curves

Once you have more than one curve, `bezier` becomes a list:

```nix
bezier = [
  "easeOutQuint, 0.23, 1, 0.32, 1"
  "easeInOutExpo, 0.87, 0, 0.13, 1"
];
animation = [
  "windows, 1, 5, easeOutQuint"
  "workspaces, 1, 6, easeInOutExpo, slide"
];
```

---

## Spring curves

Spring curves simulate physical spring physics (like Apple's animations). Defined by mass, stiffness, and damping — available in Hyprland 0.55+ with the Lua syntax:

```lua
hl.curve("rubber", { type = "spring", mass = 1, stiffness = 70, dampening = 10 })
```

| Parameter | Effect |
|-----------|--------|
| `mass` | Keep at 1. Higher = slower, heavier feel |
| `stiffness` | Higher = faster animation |
| `dampening` | Higher = less bounce |

---

## Runtime control

Check or toggle animations without editing config:

```bash
# See current animation and bezier info
hyprctl animations

# Toggle all animations on/off
hyprctl toggleanimation
```

---

## Syntax: old (this config) vs new

This config uses the pre-0.55 hyprlang syntax. If you upgrade Hyprland past 0.55, here's the equivalent in the new Lua format:

**Old (this config):**
```nix
animations = {
  bezier = "easeOutQuint, 0.23, 1, 0.32, 1";
  animation = [
    "windows, 1, 5, easeOutQuint"
    "workspaces, 1, 6, default, slide"
  ];
};
```

**New (Hyprland 0.55+):**
```lua
hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1}, {0.32, 1} } })
hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "easeOutQuint" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, curve = "default", style = "slide" })
```

---

## Sources

- [Hyprland Wiki — Animations](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/)
- [Hyprland Wiki — hyprctl](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Using-hyprctl/)
- [easings.net](https://easings.net)
- [cssportal.com Bezier Generator](https://www.cssportal.com/css-cubic-bezier-generator/)
