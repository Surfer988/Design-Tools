# Halftone Dither — v2.2 context

> Self-contained brief for an AI assistant or collaborator. Paste this whole file
> into a new chat together with (or instead of) `versions/v2.2/halftone.html`.

| | |
|---|---|
| **Version** | v2.2 (current) · 2026-11-10 |
| **File** | `versions/v2.2/halftone.html`, a single file with no build step and no dependencies (~6,200 lines of HTML + CSS + vanilla JS) |
| **Built from** | v2.1 (ASCII Dithering, SVG Fill, Stippling) plus a fourth tab, **Halftone**, which turns an image or video into a grid of dots |
| **Run** | Open the file in Chrome/Safari, or serve the repo root (`python3 -m http.server 7823`) and open `/versions/v2.2/halftone.html` |

## 1. What the tool is

A browser design tool for making **halftone / ASCII-dither graphics**,
**text-filled shapes**, **bar-stippled images** and **classic halftone dots**,
as stills or animations.
Everything runs client-side on `<canvas>`. The top **mode banner** switches
between four output modes, which all draw to the same `#output` canvas:

### A. ASCII Dithering (`setOutputMode('video')`, button `#omBtn-video`)
Image, GIF or video in → a dithered grid of characters, blocks or SVG stamps out.
- **Image**: Scale, Brightness, Contrast, Blur, Noise, Invert. **Levels**: Black pt / White pt.
- **Dithering**: Bayer 8×8 (ordered) or Floyd–Steinberg (error diffusion).
- **Text mode** (`renderMode`):
  - `phrase` (Phrase tiling) repeats a phrase across the ink cells.
  - `density` (Density set) picks a char from a light→dark ramp.
  - `pattern` (Pattern) uses an uploaded SVG as the glyph, tinted per band, with a per-band size %.
- **Cell**: size, output scale, margin, font and weight, with custom font upload (`localStorage` key `halftone_custom_fonts_v2`).
- **Tonal bands**: 4/6/8/12 bands, from band 0 = paper to N-1 = darkest ink. Each band has colour, opacity and margin, and bands 1 and up also have Text/Block/Both, a background fill and a pattern size. There is a palette grid and an auto-palette.
- **Animation**: typing (seq/rnd/lr/rl/tb/bt plus decode scramble), flicker, and media playback for GIF/video.
- **Export**: PNG, PNG sequence (ZIP built in the browser), SVG (Pattern mode uses one `<symbol>` per band), TXT, WebM.

### B. SVG Fill / Text Fill (`setOutputMode('svgfill')`)
Drop in an **SVG, or a raster image that gets thresholded to a mask**, and its
interior fills with rows of styled text.
- **Text**: one or more rich-text blocks (`addSVGFillBlock`) with a floating style toolbar and a Sequence/Random fill order.
- **Layout and colours**: line gap, grid margin, SVG size and output; font and background colours via the custom HSV + alpha picker (`openCP`).
- **Animation**:
  - typing: order, reveal per char or per block, speed, stagger, decode, and **Text fx** (`SVGFILL_TEXT_EFFECTS`).
  - flicker: density, slow/fast Hz and cycle, by char or by block.
- **Export**: PNG, SVG, PNG sequence, WebM.

### C. Stippling (`setOutputMode('stipple')`, button `#omBtn-stipple`) — new in v2.1
Image (or GIF/video frame) → **columns or rows of bars**, where each bar's
length follows how dark the image is there. Sidebar `#stipple-panel`, ids
prefixed `st-`, sections can be dragged to reorder.

- **Image**: its own Scale, Brightness, Contrast, Blur, Noise, Black/White pt and Invert. These are separate from the dither tab's controls.
- **Bars**:
  - Direction: **Vertical / Horizontal** (`stip.dir` = `v` / `h`).
  - **Bar width**, **Distance** (gap between bar lines), **Output** scale %, **Threshold** (tones lighter than this get no bar).
