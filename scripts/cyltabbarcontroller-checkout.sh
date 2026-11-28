#!/usr/bin/env bash
# Usage: scripts/cyltabbarcontroller-checkout.sh
#
# Checks out the CYLTabBarController commit the Cartfile pins into Carthage/Checkouts/CYLTabBarController (Carthage's
# layout) and prints that folder. Used by scripts/cyltabbarcontroller-xcframework.sh (the framework the Xcode project
# and Tests/run-tests.rb link) and scripts/pod-lint.sh (`pod lib lint --include-podspecs`).
# CYL_TABBARCONTROLLER_URL overrides the repository. The last line is the absolute path; with Git Bash on Windows it is
# the mixed form `C:/...` (`cygpath -m`: bash and Java, so Gradle, both accept it; `/c/...` is invisible to Java).
set -euo pipefail
cd "$(dirname "$0")/.."
URL="${CYL_TABBARCONTROLLER_URL:-https://github.com/ChenYilong/CYLTabBarController.git}"
SHA=$(sed -nE 's/^github "ChenYilong\/CYLTabBarController" "([0-9a-f]{40})".*/\1/p' Cartfile)
[[ -n "$SHA" ]] || { echo "error: Cartfile pins no CYLTabBarController commit" >&2; exit 1; }
CHECKOUT=Carthage/Checkouts/CYLTabBarController
if [[ ! -d "$CHECKOUT/.git" ]]; then
  rm -rf "$CHECKOUT"
  git clone --quiet --filter=blob:none --no-checkout -c core.longpaths=true "$URL" "$CHECKOUT" >&2
fi
# Windows: CYLTabBarController has paths longer than 260 characters (the mini program and HarmonyOS folders); without
# long paths, checkout and `git show <sha>:<path>` fail with "Filename too long". No effect elsewhere.
git -C "$CHECKOUT" config core.longpaths true
git -C "$CHECKOUT" cat-file -e "$SHA^{commit}" 2>/dev/null || git -C "$CHECKOUT" fetch --quiet origin "$SHA" >&2
git -C "$CHECKOUT" checkout --quiet --force "$SHA" >&2
ABSOLUTE="$PWD/$CHECKOUT"
if command -v cygpath >/dev/null 2>&1; then ABSOLUTE=$(cygpath -m "$ABSOLUTE"); fi
echo "$ABSOLUTE"
