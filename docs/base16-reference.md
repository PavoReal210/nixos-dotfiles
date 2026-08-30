# Base16 Color Palette Reference

## What this is for

When Stylix generates a color scheme from your wallpaper, it maps every color to one of 16 named slots. You reference these slot names when you need a specific color in a custom config — a manual theme override, a bar widget script, or anything that isn't automatically themed by Stylix.

See the [Theme System section in the README](../README.md#theming-stylix) for how Stylix generates the palette and applies it.

---

## The 16 slots

Base16 splits into two groups: **base00–base07** are background and foreground shades (dark to light for dark themes), and **base08–base0F** are accent colors for syntax highlighting and UI accents.

| Slot   | Typical Color  | Intended Use |
|--------|----------------|--------------|
| base00 | Dark           | Default background |
| base01 | Slightly lighter | Status bars, line numbers, folding marks |
| base02 | Lighter still  | Selection background |
| base03 | Mid-dark       | Comments, invisible characters, line highlighting |
| base04 | Mid            | Dark foreground — used for status bars |
| base05 | Light          | Default foreground, caret, delimiters, operators |
| base06 | Lighter        | Light foreground (rarely used) |
| base07 | Lightest       | Light background (rarely used) |
| base08 | Red            | Variables, XML tags, markup link text, diff deleted |
| base09 | Orange         | Integers, booleans, constants, XML attributes, link URLs |
| base0A | Yellow         | Classes, markup bold, search highlight background |
| base0B | Green          | Strings, inherited class, markup code, diff inserted |
| base0C | Cyan           | Support, regular expressions, escape characters, markup quotes |
| base0D | Blue           | Functions, methods, attribute IDs, headings |
| base0E | Magenta        | Keywords, storage, selector, markup italic, diff changed |
| base0F | Brown/Dark Red | Deprecated, opening/closing embedded language tags |

For a dark theme: base00 is darkest, base07 is lightest. For a light theme, they flip.

---

## How to use a slot in practice

### In a Nix config (via Stylix config object)

Stylix exposes the current palette through `config.lib.stylix.colors`:

```nix
# Example: use the base0D (blue) accent in a custom waybar color
{ config, ... }: {
  programs.waybar.settings.mainBar."custom/thing".format-style =
    "color: #${config.lib.stylix.colors.base0D};";
}
```

### In a shell script

Stylix writes the palette to `~/.cache/stylix/colors.sh` (sourced by some tools automatically). You can also read it in a script:

```bash
# Get the current base0D color (blue accent)
source ~/.cache/stylix/colors.sh
echo "Blue accent: #$base0D"
```

### Previewing the current palette

```bash
base16-shell-preview
```

This is installed from `common-packages.nix` and shows all 16 colors rendered in your terminal with their slot names.

---

## Sources

- [Base16 Styling Guidelines](https://github.com/chriskempson/base16/blob/main/styling.md) — original spec
- [tinted-theming/base16-schemes](https://github.com/tinted-theming/base16-schemes) — maintained scheme collection
- [Base16 Colorscheme Previews](https://tinted-theming.github.io/tinted-gallery/) — visual gallery
