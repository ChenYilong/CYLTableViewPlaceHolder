#!/usr/bin/env bash
# Usage: scripts/sync-harmonyos-classifymenu.sh [--check]
#
# [EN] Copies CollectionViewClassifyMenu's HarmonyOS tag list module (harmony/classifymenu, ohpm package
#      `@cyl/classifymenu`: CYLTagListView / CYLTagListState, with the long-press action API and titleMaxLines) at the
#      commit CrossPlatform/harmonyos-cylplaceholder/classifymenu.commit holds into
#      CrossPlatform/harmonyos-cylplaceholder/classifymenu, and writes that commit into its UPSTREAM_COMMIT. The example
#      uses the tag list for its sectioned lists (docs/instructions/examples.md). The module needs the engine commit in
#      cyltabbar-harmony.commit (scripts/sync-harmonyos-cylanimateditem.sh). It is copied rather than referenced with
#      `file:` so that a fresh clone builds; the copy is upstream's, unchanged: never edit it, move the commit and re-run
#      this script. CYL_CLASSIFYMENU_URL overrides the repository (a local clone path works). --check only compares.
# [CN] 把 CollectionViewClassifyMenu 鸿蒙端的 tag list 模块（harmony/classifymenu）按 classifymenu.commit 里的 commit 复制到
#      CrossPlatform/harmonyos-cylplaceholder/classifymenu，并写入 UPSTREAM_COMMIT。复制的文件保持上游原样，不要修改；--check 只比较。
set -euo pipefail
cd "$(dirname "$0")/.."
URL="${CYL_CLASSIFYMENU_URL:-https://github.com/ChenYilong/CollectionViewClassifyMenu.git}"
PIN_FILE=CrossPlatform/harmonyos-cylplaceholder/classifymenu.commit
SHA=$(grep -E '^[0-9a-f]{40}$' "$PIN_FILE" | head -n 1)
[[ -n "$SHA" ]] || { echo "error: $PIN_FILE holds no 40-character commit" >&2; exit 1; }
UPSTREAM_PATH=harmony/classifymenu
DEST=CrossPlatform/harmonyos-cylplaceholder/classifymenu
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
git init --quiet "$WORK/repo"
git -C "$WORK/repo" config core.longpaths true
git -C "$WORK/repo" fetch --quiet --depth 1 "$URL" "$SHA" >&2 || git -C "$WORK/repo" fetch --quiet "$URL" "$SHA" >&2
STAGE="$WORK/stage"
mkdir -p "$STAGE"
git -C "$WORK/repo" archive "$SHA" "$UPSTREAM_PATH" | tar -x -C "$STAGE"
cat > "$STAGE/$UPSTREAM_PATH/UPSTREAM_COMMIT" <<EOF
# Copied by scripts/sync-harmonyos-classifymenu.sh. Do not edit this folder: re-run the script instead.
repository=https://github.com/ChenYilong/CollectionViewClassifyMenu
commit=$SHA
path=$UPSTREAM_PATH
EOF
IGNORED=(--strip-trailing-cr -x build -x .test -x oh_modules -x .hvigor -x BuildProfile.ets -x oh-package-lock.json5)
if [[ "${1:-}" == "--check" ]]; then
  if diff -r "${IGNORED[@]}" "$STAGE/$UPSTREAM_PATH" "$DEST" >/dev/null 2>&1; then
    echo "$DEST matches CollectionViewClassifyMenu $SHA"
    exit 0
  fi
  diff -r "${IGNORED[@]}" "$STAGE/$UPSTREAM_PATH" "$DEST" || true
  echo "error: $DEST differs from CollectionViewClassifyMenu $SHA; run scripts/sync-harmonyos-classifymenu.sh" >&2
  exit 1
fi
rm -rf "$DEST"
cp -R "$STAGE/$UPSTREAM_PATH" "$DEST"
echo "Copied $UPSTREAM_PATH at CollectionViewClassifyMenu $SHA into $DEST"
