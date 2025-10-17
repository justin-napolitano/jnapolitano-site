#!/usr/bin/env bash
# add_post_submodule.sh
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <git-repo-url> [slug]"
  exit 1
fi

URL="$1"
SLUG="${2:-}"

# derive slug from repo name if not provided
if [[ -z "$SLUG" ]]; then
  # strip .git and trailing slashes
  SLUG="$(basename "${URL%.git}")"
  # fallback if empty
  [[ -z "$SLUG" ]] && SLUG="post-$(date +%Y%m%d%H%M%S)"
fi

TARGET="site/content/posts/${SLUG}"

# ensure we are in a git repo
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "error: run inside your site repo"
  exit 1
}

# guard: path must not exist or be tracked already
if git ls-files --error-unmatch "$TARGET" >/dev/null 2>&1 || [[ -e "$TARGET" ]]; then
  echo "error: target path exists or tracked: $TARGET"
  exit 1
fi

# detect default branch of remote (falls back to main)
BRANCH="$(git ls-remote --symref "$URL" HEAD 2>/dev/null | awk -F'[/ ]' '/^ref:/ {print $NF; exit}')"
BRANCH="${BRANCH:-main}"

echo "Adding submodule:"
echo "  URL:    $URL"
echo "  Branch: $BRANCH"
echo "  Path:   $TARGET"

git submodule add -b "$BRANCH" "$URL" "$TARGET"
git add .gitmodules "$TARGET"

git commit -m "Add blog post submodule: ${SLUG} (${URL})"

echo "Done."
echo "Update later with: git submodule update --remote --merge \"$TARGET\""
