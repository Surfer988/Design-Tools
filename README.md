# Halftone Dither

A browser design tool for halftone / ASCII-dither graphics and text-filled
shapes, as stills or animations. Each version is a single HTML file with no
build step.

**Open it:** double-click `index.html` (it redirects to the latest version), or run:

```bash
python3 -m http.server 7823
```

then open <http://localhost:7823>.

## Layout

```
halftone/
├── index.html            → redirects to the current version
├── AGENTS.md             → instructions for AI agents (start here)
├── CHANGELOG.md
└── versions/
    ├── manifest.json     → version list (feeds the in-app "v:" switcher)
    ├── v1/  halftone.html + CONTEXT.md
    └── v2/  halftone.html + CONTEXT.md   ← current
```

Every version folder has a **`CONTEXT.md`** that fully describes that version:
features, architecture, code map, how to extend it, and known issues. Paste it
into any AI chat to bring that chat up to speed.

## Versions

| Version | Date | Summary |
|---|---|---|
| v1 | 2026-05-19 | Original stable. Dither (phrase / density / **pattern**) and SVG Fill |
| **v2** | 2026-11-05 | v1 merged with later work: colour picker, multiple text blocks, raster masks |

Each version is also a git tag (`git checkout v1`). The tag `pre-cleanup`
holds the old loose copies (`index.html`, `beta.html`, `image-processing.html`).
