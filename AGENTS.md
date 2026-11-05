# AGENTS.md

Entry point for AI agents (Claude Code, Codex, Cursor, …) working in this repo.

## Current version: **v2**
Read `versions/v2/CONTEXT.md` before changing anything. The app is the single
file `versions/v2/halftone.html`, with no build step and no dependencies.

## Rules
- **Edit the latest version only.** Older `versions/vN/` folders are frozen snapshots.
- **To cut a new version:**
  1. Copy the current folder: `cp -R versions/v2 versions/v3`.
  2. Make the changes in `v3/halftone.html`, then update `v3/CONTEXT.md` (version table, code map line numbers, and a "Changes from v2" section).
  3. Add an entry to `versions/manifest.json`, set `"current": true` on it, and remove `current` from the old one.
  4. Point the root `index.html` redirect and this file at v3, and add a `CHANGELOG.md` entry.
  5. Commit, then `git tag v3`.
- Keep each `CONTEXT.md` **self-contained**, because people paste it into other chats on its own.
- Run locally with `python3 -m http.server 7823` from the repo root, or use the `halftone` config in `.claude/launch.json`.
- Verify using the checklist in the current `CONTEXT.md`. The browser console should show no errors.
