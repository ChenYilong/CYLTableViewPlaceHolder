#!/usr/bin/env bash
# Usage: scripts/classifymenu-checkout.sh
#
# Checks out the CollectionViewClassifyMenu commit pinned in android/classifymenu.commit (commit c0b183de of its feat/glass-backdrop
# branch, which contains its PR #37; never a branch or a version) into android/.classifymenu/CollectionViewClassifyMenu (a sparse, blobless clone: only the Android
# module android/merged/library) and prints that folder. android/settings.gradle.kts runs it when -PcylClassifyMenuDir is
# not given; only the example app (:merged-example) uses the module. CYL_CLASSIFYMENU_URL overrides the repository. The last
# line is the absolute path (with Git Bash on Windows the mixed form `C:/...`, which Java and Gradle accept).
set -euo pipefail
cd "$(dirname "$0")/.."
URL="${CYL_CLASSIFYMENU_URL:-https://github.com/ChenYilong/CollectionViewClassifyMenu.git}"
SHA=$(tr -d '[:space:]' < android/classifymenu.commit)
[[ "$SHA" =~ ^[0-9a-f]{40}$ ]] || { echo "error: android/classifymenu.commit has no 40-character commit" >&2; exit 1; }
CHECKOUT=android/.classifymenu/CollectionViewClassifyMenu
if [[ ! -d "$CHECKOUT/.git" ]]; then
  rm -rf "$CHECKOUT"
  mkdir -p "$(dirname "$CHECKOUT")"
  git clone --quiet --filter=blob:none --no-checkout -c core.longpaths=true "$URL" "$CHECKOUT" >&2
fi
git -C "$CHECKOUT" config core.longpaths true
git -C "$CHECKOUT" sparse-checkout set android/merged/library >&2
git -C "$CHECKOUT" cat-file -e "$SHA^{commit}" 2>/dev/null || git -C "$CHECKOUT" fetch --quiet origin "$SHA" >&2
git -C "$CHECKOUT" checkout --quiet --force "$SHA" >&2
ABSOLUTE="$PWD/$CHECKOUT"
if command -v cygpath >/dev/null 2>&1; then ABSOLUTE=$(cygpath -m "$ABSOLUTE"); fi
echo "$ABSOLUTE"
