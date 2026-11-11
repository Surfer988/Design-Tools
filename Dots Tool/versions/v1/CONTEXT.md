# Dots v1: context

This is a self-contained description of **Dots v1**, so you can paste it into any AI chat.

| | |
|---|---|
| **File** | `versions/v1/dots.html`: one HTML file (~2,100 lines) with no build step, no dependencies and no network calls |
| **Version** | v1 (2026-11-06), the first version |
| **Renderer** | WebGL2 point sprites, plus a 2D canvas for the source image and curve editors |
| **Repo** | `/Users/v/Claude Code/dots` (local git), mirrored to `github.com/Surfer988/Design-Tools` under `Dots Tool/` |

## 1. What the tool does
Dots turns an image, video or GIF into a field of fine noise dots. The dots can:
- **gather** into the picture from a scattered cloud, with bezier-timed staggering
- **keep moving** once formed (Brownian wander and/or a wave)
- be seen in **real 3D**, where every dot has a distance from the camera, with an orbiting camera, perspective, far fade and per-dot **lens blur** (bokeh)

Output is PNG (1× / 2×), WebM (real time) or a PNG-sequence ZIP (offline, 24 fps).

### Presets (top of the sidebar)
- **Contents**: a preset holds every control in `#sections` (sliders, checkboxes, number inputs, selects and colours), every toggle (`ui`) and the four curves. It does **not** hold the source image/video or an uploaded depth map.
- **Storage**: `localStorage` under `dots-presets`, as `{ name: { state, savedAt } }`. **Default (built-in)** is the factory state captured at boot; it can't be updated, renamed or deleted.
- **Modified state**: loading a preset sets `presets.base`. Any change makes the current state differ from it, which shows **● modified** and enables **Update** (overwrite the preset) and **Revert** (reload it).
  - Exports always use the current settings. Changing things and exporting without clicking Update leaves the preset untouched ("export it just once").
- **Buttons**:
  - **＋ Save new** asks for a name inline.
  - **⋯** opens Rename, Delete, **Export file** (`<name>.dots-preset.json`) and **Import file**. An imported file is added as a new preset and loaded.
  - Loading a different preset while modified asks for confirmation first.

### Sidebar sections
The sections can be reordered by dragging their header; the order is saved in `localStorage` under `dots-section-order`. **Clicking** a header (or the Preset box header) folds or unfolds that section; the folded set is saved under `dots-folded` (`initFolding`). A folded Preset box still shows the preset name and the ● modified flag. Click any slider's value to type an exact number. Every colour swatch opens a hex picker with an eyedropper.

- **Image**
  - Detail: the sampling resolution (long side).
  - Brightness, Contrast, Blur, Noise, Black pt, White pt.
  - Threshold: tones lighter than this get no dots.
  - Invert.
- **Dots**
  - Output: the canvas long side.
  - Dot size, Size variation.
  - Distance between dots:
    - **Even**: a grid at *Distance*.
    - **Random**: Poisson-disc spacing between *Min* and *Max distance*. Even with min = max and divergence 0 this is still blue noise (random positions; only the minimum gap is fixed), so tight pairs and holes appear.
    - **Uniformity** (Random only, default 0%): `relax()` runs up to 20 rounds of short-range repulsion after sampling. Pairs closer than 1.3 × their Poisson distance push apart, so clumps and holes even out but the layout stays organic. Measured at 6px/6px: nearest-neighbour CV 0.080 → 0.028, closest pair 6.0 → 6.6px. The work is capped at about 5M dot-steps (+~1 s at 950k dots). Lloyd relaxation (Voronoi centroids) was tried and was less even (CV 0.068) and ~5× slower. Note: Brownian motion with Coherence 0% moves each dot independently (default 2px), so at small spacings it brings back the clumps; raise Brownian *Coherence* to keep the spacing while moving.
  - Divergence: positional jitter.
  - Image tone shown by: **Density** (darker = more dots), **Size** (darker = bigger) or **Both**. Density thinning is even (blue-noise order from `blueRanks`), so light areas keep the even spacing instead of clumping. Measured at 3px/3px: nearest-neighbour CV of the kept dots at 5% density 0.47 (random) → 0.11, at 30% 0.25 → 0.13.
  - Seed (🎲).
- **Colour**
  - Mono, Image (source colours) or Depth (near → far gradient).
  - Dot opacity.
  - Normal or Glow (additive) blending.
  - Background colour and opacity. Opacity 0 gives a transparent PNG.
