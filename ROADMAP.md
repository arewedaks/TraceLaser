# TraceLaser Roadmap

Fork of [tracedraw/tracedraw](https://github.com/tracedraw/tracedraw) (MIT OR Apache-2.0)
focused on **direct laser output** for Lihuiyu M3 / CH341 controller boards, with an
Engrave/Cut workflow that matches the placement semantics users expect (page-accurate,
origin-aware).

- **Repo:** https://github.com/arewedaks/TraceLaser (public)
- **Local:** `/home/arewedaks/orca/TraceLaser` (ext4)
- **Upstream:** `upstream` → `https://github.com/tracedraw/tracedraw.git`
- **Origin:** `origin` → `https://github.com/arewedaks/TraceLaser.git`

---

## Constraints (non-negotiable)

- **Licensing:** keep `LICENSE-MIT`, `LICENSE-APACHE`, `ATTRIBUTION.md`. All new code must
  be compatible (MIT/Apache-2.0). **No GPL code** copied in (e.g. do not copy K40
  Whisperer / `nano_library.py`). Implement protocol logic from clean-room understanding
  and hardware-verified behavior.
- **Clean-room:** do not include decompiled code or dumps. Protocol facts are recorded
  from our own hardware tests and public protocol descriptions (e.g. Lihymicro-GL / M2-Nano
  family docs) with sources noted.
- **Naming:** use neutral, original names in code/docs/commits (e.g. "Laser Output",
  "M3/LHY driver", "Engrave/Cut", "Page/Selection"). Do not present this as a clone of
  any other product.
- **Architecture (TraceDraw rules):** user-visible behavior as `tracedraw_core::Command`
  via `Engine::run`; UI builds commands/reads document, no direct mutation. Driver kept in
  its own crate/layer; `tracecut` depends only on `core` (respect layering).
- **No panics on input:** return `Result`, warn/skip on bad data.

---

## Phase 0 — Foundation ✅

- [x] Fork upstream tracedraw → **TraceLaser** (public)
- [x] Remotes: `origin` (TraceLaser), `upstream` (tracedraw)
- [x] Workspace placed alongside M3 materials, then moved to local ext4: `/home/arewedaks/orca/TraceLaser`
- [x] exFAT copy removed (avoids permission-bit/hardlink issues); ext4 clone is clean (`core.fileMode true`, executable bits preserved)

**Build note:** workspace is on local ext4, so default `cargo` target dir inside the repo is fine (no `CARGO_TARGET_DIR` override needed).

---

## Phase 1 — Repo hygiene

- [ ] Add fork notice to README (independent fork of TraceDraw, same license) + keep upstream
      attribution and trademark notice intact
- [ ] Record M3 protocol knowledge + sources in a clean-room note (no decompiled material)
- [ ] Decide: rename internal crates/binary/branding `tracedraw` → `tracelaser` **now** vs
      **after feature** (tradeoff: clean branding early vs easier upstream merges now)

---

## Phase 2 — M3 / LHY device crate (new)

Goal: a small, isolated crate (e.g. `crates/m3` or `crates/laser-m3`) that can stream a
job to an M3 board over USB (CH341), with no UI dependency.

- [ ] USB transport (CH341/libusb or equivalent) — detect device, open/claim, bulk/ctrl I/O
- [ ] Protocol primitives (hardware-verified): init/reset, speed/power encoding, direction
      flags, distance packets, CRC/checks, job framing
- [ ] Vector path streaming: polyline/segments in machine ticks (1 tick = 0.0254 mm @ 1000 dpi)
- [ ] Raster streaming: row-by-row bitmap engraving (scanline packets), power modulation
- [ ] Machine profile: bed 400×600 mm (configurable), origin **top-left**, resolution 1000 dpi
- [ ] Dry-run / byte-dump mode for testing without hardware
- [ ] Error handling: device not found, disconnect mid-job, bounds checks (never panic)

**Reference facts (verified on our board):**
- Board: Lihuiyu M3, VID:PID `1a86:5512` (CH341), S/N `M3 S400 600 A B 1.0 000.000`
- Responses: `I` (idle), `B`/`P` (busy)
- Commands observed: `IS1P` + 8 control/flag bytes (ACK `I`), `IPP` (end)
- Speed vector prefix `V<speed><power>`, 1 byte = 25.4 mm/s
- 1000 ppi ≈ 0.0254 mm/step (pixel/step)

---

## Phase 3 — Laser Output UI (TraceDraw app)

Goal: user-facing Engrave/Cut controls mirroring placement semantics (not pixel-identical UI).

- [ ] Machine profile settings: bed size (default 400×600), origin (top-left default),
      page origin X/Y offset, resolution (1000 dpi)
- [ ] Job parameters: **Speed**, **Power** (separate profiles for engrave vs cut)
- [ ] Two actions: **Engrave** and **Cut**
- [ ] Target mode (mode C — both): **Page** (whole page as coordinate field, object
      positions preserved, origin at top-left of page/machine) and **Selection** (bbox of
      selection)
- [ ] Placement semantics: map document mm → machine mm respecting origin + page offset;
      clamp/report out-of-bounds
- [ ] Destination: send to **M3 (USB)** (and keep existing file/export paths where useful)
- [ ] Progress / cancel / status feedback (device state, bytes/rows sent)

Placement targets (behavioral parity):
- Origin: top-left
- Page origin X / Y offsets
- Page/work area: 600×400 (configurable)
- 1 step = 1/1000 in = 0.0254 mm

---

## Phase 4 — Pipelines

### 4a. Vector Cut
- [ ] Reuse TraceCut geometry (`tracedraw_tracecut::cut::hpgl` knife path, layout, order)
- [ ] Convert plotted/layout paths → M3 vector packets (mm → ticks, origin transform)
- [ ] Honor cut order / inner-first / optimize where applicable

### 4b. Raster Engrave
- [ ] Rasterize page or selection to bitmap at device resolution (1000 dpi grid, stepped)
- [ ] Map raster rows to M3 scanline packets (direction, power on/off per pixel/run)
- [ ] Support "engrave data" from vector fills/strokes rendered to bitmap (WYSIWYG) and/or
      image nodes if present

---

## Phase 5 — Integration & hardware validation

- [ ] End-to-end: Page + Selection, Engrave + Cut on real M3 (400×600)
- [ ] Verify: origin/placement, scale (mm accuracy), speed/power effect, bounds handling
- [ ] Regression: existing TraceCut/plotter features still work
- [ ] Document supported workflow and known limits

---

## Open decisions

- [ ] **Rename timing:** internal `tracedraw` → `tracelaser` now or after feature lands?
- [ ] **USB stack:** `rusb`/`libusb`, `nusb`, or CH341-specific crate — pick based on portability
      and maintenance (must work on Linux; Windows/macOS nice-to-have)
- [ ] **Raster source:** render-to-bitmap via existing render path vs a dedicated engrave
      rasterizer (needs investigation of `crates/render` capabilities)

---

## Progress log

| Date | Note |
|---|---|
| 2026-04-11 | Forked, created repo, added ROADMAP.md |
| 2026-04-11 | Moved workspace to `/home/arewedaks/orca/TraceLaser` (ext4), deleted exFAT copy, roadmap updated |
