# Dots

A browser design tool that turns an image, video or GIF into fine noise dots. The dots gather into the picture, keep
moving (Brownian wander or a wave) and can be shown in real 3D with depth and lens blur. Exports are PNG, WebM and
PNG sequences. It is a single HTML file using WebGL2, with no build step.

**Live:** <https://surfer988.github.io/Design-Tools/Dots%20Tool/> (GitHub Pages; updates after each sync)

**Open locally:** double-click `index.html` (it redirects to the latest version), or run:

```bash
python3 -m http.server 7824
```

then open <http://localhost:7824>.

## Layout

```
dots/
├── index.html            → redirects to the current version
├── AGENTS.md             → instructions for AI agents (start here)
├── CHANGELOG.md
├── sync-to-github.sh     → push to GitHub (Design-Tools/Dots Tool)
└── versions/
    ├── manifest.json     → version list (feeds the in-app "v:" switcher)
    └── v1/ dots.html + CONTEXT.md  ← current
```

Every version folder has a **`CONTEXT.md`** that fully describes that version, so you can paste it into any AI chat.

## Versions

| Version | Date | Summary |
|---|---|---|
| v1 | 2026-11-06 | First version: noise dots, gather intro, Brownian/wave motion, real 3D with lens blur, video/GIF, bezier curves |

## GitHub sync

```bash
./sync-to-github.sh
```

This mirrors the committed state into `Design-Tools/Dots Tool/` with `git subtree`, and pushes tags as `dots-vN`.