- **3D & lens** (2D / 3D toggle)
  - Distance from camera comes from:
    - **Brightness**: dark = near.
    - **Random**: per-dot random.
    - **Depth map**: an uploaded greyscale image, white = near.
  - Random mix: blends Brightness or Map toward random.
  - Clustering: pulls random depths toward the middle.
  - Depth smooth: the mip level the image depth is read at.
  - Invert depth.
  - Near / far: Depth amount, Far fade (default 0).
  - **View**:
    - **Orthographic** (default) or **Perspective**. In orthographic, the front view (Turn 0, Tilt 0) is pixel-identical to 2D, and depth only shows when you rotate.
    - Perspective (FOV 5–120°) is shown in perspective mode. The z = 0 plane always keeps the same framing, so the FOV only changes how strongly near and far differ.
    - Turn (−180..180, wraps) and Tilt (−90..90).
    - ⟲ Reset view.
    - Auto orbit amount and period.
  - Lens blur (Aperture default 0): Aperture, Focus, ⌖ Pick focus (then click a dot), Rack focus during the intro (Focus from → Focus).
- **Animation**
  - Intro: None, or Gather. Gather settings:
    - Dots start: Even, Random or Centre.
    - Scatter area, Scatter depth.
    - Order: random, ←→↑↓, centre-out, outside-in, near → far.
    - Spread, plus the **Stagger curve**.
    - Travel time, plus the **Travel curve**.
    - Swirl, Arc.
    - Start opacity / size / **density** (the share of dots visible at the start; the rest appear as they fly in), plus the **Fade-in curve**, which drives all three.
    - Once, or Gather ⇄ disperse (with Hold).
  - Motion: None, Brownian, Wave or Both.
    - **Also move before gathering**: off = each dot starts moving only as it arrives. On = the scattered cloud moves the same way before and during the gather (and in a gather ⇄ disperse loop), so the animation never goes still.
    - Brownian: Wander, Wander speed, Coherence, Jitter, Wander in depth.
    - Coherence (default 0%): blends each dot's own random phase with a smooth phase field over the canvas (features ~⅓ of the canvas, `u_bCoh`). At 100%, neighbours share almost the same offset, so the cloud drifts like a current and the Uniformity spacing survives the motion.
    - Wave:
      - Direction: → ← ↓ ↑ ↘ ◎ (radial).
      - Axis: X, Y, Z or Along.
      - Amplitude, Waves, Wave speed, Size pulse, plus the **Wave curve**.
  - Rec. secs; ▶ Preview, ⬤ WebM, 🖼 PNG Seq; Pause / Stop.
- **Export**: PNG and PNG 2× of the current frame.

### Viewport (right side)
- **Zoom**: trackpad pinch or two-finger scroll / mouse wheel zooms around the cursor, like Halftone (`setZoom(z, anchor)`). You can also use the toolbar − / + / 1:1 / Fit.
- **Drag**:
  - In 2D, dragging pans (the wrapper scrolls).
  - In 3D, dragging the canvas orbits. Hold Shift or Space, or drag the empty area around the canvas, to pan instead.
- **Axis ball** (3D only, top right, `#view-ctl`):
  - It draws the world X (red), Y (green) and Z (blue) axes with the camera's rotation. The positive ends are labelled, and nearer bubbles are drawn on top.
  - Drag it to orbit. Click a bubble to animate the view to look along that axis:
    - X = side (−90°, 0)
    - Y = top (0, 90°)
    - Z = front (0, 0)
    - The opposite bubbles give the opposite views.
  - Below it are **⟲ Reset view** and an **Ortho / Persp** switch. These share the `proj` toggle with the sidebar.

### Video / GIF
- **Video** plays from a hidden `<video>` element. Each frame is drawn into the source canvas and uploaded as a texture.
- **GIF** frames are decoded once with `ImageDecoder` into ImageBitmaps.
- The **frame bar** under the canvas works like Halftone's: ▶ / ⏸ play the source, the scrubber seeks, and a counter shows the frame. At 30 fps, frame = ⌊currentTime·30⌋.
- While Preview / WebM runs, the video restarts at 0 and plays alongside.
- The PNG sequence seeks the source to each frame's time with `seekMediaToTime(t)`, so it is frame-exact.

### Curves (CSS cubic-bezier, x = time →, y = progress ↑)
| Curve | x | y | Notes |
|---|---|---|---|
| Stagger | time within Spread | share of dots that have set off | Used **inverted**: a dot at order position q sets off when the curve reaches q. Steep = fast |
| Travel | flight time | distance covered | Overshoot (Back) is allowed. Also drives Rack focus |
| Fade-in | flight time | opacity / size / density from the Start values to full | |
| Wave | time within half a wave cycle | offset low → high | |

Presets: Linear, Ease, Ease in/out/in-out, Sine in-out, Cubic out, Expo out/in, Back out/in-out. You can drag the yellow handles or type `x1, y1, x2, y2`.

