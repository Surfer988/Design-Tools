# AGENTS.md

Entry point for AI agents (Claude Code, Codex, Cursor, …) working in this repo.

## Current version: **v2.2**
Read `versions/v2.2/CONTEXT.md` before changing anything. The app is the single
file `versions/v2.2/halftone.html`, with no build step and no dependencies.

## Rules
- **Edit the latest version only.** Older `versions/vN/` folders are frozen snapshots.
- **Version numbers:** a minor step (v2.1 → v2.2) adds features, and a major step (v2 → v3) is a big rework. Folder names match exactly (`versions/v2.2/`).
- **To cut a new version:**
  1. Copy the current folder: `cp -R versions/v2.2 versions/v2.3`.
  2. Make the changes in `v2.3/halftone.html`, then update `v2.3/CONTEXT.md` (version table, code map line numbers, and a "Changes from v2.2" section).
  3. Add an entry to `versions/manifest.json`, set `"current": true` on it, and remove `current` from the old one.
  4. Point the root `index.html` redirect and this file at the new version, and add a `CHANGELOG.md` entry.
  5. Commit, then `git tag v2.3`. Sync to GitHub with `./sync-to-github.sh` only after the user has tested it and said OK.
- Keep each `CONTEXT.md` **self-contained**, because people paste it into other chats on its own.
- Run locally with `python3 -m http.server 7823` from the repo root, or use the `halftone` config in `.claude/launch.json`.
- Verify using the checklist in the current `CONTEXT.md`. The browser console should show no errors.
