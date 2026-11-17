#!/usr/bin/env bash
# Usage: scripts/sync-harmonyos-cylanimateditem.sh [--check]
#
# [EN] Copies CYLTabBarController's HarmonyOS CYLAnimatedItem module (CrossPlatform/harmonyos-cyltabbar/cylanimateditem,
#      ohpm package `cylanimateditem`, component `CYLAnimatedItemView`) at the commit the Cartfile pins into
#      CrossPlatform/harmonyos-cylplaceholder/cylanimateditem, and writes that commit into UPSTREAM_COMMIT there.
#      The module is not published to ohpm yet, so this repository takes it by commit, as CYLTabBarController's
#      docs/Animated-Item.md describes ("copy, or depend with `file:` on, the cylanimateditem folder at a pinned
#      commit"). It is copied rather than referenced with `file:` because Carthage/ is git-ignored: a `file:` path into
#      it would break a fresh clone. The copied files are upstream's, unchanged (MIT, ChenYilong, its own LICENSE);
#      never edit them: adapt this repository's code instead and re-run this script after the Cartfile moves.
#      --check only compares the copy with the pinned commit and exits 1 when they differ.
# [CN] 把 CYLTabBarController 鸿蒙端的 CYLAnimatedItem 模块（CrossPlatform/harmonyos-cyltabbar/cylanimateditem，ohpm 包
#      `cylanimateditem`，组件 `CYLAnimatedItemView`）按 Cartfile 固定的 commit 复制到 CrossPlatform/harmonyos-cylplaceholder/cylanimateditem，
#      并把该 commit 写入其中的 UPSTREAM_COMMIT。复制的文件保持上游原样（MIT，ChenYilong，自带 LICENSE），不要修改；--check 只比较。
set -euo pipefail
cd "$(dirname "$0")/.."
UPSTREAM_PATH=CrossPlatform/harmonyos-cyltabbar/cylanimateditem
DEST=CrossPlatform/harmonyos-cylplaceholder/cylanimateditem
CHECKOUT=$(bash scripts/cyltabbarcontroller-checkout.sh | tail -n 1)
SHA=$(git -C "$CHECKOUT" rev-parse HEAD)
git -C "$CHECKOUT" cat-file -e "$SHA:$UPSTREAM_PATH" 2>/dev/null || {
  echo "error: CYLTabBarController $SHA has no $UPSTREAM_PATH" >&2
  exit 1
}
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
# [EN] Only the committed files (no build outputs of a local checkout). [CN] 只取提交中的文件。
git -C "$CHECKOUT" archive "$SHA" "$UPSTREAM_PATH" | tar -x -C "$STAGE"
cat > "$STAGE/$UPSTREAM_PATH/UPSTREAM_COMMIT" <<EOF
# Copied by scripts/sync-harmonyos-cylanimateditem.sh. Do not edit this folder: re-run the script instead.
repository=https://github.com/ChenYilong/CYLTabBarController
commit=$SHA
path=$UPSTREAM_PATH
EOF
if [[ "${1:-}" == "--check" ]]; then
  if diff -r "$STAGE/$UPSTREAM_PATH" "$DEST" >/dev/null 2>&1; then
    echo "$DEST matches CYLTabBarController $SHA"
    exit 0
  fi
  diff -r "$STAGE/$UPSTREAM_PATH" "$DEST" || true
  echo "error: $DEST differs from CYLTabBarController $SHA; run scripts/sync-harmonyos-cylanimateditem.sh" >&2
  exit 1
fi
rm -rf "$DEST"
mkdir -p "$(dirname "$DEST")"
cp -R "$STAGE/$UPSTREAM_PATH" "$DEST"
echo "Copied $UPSTREAM_PATH at CYLTabBarController $SHA into $DEST"
