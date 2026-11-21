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
# Since 2026-11-17 CYLTabBarController's CYLUtils depends on its sibling pod CYLAnimatedItem (CYLAnimatedItem.podspec in
# the same repository, not on the trunk yet), so when that commit has the podspec, --write also keeps a
# `pod 'CYLAnimatedItem', :git => …, :commit => '<sha>'` line next to it, adding the line when it is missing.
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
  if git -C "$WORK/repo" cat-file -e "$SHA:CYLAnimatedItem.podspec" 2>/dev/null; then
    if grep -Eq "pod +'CYLAnimatedItem'.*:commit *=> *'[0-9a-f]{40}'" "$podfile"; then
      sed -E -i.bak "/pod +'CYLAnimatedItem'/ s/(:commit *=> *')[0-9a-f]{40}(')/\1$SHA\2/" "$podfile"
    else
      # The same indentation as the CYLTabBarController line, right after it.
      sed -E -i.bak "/pod +'CYLTabBarController'.*:commit/ {
p
s/pod +'CYLTabBarController'/pod 'CYLAnimatedItem'/
}" "$podfile"
    fi
    rm -f "$podfile.bak"
  fi
  echo "updated $podfile"
done
