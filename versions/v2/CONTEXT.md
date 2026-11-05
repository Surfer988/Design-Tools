# Halftone Dither — v2 context

> Self-contained brief for an AI assistant or collaborator. Paste this whole file
> into a new chat together with (or instead of) `versions/v2/halftone.html`.

| | |
|---|---|
| **Version** | v2 (current) · 2026-11-05 |
| **File** | `versions/v2/halftone.html`, a single file with no build step and no dependencies (~4,770 lines of HTML + CSS + vanilla JS) |
| **Built from** | The v1 Pattern mode merged into the later "index.html" line (colour picker, multiple text blocks, raster masks) |
| **Run** | Open the file in Chrome/Safari, or serve the repo root (`python3 -m http.server 7823`) and open `/versions/v2/halftone.html` |

## 1. What the tool is

A browser design tool for making **halftone / ASCII-dither graphics** and
**text-filled shapes**, as stills or animations. Everything runs client-side on
`<canvas>`. The top **mode banner** switches between two output modes:

### A. ASCII Dithering (`setOutputMode('video')`, button `#omBtn-video`)
Image, GIF or video in → a dithered grid of characters, blocks or SVG stamps out.

Sidebar sections, top to bottom (the user can drag to reorder them, and the order is saved):
- **Image**: Scale, Brightness, Contrast, Blur, Noise, Invert.
- **Levels**: Black pt / White pt.
- **Dithering**: Bayer 8×8 (ordered) or Floyd–Steinberg (error diffusion).
- **Text mode** (`renderMode`):
  - `phrase` (Phrase tiling): repeats a phrase across the ink cells.
  - `density` (Density set): picks a char from a light→dark ramp, with presets.
  - `pattern` (Pattern): an uploaded **SVG becomes the glyph**. It is tinted per band, and each band gets its own size % slider.
- **Cell**: Size (px of source per cell), Output scale %, Margin %, font family/weight, plus custom font upload (saved in `localStorage` as `halftone_custom_fonts_v2`).
- **Tonal bands**: 4/6/8/12 bands, from band 0 = paper to N-1 = darkest ink. Each band has colour, opacity and margin, and bands 1 and up also have *as* Text/Block/Both, a background fill, and a pattern size. There is a palette grid and an auto-palette option.
- **Animation**: `typing` (cells revealed in order seq/rnd/lr/rl/tb/bt, optional decode scramble), `flicker` (random cells blink between slow and fast Hz), and `media` (plays GIF/video frames through the dither live).
- **Export**: PNG, PNG sequence (ZIP built in the browser, no library), SVG (vector rects + `<text>`; Pattern mode embeds one tinted `<symbol>` per band and `<use>`s it per cell), TXT, and WebM recording.

### B. SVG Fill / Text Fill (`setOutputMode('svgfill')`, button `#omBtn-svgfill`)
Drop in an **SVG, or a raster image that gets thresholded to a mask**, and its
interior is tessellated into rows of character cells, which are then filled
with styled text.
- **Text blocks**: one or more rich-text editors (`addSVGFillBlock`). Selecting text opens a floating toolbar (weight, colour, background, styles). The **fill order** of the blocks is *Sequence* or *Random* (`setFillOrder`).
- **Mask threshold**: shown only for raster images (`buildMaskFromPixels`).
- **Layout**: Line gap, Grid margin, SVG size, Output scale.
- **Colors**: font and background, both using the custom HSV + alpha colour picker (`openCP`).
- **Animation**:
  - `typing`: order, reveal unit per char or per block, speed, char stagger, decode, a **Text fx** registry and Fx duration.
  - `flicker`: density, slow/fast Hz, cycle, and a flicker unit of char or block.
  - Loop and record options.
- **Export**: PNG, SVG, PNG sequence, WebM recording.

## 2. Architecture

Everything lives in one `<script>` with global functions and state, and controls
use inline `onclick` / `oninput` handlers. `$ = id => document.getElementById(id)`.
`debouncedRender()` is the standard "a setting changed" call in dither mode, and
`renderSVGFill()` plays the same role in SVG Fill mode.

### Code map (line numbers are approximate)

