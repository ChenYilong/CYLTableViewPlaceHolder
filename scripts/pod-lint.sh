#!/bin/bash
# Usage: scripts/pod-lint.sh lib [extra pod options]   pod lib lint, every subspec
#        scripts/pod-lint.sh spec                       pod spec lint (needs the tag pushed)
#        scripts/pod-lint.sh check-tag <tag>            exit 1 unless <tag> equals s.version
#        scripts/pod-lint.sh push                       pod trunk push (needs COCOAPODS_TRUNK_TOKEN)
#        scripts/pod-lint.sh xcframework                build/CYLTableViewPlaceHolder.xcframework.zip with Carthage
#
# Adapted from CYLTabBarController's scripts/pod-lint.sh. Xcode 27 SDKs require iOS 15, so validation builds use
# scripts/pod-lint.xcconfig; the podspec's iOS 12 minimum is unchanged. `--allow-warnings` covers upstream libpag
# warnings (license file, OpenGL ES deprecations, umbrella header).
set -euo pipefail
cd "$(dirname "$0")/.."
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
export XCODE_XCCONFIG_FILE="$PWD/scripts/pod-lint.xcconfig"
PODSPEC=CYLTableViewPlaceHolder.podspec

version() {
  ruby -e 'print File.read(ARGV[0])[/s\.version\s*=\s*"([^"]+)"/, 1]' "$PODSPEC"
}

command="${1:-lib}"
shift || true
case "$command" in
  lib)
    # Core depends on the CYLAnimatedItem pod (CYLTabBarController repository, not on the trunk yet), linted from the
    # commit the Cartfile pins.
    tabbar=$(scripts/cyltabbarcontroller-checkout.sh)
    pod lib lint "$PODSPEC" --allow-warnings --platforms=ios --skip-tests --include-podspecs="$tabbar/CYLAnimatedItem.podspec" "$@"
    ;;
  spec)
    pod spec lint "$PODSPEC" --allow-warnings --platforms=ios --skip-tests "$@"
    ;;
  check-tag)
    tag="${1:?usage: scripts/pod-lint.sh check-tag <tag>}"
    current=$(version)
    echo "Tag $tag, podspec $current"
    [[ "$tag" == "$current" ]]
    ;;
  push)
    # The CYLAnimatedItem pod is not on the trunk yet (docs/Task-Log.md): a push fails until CYLTabBarController
    # publishes it and the podspec depends on that version.
    : "${COCOAPODS_TRUNK_TOKEN:?COCOAPODS_TRUNK_TOKEN is not set}"
    pod trunk push "$PODSPEC" --allow-warnings --skip-tests "$@"
    ;;
  xcframework)
    mkdir -p build
    # Build from a clean copy so local Carthage/Build output and AppleDouble files do not leak into the archive.
    work=$(mktemp -d "${TMPDIR:-/tmp}/cyl-xcframework.XXXXXX")
    trap 'rm -rf "$work"' EXIT
    git ls-files -z | grep -zv '/\._\|^\._' | xargs -0 -I{} rsync -R "{}" "$work/" 2>/dev/null || git archive HEAD | tar -x -C "$work"
    # The framework target links CYLTabBarController.xcframework. `carthage build` of that dependency fails: Carthage
    # lists every Xcode project in its checkout, and CYLTabBarController's Flutter example needs generated Swift
    # packages (docs/Task-Log.md, TODO). So it is built by scripts/cyltabbarcontroller-xcframework.sh, and Carthage
    # builds only this repository (no Cartfile in the clean copy).
    scripts/cyltabbarcontroller-xcframework.sh all
    mkdir -p "$work/Carthage/Build"
    cp -R Carthage/Build/CYLTabBarController.xcframework "$work/Carthage/Build/"
    # Newer commits split CYLAnimatedItem out of CYLTabBarController-Framework (the framework target links both).
    [[ ! -d Carthage/Build/CYLAnimatedItem.xcframework ]] || cp -R Carthage/Build/CYLAnimatedItem.xcframework "$work/Carthage/Build/"
    rm -f "$work/Cartfile" "$work/Cartfile.resolved"
    (cd "$work" && carthage build --no-skip-current --use-xcframeworks --platform iOS)
    test -f "$work/Carthage/Build/CYLTableViewPlaceHolder.xcframework/Info.plist"
    rm -f build/CYLTableViewPlaceHolder.xcframework.zip
    (cd "$work/Carthage/Build" && zip -qry - CYLTableViewPlaceHolder.xcframework) > build/CYLTableViewPlaceHolder.xcframework.zip
    echo "build/CYLTableViewPlaceHolder.xcframework.zip ($(version))"
    ;;
  *)
    echo "Unknown command: $command" >&2
    exit 2
    ;;
esac
