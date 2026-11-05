# Halftone Dither — v1 context

> Self-contained brief for an AI assistant or collaborator. Paste this whole file
> into a new chat together with (or instead of) `versions/v1/halftone.html`.
> **v1 is archived.** New work goes in the latest version (see `/AGENTS.md`).

| | |
|---|---|
| **Version** | v1 · 2026-05-19 (the original stable snapshot) |
| **File** | `versions/v1/halftone.html`, a single file with no build step and no dependencies (~4,200 lines of HTML + CSS + vanilla JS) |
| **Run** | Open the file in a browser, or serve the repo root and open `/versions/v1/halftone.html` |
| **Edited since snapshot** | Only the version-switcher script, so that it reads `../manifest.json` in the new folder layout |

## 1. What the tool is

A browser design tool for making **halftone / ASCII-dither graphics** and
**text-filled shapes**, as stills or animations, all on `<canvas>`. A top
mode banner switches between two outputs:

### A. ASCII Dithering (`setOutputMode('video')`)
Image, GIF or video → a dithered character / block / SVG-stamp grid.
- **Image**: Scale, Brightness, Contrast, Blur, Noise, Invert. **Levels**: Black/White pt.
- **Dithering**: Bayer 8×8 or Floyd–Steinberg.
- **Text mode**:
  - `phrase` tiles a phrase across the ink cells.
  - `density` uses a light→dark char ramp, with presets.
  - `pattern` uses an uploaded SVG as the glyph, tinted per band, with a per-band size %.
- **Cell**: size, output scale, margin, font and weight, with custom font upload (`localStorage`).
- **Tonal bands**: 4/6/8/12 bands. Each has colour, opacity and margin, and bands 1 and up also have Text/Block/Both, a background fill and a pattern size. There is a palette grid and an auto palette.
- **Animation**: typing (seq/rnd/lr/rl/tb/bt plus decode scramble), flicker, and media playback for GIF/video.
- **Export**: PNG, PNG sequence (ZIP), SVG (Pattern mode embeds a `<symbol>` per band), TXT, WebM.

### B. SVG Fill (`setOutputMode('svgfill')`)
Drop in an **SVG** and its interior fills with rows of styled characters from
**one** rich-text editor (`#svgfill-editor`), which has a floating style toolbar.
- Layout: line gap, grid margin, SVG size, output.
- Colours: native colour inputs.
- Animation:
  - typing: order, per-char or per-block reveal, speed, decode, Text fx and duration.
  - flicker: density, slow/fast Hz, cycle.
- Export: PNG, SVG, PNG sequence, WebM.

## 2. Architecture

One global `<script>`, inline event handlers, and `$ = id => document.getElementById(id)`.

| Line | Symbol | Role |
|---|---|---|
| 987 | Constants (`PALETTES`, `DENSITY_PRESETS`) | |
| 1017 | State: band arrays, `patternSVG`, `anim`, `media`, `svgFill` | |
| 1108 | `getSettings()` | Snapshot of the dither controls |
| 1191 | `setOutputMode` | |
| 1208 | `initBands` / `setBandCount` / `buildBandUI` | |
| 1237 | Pattern unit: `loadPatternSVGFile`, `buildPatternMips`, `getTintedPattern`, `tintedPatternPNGDataURI` | SVG → mip chain → per-band tinted cache |
| 1508 | `setMode` / `setAlgo` | |
| 1546 | `loadFile` / `loadImage` / `loadLiveSource` | Input routing |
| 1770 | `drawGlyph` | Shared per-cell drawer (block, then char or pattern) |
| 1789 | `render()` | luminance → levels → noise → dither → charGrid → draw |
| 1990–2480 | Typing / flicker / media animation, `startAnimation` / `stopAnim` | |
| 2480–2668 | `exportPNG`, `exportPNGFrames`, `exportSVG`, `exportTXT` | |
| 2773 | Custom fonts | |
| 2967 | SVG Fill: editor, `extractStyledChars`, `loadSVGFillFile`, `buildSVGMask`, `svgFillComputeLayout`, `renderSVGFill` | |
| 3524 | `SVGFILL_TEXT_EFFECTS` | `(t, meta) => {tx,ty,sx,sy,rot,opacity,color,char,clipToCell}` |
| 3551 | `svgFillAnim` | mode, order, revealUnit, speed, effectName/Ms, entryStart, decode, flicker, baseCanvas, recorder |
| 3713 | `svgFillDrawCellWithEffect` | Clip → translate/rotate/scale → `drawStyledCell`. Fast path when `t >= 1` |
| 3749 | `svgFillAnimFrame` | rAF typing loop |
| 3853 | `svgFillInitFlicker` / `svgFillFlickerFrame` | |

Text effects: `None`, `Fade in`, `Slide up`, `SplitText`, `SplitText_mask`.
To add one, add an entry to the registry; the dropdown fills itself.

## 3. Known issues
- `SplitText_mask` pops on its last frame when glyphs are taller than `rowH`, because the fast path doesn't clip.
- Grain is hard-coded off.

## 4. Not in v1 (added in v2)
Custom HSV + alpha colour picker, multiple text blocks with fill order, raster-image masks with threshold, and a char/block flicker unit.
