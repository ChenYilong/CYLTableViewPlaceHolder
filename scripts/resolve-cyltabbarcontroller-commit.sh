#!/bin/bash
# Usage: scripts/resolve-cyltabbarcontroller-commit.sh [--write <Podfile or Cartfile>...]
#
# Prints the newest commit of CYLTabBarController as "<sha> <committer date, ISO 8601> <branch>". "Newest" is the commit
# with the latest committer timestamp on ANY branch, compared as instants (the offsets in the dates differ), not the tip
# of master or main: the newest work often lives on a feature branch. Run it before every build that depends on
# CYLTabBarController (instructions.md, "Depending on CYLTabBarController").
#
# With --write, also rewrites the `:commit => '<sha>'` of the `pod 'CYLTabBarController'` and `pod 'CYLAnimatedItem'`
# lines in each given Podfile;
# for a Cartfile, the `github "ChenYilong/CYLTabBarController" "<sha>"` line. It fails when a file has no such line. CYL_TABBARCONTROLLER_URL overrides the repository (default: GitHub).
set -euo pipefail
URL="${CYL_TABBARCONTROLLER_URL:-https://github.com/ChenYilong/CYLTabBarController.git}"
WRITE=()
if [[ "${1:-}" == "--write" ]]; then
  shift
  [[ $# -gt 0 ]] || { echo "usage: $0 --write <Podfile>..." >&2; exit 2; }
  WRITE=("$@")
fi

WORK=$(mktemp -d "${TMPDIR:-/tmp}/cyltbc-resolve.XXXXXX")
trap 'rm -rf "${WORK:?}"' EXIT
# Commits and trees only (no file contents), every branch. GitHub sometimes drops an anonymous clone on CI ("fatal: could
# not read Username for 'https://github.com': Device not configured", "expected flush after ref listing", 2026-11-22):
# never prompt for credentials, and try up to 4 times with a growing pause before failing.
export GIT_TERMINAL_PROMPT=0
for attempt in 1 2 3 4; do
  rm -rf "$WORK/repo"
  if git clone --bare --filter=blob:none --quiet "$URL" "$WORK/repo"; then
    break
  fi
  [[ $attempt -lt 4 ]] || { echo "error: could not clone $URL after $attempt attempts" >&2; exit 1; }
  echo "clone of $URL failed (attempt $attempt), retrying" >&2
  sleep $((attempt * 5))
done
LINE=$(git -C "$WORK/repo" for-each-ref --sort=-committerdate --count=1 \
  --format='%(objectname) %(committerdate:iso-strict) %(refname:short)' refs/heads)
[[ -n "$LINE" ]] || { echo "error: no branches found in $URL" >&2; exit 1; }
SHA=${LINE%% *}
[[ "$SHA" =~ ^[0-9a-f]{40}$ ]] || { echo "error: unexpected output: $LINE" >&2; exit 1; }
echo "$LINE"

for podfile in "${WRITE[@]+"${WRITE[@]}"}"; do
  if [[ "$(basename "$podfile")" == Cartfile* ]]; then
    # A Cartfile pins the commit as `github "ChenYilong/CYLTabBarController" "<sha>"`.
    grep -Eq '^github "ChenYilong/CYLTabBarController" "[0-9a-f]{40}"' "$podfile" ||
      { echo "error: $podfile has no github \"ChenYilong/CYLTabBarController\" \"<sha>\" line" >&2; exit 1; }
    sed -E -i.bak "s|^(github \"ChenYilong/CYLTabBarController\" \")[0-9a-f]{40}(\")|\1$SHA\2|" "$podfile"
    rm -f "$podfile.bak"
    echo "updated $podfile"
    continue
  fi
  # The repository holds two pods, CYLTabBarController and CYLAnimatedItem (version-locked): both lines follow it.
  grep -Eq "pod +'(CYLTabBarController|CYLAnimatedItem)'.*:commit *=> *'[0-9a-f]{40}'" "$podfile" ||
    { echo "error: $podfile has no pod 'CYLTabBarController' / 'CYLAnimatedItem' ... :commit => '<sha>' line" >&2; exit 1; }
  sed -E -i.bak "/pod +'(CYLTabBarController|CYLAnimatedItem)'/ s/(:commit *=> *')[0-9a-f]{40}(')/\1$SHA\2/" "$podfile"
  rm -f "$podfile.bak"
  echo "updated $podfile"
done