## 2. Architecture
**Main idea:** the CPU builds only the **layout**, meaning dot positions plus four random numbers per dot. Everything else is computed per frame in the **vertex shader**:
- tone from the source texture
- density and size
- colour and depth
- intro flight, motion, camera, perspective, lens blur and fade

A frame is therefore a pure function of (settings, source frame, t). This is what makes PNG sequences and recordings match the preview, and lets a video play under a fixed set of dots.

```
image/video frame ─► srcCanvas (Detail res, CSS blur filter) ─► texSrc (RGBA8 + mipmaps) ─┐
depth map ─► depthCanvas ─► texDepth (+ mipmaps) ─────────────────────────────────────────┤
curves ─► 256×1 RGBA16F texCurves (R = stagger⁻¹, G = travel, B = fade, A = wave) ─────────┤
layout (CPU) ─► VBO: pos(2) rnd(4) start(3) per dot ──────────────────────────────────────┴─► VS ─► FS (soft disc, premultiplied)
```

- **Per-dot data** (`layout.data`, 9 floats per dot):
  - `pos.xy`: target in output px, y down.
  - `rnd.x`: density rank. The dot is shown if `rank < tone`. Not random: `blueRanks()` orders the dots by progressive weighted sample elimination (Yuksel 2015). In stages that halve the set, it removes the most crowded dot (weight Σ(1 − d/2r)^8 over neighbours closer than the hex spacing 2r of the stage target), and removed dots get the highest remaining ranks, so any prefix is evenly spread. Cost: ~0.4 s at 166k dots, ~2.6 s at 950k (once per layout rebuild).
  - `rnd.y`: size jitter.
  - `rnd.z`: random depth.
  - `rnd.w`: phase, random order and noise seed.
  - `start.xyz`: scattered start, normalised to −0.5..0.5 and scaled by the `u_scatter` uniform.
- **Layout rebuilds** (`rebuildLayout`) happen only for Output, Distance(s), Uniformity, Divergence, Seed and the spacing toggle. The scatter toggle only rewrites `start` (`rescatter`). Detail and Blur re-upload the source. Everything else only redraws.
- **Projection**: `u_ortho = 1` skips the perspective divide (`persp = 1`). Lens blur then uses a fixed 45° reference `camDist`, so its strength doesn't depend on the FOV slider.
- **Coordinates**:
  - World coordinates are centred on the canvas: x right, y up, z toward the camera. Depth `z = (z01 − 0.5) · depthAmt`.
  - The camera sits at `camDist = (H/2)/tan(fov/2)`, so z = 0 maps 1:1 onto the canvas.
  - `u_rot = Ry(yaw)·Rx(pitch)`, column-major.
- **Lens blur**: `coc = aperture·0.6 · |z − focus| / camDist · persp`.
  - Point size = `√(size² + coc²)`.
  - Alpha × `size² / (size² + coc²)`, so the same amount of "ink" spreads wider.
  - The fragment edge softness is `coc / pointSize`.
  - Points smaller than 1 px are drawn at 1 px with alpha × size².
- **Clock**: a single rAF `tick` drives the dot animation (`anim`) and/or the source playback (`media.playing`). With nothing running, a static frame is drawn on demand (`requestDraw`). `introTime(t)` maps clock time to intro time for the ping-pong loop.

### Code map (line numbers approximate)
| Line | Symbol | Role |
|---|---|---|
| 228 / 235 | `#sidebar`, `#preset-box` HTML | Toggles use `data-tg` + `data-val`; conditional rows use `data-show="key:v1,v2;key2:v"` |
| 588 | `ui` | Toggle state (including `proj`: ortho / persp) |
| 599–725 | `CURVE_PRESETS`, `setCurve`, `buildCurveEditor`, `curveEditorRefresh` | Bezier curves, LUT + inverse, canvas editors |
| 749 | `VS` | Vertex shader: tone, depth, intro, motion, camera (ortho / persp), blur, colour |
| 915 | `FS` | Soft round point, premultiplied |
| 935 | `initGL` / `uploadCurves` | Program, VAO, textures, uniform lookup |
| 983 | `media`, `loadFile`, `loadGif`, `loadVideo`, `seekMediaToTime`, `uploadSource`, `loadDepthMap` | Sources |
| 1147 | `poisson`, `relax` | Variable-radius Bridson Poisson-disc; Uniformity relax |
| 1296 | `blueRanks`, `rebuildLayout` / `writeScatter` | Even thinning order, layout and start positions |
| 1384 | `introTime`, `camDist`, `frameParams`, `setUniforms`, `drawFrame` | Per-frame parameters and draw (also redraws the axis ball) |
| 1470 | `anim`, `tick`, `startAnim`, `stopAnim`, `togglePause` | Clock, preview, WebM recording |
| 1569 | `exportPNG`, `buildZip`, `exportPNGSeq` | Exports |
| 1648 | `pickFocusAt` | CPU mirror of the shader's depth |
| 1680 | `zoom`, `setZoom`, wheel handler | Trackpad / wheel zoom around the cursor |
| 1710 | `setView`, `animateView`, `resetView`, canvas drag | Orbit / pan |
| 1764 | `AXES`, `drawGizmo` | Axis ball |
| 1832 | `onControl`, `setToggle`, `refreshVisibility` | Sidebar wiring |
| 2000 | `openCP` | Hex colour picker for every `input[type=color]` |
| 2050 | `presets`, `getState`, `applyState`, `presetSaveNew` / `Update` / `Revert` / `Rename` / `Delete` / `ExportFile` / `ImportFile` | Presets |
| 2019 / 2034 | `demoImage` / `boot` | Demo image; captures the built-in Default preset |
| end | Version switcher | Reads `../manifest.json` |

