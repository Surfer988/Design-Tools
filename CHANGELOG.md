# Changelog

## v1 — 2026-11-06
First version.
- Image, video and GIF input, with a frame bar (play, scrub, frame counter).
- Image controls: detail, brightness, contrast, blur, noise, levels, threshold, invert.
- Dots:
  - size and size variation
  - even grid, or random Poisson-disc spacing (min/max distance) with a Uniformity relax that evens out clumps and holes
  - divergence and seed
  - tone shown by density, size or both (density thins out evenly, using a blue-noise order)
- Colour: mono, image colours, or near → far depth gradient. Normal or glow blending, background colour and opacity.
- Intro: dots gather from an even, random or centre scatter.
  - Order options, spread and travel time, swirl, arc, start opacity, size and density.
  - Gather ⇄ disperse loop.
- Motion: Brownian wander and jitter (with Coherence, so neighbours drift together), and/or a wave (6 directions; X/Y/Z/along axis; size pulse). Optionally also before and during the gather, for seamless loops.
- Bezier curve editors: Stagger, Travel, Fade-in, Wave.
- Real 3D (WebGL2):
  - depth from brightness, random, or an uploaded depth map, with random mix and clustering
  - depth amount, perspective, far fade
  - turn, tilt, drag-to-orbit, auto orbit
  - lens blur with aperture, focus, pick-focus and rack focus
- Exports: PNG, PNG 2×, WebM, PNG-sequence ZIP.
- Presets: save new, update, revert, rename, delete, and export/import `.json` files. A ● modified flag shows when settings differ from the loaded preset, and exports never change a preset.
- 3D view:
  - axis ball (drag to orbit, click an axis for front/side/top views)
  - ⟲ Reset view
  - Orthographic (default, with a front view identical to 2D) or Perspective with an FOV control
- Viewport: trackpad pinch / scroll zoom around the cursor (like Halftone), and drag to pan (Shift in 3D).
- Foldable sidebar sections (click a header; remembered).
- Type-a-value slider labels; hex colour picker with eyedropper.
