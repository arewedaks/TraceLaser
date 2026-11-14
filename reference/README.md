# Reference material

Layout and behaviour study for TraceLaser's laser output UI and device protocol.

**These files are reference only.** No code may be copied from them, no decompiled
material may be used, and nothing from a third-party installer may be committed.

| File | What it shows |
|---|---|
| `laser-plugin-data-settings.png` | Data/area settings: engraving data format, engraving area, cutting data format, cutting area, optimize options, out-of-bounds, pixel size + step unit, "always display" |
| `laser-plugin-machine-properties.jpg` | Machine properties: board model, resolver/speed, resolution (dpi), max speed (mm/s), **origin position**, axis travel X/Y, page origin X/Y, page size X/Y, verify field |

Used by: `ROADMAP.md` → Phase 3 → Design target.

Notes:
- The machine in these screenshots is the same class of board we target (400x600 bed,
  top-left origin, 1000 dpi).
- The verify-code field is informational for us: our build does not enforce licensing.
- Before any public release, replace these with our own mockups or remove the folder.