- **Each column** (`stip.structure`):
  - `single`: one bar per column. Length = mean darkness × column length, centred on the column's darkness-weighted centroid, clamped to Min/Max size.
  - `sections`: the column is cut into random sections. Each section's length is random between **Min size** and **Max size**, sections are separated by **Section gap**, and the bar in each section is `section length × section darkness`.
  - **Snap to edges** (`stip.snap`, on by default, sections only): the column is first split into *edge runs* (`_stDarkRuns`). A run is a stretch at or above the threshold whose darkness stays on one of **Edge levels** tone steps (`st-snaplev`, 1–8, default 4). A change of level counts as an edge, so a subject is separated from a lighter background that is still above the threshold. Blips of 2 source px or less are absorbed. Sections are cut only inside runs, and a bar that touches a run boundary is pinned to it. When a short run's bar touches both ends, it sits on the stronger tonal step, usually the outline. Edge levels 1 means the threshold outline only. With Snap off, sections ignore the image's edges, which gives a looser, "hairier" look.
  - **Divergence** (0–100%) adds random jitter to bar length and position.
  - **Seed** (with a 🎲 button) makes the randomness reproducible.
- **Candle line**: an optional middle line through each bar that sticks out past both ends, like a candlestick chart. Settings: **Line width**, **Extend** (px past each end, jittered by Divergence), and colour (same as bar, or a custom colour).
- **Colour** (`stip.colorMode`):
  - `bands`: a palette (from `PALETTES`, minus its paper colour) split into 2/3/4/6/8 bands from light to dark, with per-band colour pickers. Choosing a palette also sets the background to its paper colour.
  - `mono`: one solid colour.
  - `alpha` ("Mono fade"): one colour whose opacity follows darkness, from **Min opacity** up to 100%.
  - Background colour + opacity, for all colour modes. 0% gives a transparent PNG.
- **Animation**. An intro and a motion run together:
  - **Intro** (how bars appear):
    - `none`.
    - `grow`: each bar goes from 0 to full length with easeOutCubic.
    - `flicker` ("Flicker in"): each bar blinks with rising probability until it settles on.
    - Order: → ← ↓ ↑ ◎ (centre out) or Random.
    - **Spread** = time from the first bar starting to the last. **Per bar** = how long each bar takes. **Flicker Hz** applies to flicker-in.
  - **Motion** (during and after the intro):
    - `none`.
    - `wave`: a sine wave of height change moving in a direction (→ ← ↓ ↑ ◎), with **Waves** = crests across the image.
    - `random`: smooth per-bar random height change (two sines with random frequency and phase per bar).
    - `flicker`: a **Density** % of bars blink at a random rate between **Slow/Fast Hz**.
    - **Height change** % and **Speed** (Hz) apply to wave and random.
  - **Curves**: three collapsible cubic-bezier editors (`<details class="st-curve" data-curve=…>`). Drag the two yellow handles, pick a preset, or type `x1, y1, x2, y2` (same meaning as CSS `cubic-bezier()`). y can go from −0.6 to 1.6, so curves can overshoot. **All three read like CSS easing: x = time →, y = progress ↑**. Each editor labels its axes (`data-x` / `data-y`).
    - **Stagger curve** (`stagger`, default Linear): y = share of bars that have started by time x within Spread. Steep means many bars start quickly; flat means few. A bar at order position q starts at the curve's **inverse**, `_stCurveInv('stagger', q)`, which uses an inverse lookup table (`_stLUTInv`, first crossing).
    - **Per-bar curve** (`grow`, default Cubic out): y = bar length (Grow) or the chance of being visible (Flicker in) over the bar's own duration. Back out overshoots and then settles.
    - **Motion curve** (`motion`, default Sine in-out): y = bar height, from `1 − Height change` at 0 to full height at 1. Wave plays the curve forward and then back each cycle (Sine in-out ≈ a sine wave). Random runs its noise value through it.
    - Presets: Linear, Ease, Ease in, Ease out, Ease in-out, Sine in-out, Cubic out, Expo out, Expo in, Back out, Back in-out, and Custom.
    - Engine: `stSetCurve(key, [x1,y1,x2,y2])` builds a 257-sample lookup table (`_stLUT`), and `_stCurve(key, p)` reads it each frame. Curves can be edited live during a preview.
  - **Bars grow from**: Centre, Top/Left, or Bottom/Right. This is the anchor used by both grow and height motion.
  - **Loop intro**: the intro repeats every `spread + per bar + 1 s`.
  - **Rec. secs** sets the length of the WebM and PNG-sequence exports.
  - Buttons: ▶ Preview, ⬤ WebM (MediaRecorder at 30 fps, 8 Mbps), 🖼 PNG Seq (24 fps ZIP), ⏸ Pause, ■ Stop. A preview with no loop and no motion stops by itself when the intro ends.
