#!/usr/bin/env bash
# update_all_submodules.sh
set -euo pipefail

# Ensure we're in a git repo
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "error: run inside your repo"; exit 1; }

echo "[1/4] Sync submodule URLs"
git submodule sync --recursive

echo "[2/4] Init any missing submodules"
git submodule update --init --recursive

echo "[3/4] Pull latest commits from tracked branches"
# Uses the branch set in .gitmodules for each submodule
git submodule update --remote --recursive --merge

# Optionally refresh nested submodules inside each submodule
git submodule foreach --recursive '
  git submodule sync --recursive
  git submodule update --init --recursive
' || true

echo "[4/4] Commit superproject refs if changed"
if ! git diff --quiet --ignore-submodules=dirty; then
  git add .gitmodules
  git commit -m "chore: update submodules $(date -u +%F)"
  echo "Committed updated submodule refs."
else
  echo "No changes to commit."
fi

echo "Done."
