#!/usr/bin/env bash
# Sync this project into github.com/Surfer988/Design-Tools under "Dots Tool/".
#
# Usage:  ./sync-to-github.sh
#
# - Commit your changes here first (only committed work is synced).
# - History is kept via `git subtree`; each local tag vN is pushed as dots-vN.
# - Safe to run repeatedly: it clones the repo to a temp dir, merges, pushes, cleans up.
set -euo pipefail

REMOTE="https://github.com/Surfer988/Design-Tools.git"
PREFIX="Dots Tool"
BRANCH="main"
SRC="$(cd "$(dirname "$0")" && pwd)"

if [ -n "$(git -C "$SRC" status --porcelain)" ]; then
  echo "Uncommitted changes in $SRC; commit them first." >&2
  exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
git clone --quiet "$REMOTE" "$TMP/repo"
cd "$TMP/repo"
git config user.name  "$(git -C "$SRC" config user.name)"
git config user.email "$(git -C "$SRC" config user.email)"

# Empty repo → create the first commit so subtree has something to merge into.
if ! git rev-parse --verify -q HEAD >/dev/null; then
  git checkout --quiet -b "$BRANCH"
  printf '# Design Tools\n\nBrowser-based design tools.\n\n| Tool | Folder |\n|---|---|\n' > README.md
  git add README.md
  git commit --quiet -m "Initial commit"
fi

git fetch --quiet --tags "$SRC" main
if [ -d "$PREFIX" ]; then
  git subtree pull --prefix="$PREFIX" "$SRC" main -m "Sync Dots Tool from local"
else
  git subtree add  --prefix="$PREFIX" "$SRC" main -m "Add Dots Tool"
fi

# List the tool in the root README once.
if [ -f README.md ] && ! grep -q 'Dots Tool' README.md; then
  printf '| Dots | [`Dots Tool/`](Dots%%20Tool/) |\n' >> README.md
  git add README.md
  git commit --quiet -m "README: list Dots Tool"
fi

# Prefix tags so other tools in this repo don't clash (v1 → dots-v1).
for t in $(git -C "$SRC" tag); do
  git tag -f "dots-$t" "$(git -C "$SRC" rev-parse "$t^{commit}")" >/dev/null
done
git tag -d $(git -C "$SRC" tag) >/dev/null 2>&1 || true

git push --quiet origin "$BRANCH"
git push --quiet --force origin 'refs/tags/dots-*'
echo "Synced → https://github.com/Surfer988/Design-Tools/tree/$BRANCH/Dots%20Tool"
