# M3 / LHY protocol notes (clean-room)

Clean-room record of protocol knowledge for the Lihuiyu M3 (LHY) controller
family used by this fork's planned laser output feature. This follows
`CLEANROOM.md` and the project constraints in `AGENTS.md`: no decompiled code or
dumps, no code ported from other implementations, and only files/material the
contributors own or are allowed to use.

Status: **preliminary, hardware-observed facts only**. Every claim must be
verified against our own hardware before it is relied on for implementation.

## Sources

| Date | What | Source |
|---|---|---|
| 2026-04-11 | Board identity, USB IDs, idle/busy responses, observed command bytes, speed/power prefix shape, step size; recorded as reference facts for this fork. | Direct observation on our own Lihuiyu M3 board (VID:PID `1a86:5512`, CH341; S/N `M3 S400 600 A B 1.0 000.000`) during local testing. The raw captures and vendor material stay outside the repository. |
| 2026-04-11 | Cross-check of general command/packet family concepts for Lihymicro-GL / M2-Nano compatible controllers. | Public protocol descriptions of the Lihymicro-GL / M2-Nano controller family (documentation/notes), read for confirmation only; no code read or copied. |
| 2026-04-11 | Behaviour/layout spot-checks (not committed). | Independent implementations consulted for behaviour comparison only: K40 Whisperer 0.71 source (GPL-2+, **no code copied**) at `~/Downloads/Compressed/K40_Whisperer-0.71_src`; Meerk40t `meerk40t/lihuiyu/*` (MIT, local venv at `/tmp/mk40uv`) for protocol description cross-check. |

## Verified facts (our hardware)

- Board: Lihuiyu M3, VID:PID `1a86:5512` (CH341 bridge).
- Serial/identity string observed: `M3 S400 600 A B 1.0 000.000`.
- Nominal bed: 400×600 mm (configurable in software); resolution assumed 1000 dpi
  for tick mapping unless re-verified.
- Tick/step: 1000 ppi ≈ 0.0254 mm/step (pixel/step).
- Device responses observed: `I` (idle), `B`/`P` (busy).
- Commands observed in captures: `IS1P` followed by 8 control/flag bytes (device
  ACK `I`), `IPP` (end-of-job marker observed in sequence).
- Speed vector prefix observed: `V<speed><power>` where 1 speed byte corresponds
  to 25.4 mm/s (to be confirmed per mode/encoding before implementation).

## Assumptions / to verify

- Exact encoding of the 8 control/flag bytes after `IS1P` (direction, mode,
  units) — **assumed from captures, must be re-derived/verified on hardware**.
- Distance/vector packet format, raster scanline packet format, CRC/checks, and
  job framing details — **not yet fully recorded**; derive from our own
  captures/tests and public family descriptions, then verify on hardware.
- Power scaling/range mapping for engrave vs cut and any PPI modulation —
  **to verify**.
- Bounds/origin semantics for top-left origin and page offsets — **to verify**
  end-to-end (ROADMAP Phase 5).

## Rules for future entries

- Add date, finding, and source for every new fact.
- Mark each item as `confirmed (hardware)` or `assumed` until verified.
- Never include decompiled output, vendor binaries, or copied third-party code.
- Keep local-only reference material (screenshots, captures, vendor installers)
  outside the repository.