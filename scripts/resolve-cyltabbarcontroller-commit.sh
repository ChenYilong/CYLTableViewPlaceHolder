#!/bin/bash
# Usage: scripts/resolve-cyltabbarcontroller-commit.sh [--write <Podfile>...]
#
# Prints the newest commit of CYLTabBarController as "<sha> <committer date, ISO 8601> <branch>". "Newest" is the commit
# with the latest committer timestamp on ANY branch, compared as instants (the offsets in the dates differ), not the tip
# of master or main: the newest work often lives on a feature branch. Run it before every build that depends on
# CYLTabBarController (instructions.md, "Depending on CYLTabBarController").
#
# With --write, also rewrites the `:commit => '<sha>'` of the `pod 'CYLTabBarController'` line in each given Podfile;
# it fails when a Podfile has no such line. CYL_TABBARCONTROLLER_URL overrides the repository (default: GitHub).
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
# Commits and trees only (no file contents), every branch.
git clone --bare --filter=blob:none --quiet "$URL" "$WORK/repo"
LINE=$(git -C "$WORK/repo" for-each-ref --sort=-committerdate --count=1 \
  --format='%(objectname) %(committerdate:iso-strict) %(refname:short)' refs/heads)
[[ -n "$LINE" ]] || { echo "error: no branches found in $URL" >&2; exit 1; }
SHA=${LINE%% *}
[[ "$SHA" =~ ^[0-9a-f]{40}$ ]] || { echo "error: unexpected output: $LINE" >&2; exit 1; }
echo "$LINE"

for podfile in "${WRITE[@]+"${WRITE[@]}"}"; do
  grep -Eq "pod +'CYLTabBarController'.*:commit *=> *'[0-9a-f]{40}'" "$podfile" ||
    { echo "error: $podfile has no pod 'CYLTabBarController' ... :commit => '<sha>' line" >&2; exit 1; }
  sed -E -i.bak "/pod +'CYLTabBarController'/ s/(:commit *=> *')[0-9a-f]{40}(')/\1$SHA\2/" "$podfile"
  rm -f "$podfile.bak"
  echo "updated $podfile"
done
