# AGENTS.md

Entry point for AI agents (Claude Code, Codex, Cursor, …) working in this repo.

## Current version: **v1**
Read `versions/v1/CONTEXT.md` before changing anything. The app is the single
file `versions/v1/dots.html` (WebGL2), with no build step and no dependencies.

## Rules
- **Edit the latest version only.** Older `versions/vN/` folders are frozen snapshots.
- **Version numbers:** a minor step (v1 → v1.1) adds features, and a major step (v1 → v2) is a big rework. Folder names match exactly.
- **To cut a new version:**
  1. Copy the current folder: `cp -R versions/v1 versions/v1.1`.
  2. Make the changes in `v1.1/dots.html`, then update `v1.1/CONTEXT.md` (version table, code map line numbers, and a "Changes from v1" section).
  3. Add an entry to `versions/manifest.json`, set `"current": true` on it, and remove `current` from the old one.
  4. Point the root `index.html` redirect and this file at the new version, and add a `CHANGELOG.md` entry.
  5. Commit, then `git tag v1.1`. Sync to GitHub with `./sync-to-github.sh` only after the user has tested it and said OK.
- Keep each `CONTEXT.md` **self-contained**, because people paste it into other chats on its own.
- Run locally with `python3 -m http.server 7824` from the repo root, or use the `dots` config in `.claude/launch.json`.
- Verify using the checklist in the current `CONTEXT.md`. The browser console should show no errors.
- This is a sibling of the Halftone tool (`../halftone`). The two share UI conventions but no code.
