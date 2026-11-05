# Changelog

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