- **Export**: PNG (the static, fully grown frame) and SVG (one `<rect>` per bar and per candle line, grouped by colour).
- **GIF/video sources**: `showFrame()` calls `render()`, which forwards to `renderStipple()` in this mode, so stippling follows the current frame.

### D. Halftone (`setOutputMode('halftone')`, button `#omBtn-halftone`) — new in v2.2
Image, GIF or video → a grid of round dots whose **area** follows how dark the
image is there (like halftonemaker.com). Sidebar `#halftone-panel`, ids
prefixed `ht-`, deliberately few controls. Lives in its own `<script>` block
(the last one before `#cp-popup`); state object `ht`.

- **Canvas & Adjustments**:
  - **Fit mode**: Fit to short edge / long edge. **Base res.** = that edge's size in output px, so it sets the output size.
  - **Blur** (output px, applied with `ctx.filter` on the sampling canvas), **Brightness** (−1…1, subtracted from darkness), **Noise** (0–100%, a fixed per-grid-cell random tone offset from `_htHash(i, j)`, so it doesn't change between renders or video frames), **Gamma** (0.2–3; higher = bigger dots), **Contrast** (−1…1, around mid-grey).
  - **Clamp min / max**: darkness levels. Below min = no dot, above max = full dot.
  - Tone pipeline (`_htTone`): clamp (levels) → contrast → gamma → invert.
  - **Auto Tone** (`htAutoTone`): clamp = 2nd/98th percentile of darkness, contrast 0, gamma so the median lands on 50%. **↺** (`htResetTone`) restores the defaults.
  - **Invert**.
- **Grid**: **Square / Hexagonal** (`ht.grid`), **Spacing** (px between dot centres), **Rotation** (−90…90°, about the image centre), **Dot size** (10–200%; 100% = at full black the dot covers its whole cell, radius sp/√2 square or sp/√3 hex, so dark dots **overlap** like print halftone; ~70% = dots just touch).
- **Dot shape** (`ht.shape`, `htSetShape`): Circle, Square, Diamond, Ellipse (1.25 × 0.8 of the circle radius, same area), Line (cell-long bars whose thickness follows tone, so neighbours join into lines). All shapes turn with the grid Rotation. The stored size per dot depends on the shape (radius, half side, half diagonal or half thickness); `_htPoly` gives corner points for square/diamond/line, which the canvas and SVG (`<polygon>`, `<ellipse transform=rotate>`) share.
- **Corners** (`ht-corner`, 0–100% of the dot's half-size) and **Neck** (`ht-neck`, 0–100% of spacing): rounded dots, and dots that merge into one smooth shape with rounded inside corners and soft holes. When either is above 0, drawing switches from vector shapes to a **signed distance field**:
  - `_htShapeSDF(s)` returns each shape's distance function in the grid frame. Rounded corners use the rounded-box trick: shrink by ρ, then subtract ρ. The diamond is a box turned 45°.
  - `buildHalftoneField` rasterises each dot's distance over its bounding box (shape reach + neck), keeping the **nearest and second-nearest** distance per pixel. It then applies a quadratic smooth-min (k = neck × spacing) between just those two. Smoothing across all neighbours would add up and fill the small white holes.
  - `drawHalftoneField` turns the field into pixels with anti-aliased coverage `clamp(0.5 − d, 0, 1)`, which is about 35 ms at 1120×560.
  - SVG export traces the same field (`_htTracePath`): marching squares over pixel centres with a 1-sample "outside" border, segments stitched into loops, simplified with RDP at 0.25 px, and written as one `<path fill-rule="evenodd">`. It matches the canvas to within about 0.01% of pixels.
  - With both at 0, the fast vector path and the per-dot SVG stay as before.
- **Colour**: dot colour; background colour + opacity (0% = transparent PNG / no SVG rect).
- **Export**: PNG, **SVG** (one `<circle>` per dot in a single `<g fill>`; for video it is the current frame), Copy PNG (Clipboard API).
- **Video / GIF**: upload uses the shared `#file-input` and frame bar (`showFrame` → `render()` → `renderHalftone()`), so scrub/play just work. When the source has more than one frame, the panel shows **⬤ Video (WebM)** (`exportHalftoneVideo`: MediaRecorder on `#output`, every frame once at its own duration, 12 Mbps) and **🖼 PNG Seq** (`exportHalftonePNGSeq`, ZIP), plus a ■ Stop button. Browsers only record WebM natively, so there is no MP4.
- **Engine**: `_htDarkness` draws the source into a sampling canvas capped at 900 px on the long side (darkness = (1 − luminance) × alpha). `buildHalftoneDots` walks the lattice in rotated space, samples bilinearly, and returns a flat `Float32Array` `[x, y, r, …]` with `r = rMax·√tone` (dots under 0.3 px dropped). `drawHalftone` fills all dots in one path.

### Shared controls (all tabs)
- **Presets** (`#preset-bar` under the tab buttons, last `<script>` block before `#cp-popup`): save the current tab's settings under a name, load them later, adjust, then **Update** (overwrite the preset) or just export without saving. **Revert** goes back to the loaded preset; **＋ Save new** saves a copy. The status line shows "● Modified" when the panel differs from the loaded preset. The ⋯ menu has Rename, Delete, **Export all presets (.json)** and **Import presets (.json)** (merges; same-name imports get " (2)").
  - Each preset belongs to one tab (`mode`); the dropdown lists only the current tab's presets.
  - Snapshot = every id'd `input`/`select`/`textarea` in the tab's panel roots (`PRESET_MODES[mode].roots`) + tab state from `PRESET_MODES[mode].get()`: dither `renderMode`/`algo`/`animMode`/palette/all band arrays; SVG Fill text blocks (HTML, sanitised on load by `_presetCleanHTML`), fill order and animation toggles; Stippling toggle keys, palette, band colours, curves; Halftone grid + shape.
  - Applying sets each control and fires its `input` + `change` events (so labels and renders update), re-asserts the values, then calls `set()`.
  - Not saved: the source image/video, an SVG Fill shape, the dither Pattern SVG. Custom fonts are stored separately already.
  - Storage: `localStorage['halftone_presets_v1']` = `[{ id, name, mode, savedAt, snap: { controls, state } }]`. Export file: `{ app: 'halftone-dither', kind: 'presets', version: 1, presets: [...] }`.
- **Version switcher** (top right): reads `../manifest.json`. When the file is opened straight from disk (`file://`) that fetch is blocked, so v2.2 falls back to a built-in list of versions.
- **Type a slider value**: click any value label next to a slider (`.slider-val`), type a number, and press Enter (Esc cancels, clicking away applies). The label may show a scaled value (%, s, px, fps), so the label-to-slider mapping (`label = a + b * raw`) is measured once per slider by firing its own `oninput` (`_svMap`). Values are clamped to the slider's min/max. A value between the slider's steps is kept exactly by loosening `step` (to `1`, or `any` for decimals).
- **Colour inputs**: every `<input type="color">` opens the app's own hex picker (`#cp-popup`) instead of the browser's, whose RGB/HSL/hex mode can't be set by the page. A document-level capture `click` listener calls `openCP(inputEl, inputEl)`. For input targets, the popup gets the `.cp-solid` class (no opacity row), and `_cpApply` writes the hex back and fires the input's `input`/`change` events. The hex field accepts `#rrggbb`, `rrggbb` or `#rgb`. There is an eyedropper button (EyeDropper API, hidden where unsupported). The popup closes on an outside click or when a panel scrolls.

## 2. Architecture

The main `<script>` uses global functions and state with inline `onclick` /
`oninput` handlers, and `$ = id => document.getElementById(id)`. Stippling
lives in its **own later `<script>` block**. The main script's boot calls
`setOutputMode('video')` before that block exists, so the hooks into
stippling are guarded with `typeof renderStipple === 'function'`.

### Code map (line numbers are approximate; rows after ~1290 shifted by ~+130 in v2.2)

| Line | Section / symbol | Role |
|---|---|---|
| 1085 | `#stipple-panel` HTML | Stippling sidebar (toggles use `data-stg` + `data-val`; conditional rows use `data-st-show="key:v1,v2"`) |
| 1318 | Constants: `MAX_DIM`, `PALETTES`, `DENSITY_PRESETS` | |
| 1348 | State: `renderMode`, `algo`, `outputMode`, band arrays, `patternSVG`, `anim`, `media`, `svgFill` | |
| 1475 | `getSettings()` | Snapshot of the dither controls |
| 1558 | `setOutputMode(m)` | `'video'` / `'svgfill'` / `'stipple'` / `'halftone'`. Shows the right panel and stops the other modes' animations |
| 1589 | `initBands` / `setBandCount` / `buildBandUI` | Dither tonal bands |
| 1582 | Pattern unit (`loadPatternSVGFile`, mips, `getTintedPattern`) | Dither Pattern mode |
| 1927 | `loadFile` → `loadImage` / `loadLiveSource` | Input routing (SVG → SVG Fill; GIF/video → frames) |
| 2152 | `getSourcePixels(blur, scale)` | Shared downscaled, blurred source pixels |
| 2169 | `drawGlyph` | Shared per-cell drawer for the dither tab |
| 2188 | `render()` | Dither pipeline. **In stipple / halftone mode it forwards to `renderStipple()` / `renderHalftone()`** |
| 2356–2846 | Dither animation, flicker, media playback | |
| 2889 | `exportPNG`, `exportPNGFrames`, `exportSVG`, `exportTXT`, `buildZip`, `dl` | |
| 3140 | Custom fonts | |
| 3334 | SVG Fill editors and blocks | |
| 3613 | Custom colour picker (`openCP`, `_cpApply`; also drives every `input[type=color]`) | |
| 3806 | Type-a-slider-value (`_svRangeFor`, `_svMap`, document click handler) | |
| 3939–4143 | `loadSVGFillFile`, masks, `svgFillComputeLayout`, `renderSVGFill` | |
| 4399 | `SVGFILL_TEXT_EFFECTS` | `(t, meta) => {tx,ty,sx,sy,rot,opacity,color,char,clipToCell}` |
| 4270–4755 | `svgFillAnim`, `svgFillDrawCellWithEffect`, `svgFillAnimFrame`, flicker, `startSVGFillAnimation` | |
| 5091 | `stip` | Stippling state: toggle keys, `bars`, `s` (settings), `ow`/`oh`, `anim` |
| 5306 | `stSet(key, val)` | Sets a toggle, refreshes button states and `data-st-show` rows, then re-renders |
| 5014 / 5032 | `getStippleSettings()` / `getStippleAnimSettings()` | Read all `st-` controls |
| 5380 | `_stDarkness(s)` | Source → darkness grid (0 = paper, 1 = ink). Alpha counts as paper |
| 5404 | `_stDarkRuns` | Edge runs of a line (threshold + tone levels), used by Snap to edges |
| 5447 | `buildStippleBars(s)` | Darkness → bar list. Works in "line space": `a` = across lines, `p` = along the line |
| 5567 | `_stBarK(b, t, A, seed)` | Per-bar length multiplier at time `t`, or `-1` when hidden |
| 5606 | `drawStippleFrame(ctx, s, bars, t, A)` | Draws one frame (`A = null` → static) |
| 5637 | `renderStipple()` / `debouncedStipple` | Rebuilds bars and draws the static frame. While animating, it only swaps the data |
| 5255–5320 | `startStippleAnim`, `stippleFrame`, `stopStippleAnim`, `toggleStipplePause` | rAF loop with time-based frames and a MediaRecorder |
| 5320–5388 | `exportStipplePNG`, `exportStippleSVG`, `exportStipplePNGSeq` | |
| 5788 | `initStipple()` | Fills the palette select and applies the initial toggle state |
| 1299 | `#halftone-panel` HTML | Halftone sidebar (ids `ht-`) |
| 5938 | Halftone `<script>`: `ht`, `htSv`, `htSetGrid`, `getHalftoneSettings` | |
| 5998 / 6011 | `_htTone` / `buildHalftoneDots` | Tone curve; lattice → dots `[x,y,r…]` |
| 6058 | `renderHalftone()` / `debouncedHalftone` | Builds and draws dots, shows video-export row when the source has frames |
| 6077 | `htAutoTone`, `htResetTone` | |
| ~6110 | `_htShapeSDF`, `buildHalftoneField`, `drawHalftoneField`, `_htTracePath`, `_htRDP` | Corners / Neck field renderer and SVG tracer |
| 6320 | Presets `<script>`: `PRESET_MODES`, `presetSnapshot`, `presetApplySnapshot`, `presetChoose/SaveNew/Update/Revert`, import/export | |
| 6115–6190 | `exportHalftoneSVG`, `copyHalftonePNG`, `exportHalftoneVideo`, `exportHalftonePNGSeq` | |
| end | Version switcher | Reads `../manifest.json` |

### Stippling data model
Each bar is `{ id, line, a0, p0, len, tone, col, alpha, nx, ny, we }`:
- `a0` is the cross-axis start, with width `s.barW`.
- `p0` and `len` are the start and length along the axis, in output px.
- `tone` is 0..1 above the threshold, and decides `col` and `alpha`.
- `nx` / `ny` are the screen-normalised centre, used for animation order and wave direction.
- `we` is the candle-line extension jitter.

The bar layout comes from `_stRng(seed)` (mulberry32), drawn in a fixed order,
so the same seed always gives the same bars. Animation randomness comes from
the stateless `_stHash(id, n)`, so frames depend only on `t`. That is what lets
the PNG sequence render frames offline (`t = i / 24`), and lets settings change
live during a preview.

## 3. How to extend
- **New animation curve**: add a `<details class="st-curve" data-curve="name" data-label="…">` in the panel, a default in `ST_CURVE_DEFAULTS`, and call `_stCurve('name', p)` where it applies. New presets go in `ST_CURVE_PRESETS`.
- **New stippling animation**: add a branch in `_stBarK`. It returns a length multiplier, or `-1` to hide the bar. Then add a `data-stg="motion"` (or `intro`) button, and any rows with `data-st-show="motion:yourname"`. No other wiring is needed.
- **New preset-able state**: plain id'd controls inside a tab's panel are saved automatically. State kept in JS variables needs adding to that tab's `PRESET_MODES[mode].get/set`.
- **New halftone control**: add an `ht-` input with `oninput="htSv(this,'unit')"`, read it in `getHalftoneSettings()`, and use it in `_htTone` / `buildHalftoneDots` / `drawHalftone`.
- **New stippling control**: add an `st-` input with `oninput="stSv(this,'unit')"`, read it in `getStippleSettings()`, and use it in `buildStippleBars` or `drawStippleFrame`.
- **New SVG Fill text effect**: add an entry to `SVGFILL_TEXT_EFFECTS`. The `t = 1` state must look exactly like a plain draw.
- **New dither glyph mode**: add a toggle and a `*-ctrl` block, a branch in `setMode`, the `charGrid` in `render()`, a draw branch in `drawGlyph`, and an `exportSVG` branch.

## 4. Known issues and follow-ups
- `SplitText_mask` pops on its last frame with oversized fonts, because the fast path doesn't clip.
- Dither `grain` is hard-coded off.
- Stippling: when the source is a GIF/video, playback is controlled from the frame bar. The stippling animation and media playback aren't synced for recording.
- Stippling SVG export is always the static frame. The animation only exports as WebM or PNG sequence.
- Very small bar width + gap on large outputs can produce 50k+ bars. Static rendering is still fine, but preview frame rates drop.

## 5. Verification checklist
1. Open the file. The console should show no errors, the top bar should read `v: v2.2`, and the four tabs should fit on one line.
2. **Stippling**: drop in an image. Try Vertical/Horizontal, Single bar/Random sections, a different Seed, Divergence, Candle line, and all three colour modes.
3. **Halftone**: drop in an image, switch tab. Try Square/Hexagonal, Spacing, Rotation 45°, every Dot shape, Corners + Neck (Diamond: rounded diamonds, then merged shapes with soft holes; SVG matches), Brightness/Noise/Gamma/Contrast/Blur, Auto Tone and ↺, Clamp, Invert, colours. Export PNG, SVG, Copy PNG. Drop in a short video: scrub/play updates the dots; Video (WebM) downloads the whole clip; PNG Seq downloads a ZIP.
4. **Presets** on each tab: Save new → change a control (status shows Modified) → Revert / Update. Switch tabs: the dropdown lists only that tab's presets. Export all, delete one, import the file back. Reload the page: presets are still there.
5. Stippling: preview Grow → (L→R) with Motion Wave, then Flicker in + Random order + Motion Flicker. Pause, resume and stop.
6. Stippling: export PNG, SVG, WebM (Rec. secs 2) and a PNG sequence.
7. Switch to ASCII Dithering: the image should re-render as dither, and a running stippling preview should stop.
8. Click a slider's value label, type a number and press Enter; the slider should move. Click any colour swatch; the hex picker should open.
9. **ASCII and SVG Fill regression**: follow the v2 checks (Pattern mode, colour picker, two text blocks, a raster mask).

## 6. Changes from v2.1
- New **Halftone** tab with everything in §1D (image/video → dot grid; PNG, SVG, Copy PNG, WebM, PNG sequence).
- `setOutputMode` handles four modes; `render()` forwards to `renderHalftone()` in halftone mode.
- Mode-banner font is 11px so four tabs fit on one line.
- Halftone: dots overlap in dark areas (100% Dot size covers the cell), Brightness, Noise, five dot shapes, and Corners + Neck (distance-field merging).
- **Presets** for all four tabs (save / load / update / revert / rename / delete / export + import .json).
- Version switcher works when the file is opened from disk (built-in fallback list).

## 7. Changes from v2 (in v2.1)
- New **Stippling** tab with everything in §1C.
- `setOutputMode` handles three modes. It now stops other modes' animations when switching, and re-renders the dither when you come back to ASCII.
- `render()` forwards to `renderStipple()` in stipple mode.
- Mode-banner labels no longer wrap.
- Boot: the deferred init (colour picker, SVG Fill, fonts) now waits for `DOMContentLoaded`, because `#cp-popup` sits after the later scripts and a bare `setTimeout(0)` could run before it was parsed.
- Slider values can be typed (click the value label), on every tab.
- All colour swatches open the app's own hex picker (with an eyedropper) instead of the browser's RGB picker.