## 3. How to extend
- **Presets** pick up any new `#sections` control with an `id` automatically. Old presets without the new id keep that control's current value.
- **New slider**: add `<input type="range" id="x" data-u="unit">` + `<span class="slider-val">`, then read it in `setUniforms`. Add its id to `LAYOUT_IDS` or `SOURCE_IDS` if it changes the layout or the source.
- **New uniform**: declare it in `VS`. It is picked up automatically, since `U[name]` is filled from the active uniforms.
- **New toggle**: add buttons with `data-tg="key" data-val="…"`, a default in `ui`, and use `ui.key` in `setUniforms`.
- **New intro order**: add an `<option>` to `#order` and a branch in the `key` expression in `VS`.
- **New curve**: add a `<details class="curve" data-curve="name">` and a default. The texture has 4 channels and all are used, so a 5th curve needs a second row or texture.
- **New motion**: add it in the motion block of `VS`. Scale it by `settle`: that fades the motion in as each dot arrives, or is 1 throughout when *Also move before gathering* is on (`u_motionPre`).

## 4. Known issues and follow-ups
- WebM recording runs in real time and needs the tab visible. Background tabs pause `requestAnimationFrame`. The PNG sequence works offline.
- Dots aren't depth-sorted. In Normal blending, overlapping blurred dots blend in draw order, which is hard to notice with noise. Glow (additive) doesn't depend on order.
- A video recorded without a duration in its metadata (some WebMs) shows a frame count estimated from `duration`.
- There is no SVG export, because hundreds of thousands of circles aren't practical.
- Pick focus ignores motion offsets. It uses each dot's formed position.
- The dot cap is 1.5M. Spacing is raised automatically above that, and the Dots section says so.

## 5. Verification checklist
1. Open the file. The console should show no errors, and the demo image should render as dots.
2. Drop an image. Switch Even and Random, change the Seed (the layout should change deterministically), and switch Tone between Density, Size and Both.
3. Turn on 3D in Orthographic: the image shouldn't change. Click the axis ball's Y and X bubbles (top / side views), drag the ball, then ⟲ Reset view. Switch to Persp and change Perspective. Pinch or scroll to zoom around the cursor; drag to pan (Shift in 3D).
4. Fold and unfold a few sections and the Preset box, then reload: they should stay folded.
5. Presets: Save new, change something (● modified), Revert, change again, Update, reload the page, load it, Export file / Import file.
6. In 3D, switch the depth source between Brightness, Random and Depth map, drag the canvas to orbit, and change Aperture and Focus. ⌖ Pick focus on a dot should make it sharp.
7. Preview Gather with each Dots start option and some Swirl, then Gather ⇄ disperse. Edit the Stagger curve: steep should mean many dots leave at once. Set Start density to 20%: only about a fifth of the dots should show at the start. Turn on *Also move before gathering* with Brownian: the scattered cloud should already move.
8. Try Motion Brownian, Wave (radial, Z axis in 3D) and Both. With Random spacing at 6/6px, Uniformity 100% and Wander 2.5px, Coherence 0% should show bumping pairs and 100% even spacing that still moves.
9. Drop a video: the frame bar should appear, and ▶ / the scrubber should work. Preview: the video should play under the dots.
10. Export PNG, PNG 2×, WebM (Rec. secs 2) and the PNG sequence (frame count = secs × 24).

Measured in v1:
- Frames are deterministic.
- The share of arrived dots matches the Stagger curve to within about 2%.
- In orthographic, 3D at the front view is pixel-identical to 2D (0 bytes differ).
- Start density 20% shows 20.7% of the dots at t = 0. The formed image is unchanged.
- Also move before gathering: the scattered cloud is still when it's off and moves when it's on.
- About 780k dots render in about 3 ms per frame.
- A 1 s WebM is about 0.7 MB.
- A 1 s PNG sequence has 24 frames.
