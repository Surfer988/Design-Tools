# Halftone Dither — Project Notes

Single-file browser app at `index.html` (~3960 lines). No build step; open the
file directly. Versioned snapshots live under `versions/` and are indexed by
`versions/manifest.json` (current: `V1`, 2026-05-19).

## What it does

Two output modes, switched by the top mode banner:

1. **ASCII Dithering** (`omBtn-video`) — image/video → halftone/ASCII dither render.
2. **SVG Fill** (`omBtn-svgfill`) — drop an SVG; its interior is "typed in"
   with characters that fill the shape, with optional per-char animation.

## SVG Fill pipeline (key area of recent work)

Core functions (line numbers approximate):

| Line  | Symbol                          | Role                                                  |
|-------|---------------------------------|-------------------------------------------------------|
| 3107  | `svgFillInside`                 | Point-in-shape test                                   |
| 3132  | `svgFillComputeLayout`          | Tessellates SVG interior into per-row character cells |
| 3272  | `SVGFILL_TEXT_EFFECTS`          | Registry of per-char reveal effects                   |
| 3320  | `populateSVGFillTextEffects`    | Populates the Text fx dropdown from the registry      |
| 3461  | `svgFillDrawCellWithEffect`     | Draws one cell at time `t` honoring effect transforms |
| 3497  | `svgFillAnimFrame`              | rAF loop driving the typing animation                 |
| 3601  | `svgFillInitFlicker` / `…Frame` | Alternate flicker mode                                |

### Effect signature

```js
(t, meta) => { tx?, ty?, sx?, sy?, rot?, opacity?, color?, char?, clipToCell? }
//  t    — 0..1, elapsed within effectMs since the cell was first revealed
//  meta — { ch, fontSize, color, opacity, w, rowH }
```

The draw function applies, in order, inside one `ctx.save()/restore()`:

1. Optional **clip to cell rect** (when `clipToCell: true`) — set in unscaled
   coordinates, so subsequent transforms move the drawing inside a fixed
   window (CSS `overflow: hidden` equivalent).
2. Translate to cell center + `(tx, ty)`, rotate, scale.
3. `drawStyledCell` with color/opacity/char overrides applied.

Fast path: if `t >= 1` or no effect is selected, the cell is drawn directly
with no transform — used for the settled state and the offscreen base canvas.

### Registered effects

- `None`
- `Fade in`
- `Slide up`
- `SplitText` — reactbits-style: chars slide up `max(40, rowH*1.2)` and fade
  in via `easeOutCubic`.
- `SplitText_mask` — same slide, fully opaque, with `clipToCell: true` so the
  bottom of each char is masked at the cell baseline until it rises into view.

## Animation state (`svgFillAnim`)

| Field                   | Meaning                                              |
|-------------------------|------------------------------------------------------|
| `mode`                  | `'typing'` or `'flicker'`                            |
| `order`                 | reveal order: `seq`/`rnd`/`lr`/`rl`/`tb`/`bt`        |
| `revealUnit`, `stepSize`| reveal one char vs. one whole phrase per tick        |
| `speed`                 | tick speed (cells/sec)                               |
| `effectName`, `effectMs`| selected entry in registry + per-char duration       |
| `entryStart`            | `Map<cellIdx, ts>` of first-reveal time per cell     |
| `decodeEnabled`/`Ms`    | "decoding" character scramble before settling        |
| `baseCanvas`/`baseCtx`  | offscreen canvas holding the settled frame           |
| `recorder`/`chunks`     | MediaRecorder bits for loop/flicker capture          |

## Known edge cases / follow-ups

- **Oversized fonts + `SplitText_mask`**: when char ascenders/descenders
  exceed `rowH`, the `t<1` frames clip the overflow but the fast path at
  `t>=1` does not, producing a one-frame "pop" at settle. Fix would be to
  thread a per-effect `alwaysClip: true` flag through the registry and
  honor it on the fast path as well.

## Adding a new text effect

1. Add an entry to `SVGFILL_TEXT_EFFECTS` (around line 3272). The dropdown
   auto-populates from `Object.keys(...)` — no UI wiring needed.
2. Return any subset of `{tx, ty, sx, sy, rot, opacity, color, char,
   clipToCell}`. Use `meta.rowH` / `meta.w` to scale slide distances so the
   effect adapts to layout.
3. Keep the t≥1 settled state visually identical to a non-animated draw, or
   the fast path will pop. If you need a permanent transform, drop the fast
   path bail-out for that effect.

## Verification recipe (for SVG Fill changes)

1. Open `index.html` in a browser.
2. Click **SVG Fill** tab, drop a simple SVG (stroked rect works).
3. Type a phrase, set Size ≥ 40, pick Text fx, Fx dur ~1500 ms, hit Preview.
4. A/B effects against `None` to confirm the settled frame matches.
5. Switch reveal unit to **Per block**, stagger ~80 ms, confirm the cascade
   composes with the chosen effect.
