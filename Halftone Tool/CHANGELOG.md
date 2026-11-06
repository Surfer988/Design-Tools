# Changelog

## v2.1 — 2026-11-05
New **Stippling** tab (image → bars):
- Its own image controls: scale, brightness, contrast, blur, noise, levels, invert.
- Bars: vertical or horizontal, bar width, distance, threshold, output scale.
- Each column is a single bar or random sections, with min/max size, section gap, divergence and a seed.
- Candle line: a middle line through each bar that extends past both ends.
- Colour: tonal bands from a palette, mono, or mono fade (opacity follows brightness); background colour and opacity.
- Animation: an intro (grow / flicker in, by direction or random) combined with a motion (wave / random height / flicker), a grow anchor and loop.
- Exports: PNG, SVG, WebM, PNG sequence.
- Snap to edges: sections break at the threshold outline and at tone-level changes (Edge levels), and are pinned to the stronger edge, so outlines stay crisp in photos too.
- Cubic-bezier curve editors for the Stagger, Per-bar (grow / flicker-in) and Motion (wave / random) timing, with presets and draggable handles.
- Switching tabs now stops the other tabs' animations.
- Fixed a boot race where the colour picker could initialise before its HTML was parsed.

## v2 — 2026-11-05
Merged the newer `index.html` line with v1's Pattern mode.
- **Added (from index.html):**
  - custom HSV + alpha colour picker
  - multiple SVG-Fill text blocks with Sequence/Random fill order
  - raster-image masks with threshold
  - char/block flicker unit
  - flicker base-canvas sync
- **Kept from v1:**
  - Pattern dither mode (SVG glyph tinted per band, per-band size)
  - `xmlns:xlink` in the SVG export
  - stopping a running animation when a new image or live source loads
- **Version switcher:** now reads `versions/manifest.json` in the folder-per-version layout.

## v1 — 2026-05-19
The original stable snapshot.
- ASCII Dithering: phrase, density and pattern modes; Bayer and Floyd–Steinberg.
- SVG Fill with text effects.
- Exports: PNG, PNG sequence, SVG, TXT, WebM.

## Cleanup — 2026-11-05
Removed the redundant `index.html`, `beta.html` (staged-sidebar UI
experiment), `image-processing.html` (staged UI plus embedded V1) and
`PROJECT.md`, whose content now lives in `versions/*/CONTEXT.md`. All of them
can be recovered from the `pre-cleanup` tag.