| Line | Section / symbol | Role |
|---|---|---|
| 1101 | Constants: `MAX_DIM`, `PALETTES`, `DENSITY_PRESETS` | |
| 1131 | State: `renderMode`, `algo`, `outputMode`, band arrays, `patternSVG`, `anim`, `media`, `svgFill` | Global state |
| 1222 | `getSettings()` | Takes a snapshot of every dither control into one object `s` |
| 1305 | `setOutputMode(m)` | Switches between `'video'` (dither) and `'svgfill'` |
| 1322 | `initBands` / `setBandCount` / `buildBandUI` / `setBandMode` | Tonal band arrays and their UI |
| 1351 | **Pattern unit**: `loadPatternSVGFile`, `buildPatternMips`, `getPatternMip`, `getTintedPattern`, `stepDownCanvas`, `tintedPatternPNGDataURI` | Rasterizes the SVG as a mip chain (4–256 px) and caches a tinted copy per band |
| 1622 | `setMode` / `setAlgo` | Text mode and dither algorithm toggles |
| 1660 | `loadFile` → `loadImage(file, onLoaded)` / `loadLiveSource` | Input routing. GIF/video → frame extraction. A raster dropped in SVG Fill mode → mask |
| 1885 | `getSourcePixels(blur, scale)` | Downscaled, blurred source pixels |
| 1902 | `drawGlyph(ctx, s, x, y, inner, ds, band, bc, bm, ch)` | **Shared per-cell drawer**: block fill, then a char *or* a pattern stamp |
| 1921 | `render()` | Dither pipeline (see below) |
| 2122–2610 | `animFrame`, `initFlicker`/`flickerFrame`, media playback, `startAnimation`/`stopAnim` | Dither animations |
| 2612–2800 | `exportPNG`, `buildZip`/`exportPNGFrames`, `exportSVG`, `exportTXT` | Dither exports |
| 2906 | Custom fonts | Parses weight from file names; stored in `localStorage` |
| 3100 | SVG Fill: `initSVGFill`, block editors, `getAllBlockChars`, `extractStyledChars` | Text model: a flat list of `{char, style}` |
| 3336 | **Custom colour picker**: `openCP(target, anchorEl)`, `_initColorPicker`, `_cpApply` | One popup (`#cp-popup`) shared by every colour control |
| 3705 | `loadSVGFillFile`, `buildSVGMask`, `buildMaskFromPixels`, `svgFillInside` | Shape → boolean mask |
| 3868 | `svgFillComputeLayout` | Tessellates the mask interior into per-row character cells |
| 3909 | `renderSVGFill`, `exportSVGFillPNG`, `exportSVGFillSVG` | Static SVG Fill output |
| 4009 | `SVGFILL_TEXT_EFFECTS` | Registry of per-char reveal effects |
| 4036 | `svgFillAnim` | Animation state |
| 4205 | `svgFillDrawCellWithEffect` | Draws one cell at time `t` |
| 4241 | `svgFillAnimFrame` | rAF loop for typing |
| 4345 | `svgFillInitFlicker`, `_svgFillSyncFlickerBase`, `svgFillFlickerFrame` | Flicker mode |
| 4521 | `startSVGFillAnimation` / `stopSVGFillAnim` / `exportSVGFillPNGSeq` | |
| end | Version switcher script | Reads `../manifest.json`, fills the `v:` dropdown in the top bar |

### Dither pipeline, `render()`
1. Luminance per cell (Rec.601) → levels (black/white pt) → brightness → contrast → invert.
2. Optional noise.
3. Dither → `bandGrid` (0 = paper … N-1 = ink) using Bayer8 or Floyd–Steinberg.
4. `charGrid`: phrase tiling, density ramp, or a placeholder `'#'` for pattern mode.
5. Draw: fill the canvas with the band-0 colour; for each cell with band > 0, apply the band margin and optional background, then call `drawGlyph`.

`animDrawRange`, `animDrawDecoding` and `drawFlickerFull` all call
`drawGlyph`, so a new glyph type only needs adding in one place, plus
`exportSVG`.

### SVG Fill text-effect signature
```js
SVGFILL_TEXT_EFFECTS[name] = (t, meta) => ({ tx, ty, sx, sy, rot, opacity, color, char, clipToCell })
// t    — 0..1 progress within effectMs since the cell was first revealed
// meta — { ch, fontSize, color, opacity, w, rowH }
```
Registered effects: `None`, `Fade in`, `Slide up`, `SplitText` (chars rise by
`max(40, rowH*1.2)` and fade with easeOutCubic), and `SplitText_mask` (the
same rise, fully opaque, with `clipToCell: true`).

`svgFillDrawCellWithEffect` works inside a single `save()`/`restore()`. It
optionally clips to the cell rect in unscaled coordinates, translates to the
cell centre plus `(tx, ty)`, rotates, scales, and then calls
`drawStyledCell`. **Fast path:** when `t >= 1` or no effect is selected, the
cell is drawn directly. Settled cells are committed to an offscreen
`baseCanvas` and blitted each frame.

### `svgFillAnim` key fields
`mode` ('typing'|'flicker') · `order` (seq/rnd/lr/rl/tb/bt) · `revealUnit`
('char'|'block') + `stepSize`/`phraseLen` · `speed` · `effectName`/`effectMs`
· `entryStart` (Map cellIdx → ts) · `decodeEnabled`/`decodeMs` ·
`flickerUnit` · `flicker {cellOn, cellTimers, cellRates, reseedTimer}` ·
`baseCanvas`/`baseCtx` · `recorder`/`chunks`.

## 3. How to extend

- **New SVG Fill text effect**: add an entry to `SVGFILL_TEXT_EFFECTS`. The dropdown fills itself from `Object.keys`. Scale distances with `meta.rowH` / `meta.w`. The `t = 1` state must look exactly like a plain draw, or the fast path will visibly pop.
- **New dither glyph mode**: add a toggle button and a `*-ctrl` block in the Text mode section, add a branch in `setMode`, set the `charGrid` in `render()` step 4, draw it in `drawGlyph`, and add an SVG branch in `exportSVG`.
- **New per-band setting**: follow the `bandPatternSizes` pattern. That means a global array, `initBands`, `setBandCount` (keeping old values), a row in `buildBandUI`, and a field in `getSettings`.
- **Colour controls**: use `openCP(targetInput, anchorEl)` instead of a native `<input type=color>`, so colour and alpha stay consistent.

## 4. Known issues and follow-ups
- **`SplitText_mask` with oversized fonts**: when glyphs are taller than `rowH`, frames with `t < 1` clip the overflow, but the `t >= 1` fast path does not, so the last frame pops. Fix: add an `alwaysClip` flag to the registry entry and honour it on the fast path.
- `getSettings().grain` is hard-coded to `false`, so the grain step in `render()` is dead code.
- Pattern mode in the SVG export embeds a base64 PNG per band rather than true vector paths. `tintedPatternSVGDataURI` exists but is not used, because many SVG consumers ignore nested-SVG `fill` overrides.

## 5. Verification checklist
1. Open the file. The console should show no errors, and the top bar should read `v: v2`.
2. **Dither**: drop in an image and cycle Phrase / Density / Pattern. For Pattern, upload a simple SVG such as a circle; dots should scale per band. Try Bayer and Floyd. Export PNG and SVG; the Pattern SVG should contain `<symbol>` plus `<use>`.
3. **Colour picker**: click a colour swatch; the HSV + alpha popup should apply live.
4. **SVG Fill**: drop in an SVG, add a second text block, and switch between Sequence and Random fill order. Preview with Text fx `SplitText` at ~1500 ms, then try Per block reveal and Flicker.
5. **Raster mask**: in SVG Fill mode, drop a PNG; the Mask threshold section should appear.

## 6. Changes from v1
- Added: custom colour picker, multiple text blocks with fill order, raster-image masks with threshold, flicker unit (char/block), and a separate flicker base-canvas sync.
- Kept from v1: Pattern mode, `xmlns:xlink` in the SVG export, and stopping a running animation when a new image or live source loads.
- The version switcher now reads `versions/manifest.json`.
