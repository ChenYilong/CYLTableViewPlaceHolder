#!/usr/bin/env bash
# Usage: scripts/cyltabbarcontroller-xcframework.sh [simulator|all]
#
# Builds Carthage/Build/CYLTabBarController.xcframework and, for commits that split it out, CYLAnimatedItem.xcframework:
# the dependency the CYLTableViewPlaceHolderFramework target, the
# main example and Tests/run-tests.rb link (CYLPlaceholderView is a subclass of CYLTabBarController's CYLAnimatedItemView).
# Same layout as `carthage bootstrap --use-xcframeworks --platform iOS`, without needing Carthage: checks out the commit
# the Cartfile pins into Carthage/Checkouts/CYLTabBarController and archives its CYLTabBarController-Framework and CYLAnimatedItem
# schemes.
# "simulator" (CI test jobs) builds only the simulator slice; "all" (default) adds the device slice.
# CYL_TABBARCONTROLLER_URL overrides the repository; XCODE_XCCONFIG_FILE (e.g. scripts/pod-lint.xcconfig) applies.
set -euo pipefail
cd "$(dirname "$0")/.."
SLICES="${1:-all}"
SHA=$(sed -nE 's/^github "ChenYilong\/CYLTabBarController" "([0-9a-f]{40})".*/\1/p' Cartfile)
[[ -n "$SHA" ]] || { echo "error: Cartfile pins no CYLTabBarController commit" >&2; exit 1; }
OUTPUT=Carthage/Build/CYLTabBarController.xcframework
ITEM_OUTPUT=Carthage/Build/CYLAnimatedItem.xcframework
STAMP=Carthage/Build/.CYLTabBarController.$SLICES.$SHA
if [[ -f "$OUTPUT/Info.plist" && ( -f "$STAMP" || ( "$SLICES" == simulator && -f "Carthage/Build/.CYLTabBarController.all.$SHA" ) ) ]]; then
  echo "$OUTPUT ($SHA, up to date)"
  exit 0
fi
CHECKOUT=$(scripts/cyltabbarcontroller-checkout.sh)
# CYLTabBarController uses iOS 26 SDK APIs (e.g. UITabBarController.MinimizeBehavior), so it needs Xcode 26 or newer.
# The iOS 12 jobs select Xcode 16 for this repository's own build; build the dependency with the newest Xcode instead.
# Its Objective-C interface is what this repository imports, and a dynamic framework links across Xcode versions.
major=$(xcodebuild -version | sed -nE 's/^Xcode ([0-9]+).*/\1/p')
if [[ "${major:-0}" -lt 26 ]]; then
  newest=$(find /Applications -maxdepth 1 -name 'Xcode*.app' -print0 | while IFS= read -r -d '' app; do
      v=$(defaults read "$app/Contents/Info" CFBundleShortVersionString 2>/dev/null || echo 0)
      echo "$v $app"
    done | sort -V | tail -1 | cut -d' ' -f2-)
  [[ -n "$newest" ]] || { echo "error: CYLTabBarController needs Xcode 26 or newer" >&2; exit 1; }
  echo "Building CYLTabBarController with $newest (the selected Xcode is $major)"
  export DEVELOPER_DIR="$newest/Contents/Developer"
fi
WORK=$(mktemp -d "${TMPDIR:-/tmp}/cyltbc-xcframework.XXXXXX")
trap 'rm -rf "${WORK:?}"' EXIT
destinations=('generic/platform=iOS Simulator')
[[ "$SLICES" == simulator ]] || destinations+=('generic/platform=iOS')
# Since 720dc360 (2026-11-17) CYLTabBarController-Framework links a separate CYLAnimatedItem.framework (scheme
# CYLAnimatedItem, module CYLAnimatedItem, as in CocoaPods) instead of compiling CYLAnimatedItemView itself; its public
# CYLUtils.h then imports <CYLAnimatedItem/CYLAnimationKeys.h>. Build both xcframeworks when the scheme exists.
schemes_dir="$CHECKOUT/CYLTabBarController.xcodeproj/xcshareddata/xcschemes"
split=0
[[ -f "$schemes_dir/CYLAnimatedItem.xcscheme" ]] && split=1
tabbar_args=()
item_args=()
for destination in "${destinations[@]}"; do
  name=${destination##*=}
  name=${name// /-}
  xcodebuild archive -project "$CHECKOUT/CYLTabBarController.xcodeproj" -scheme CYLTabBarController-Framework \
    -destination "$destination" -archivePath "$WORK/$name.xcarchive" -derivedDataPath "$WORK/DerivedData" \
    SKIP_INSTALL=NO CODE_SIGNING_ALLOWED=NO BUILD_LIBRARY_FOR_DISTRIBUTION=NO -quiet
  framework="$WORK/$name.xcarchive/Products/Library/Frameworks/CYLTabBarController.framework"
  if [[ "$split" == 1 ]]; then
    xcodebuild archive -project "$CHECKOUT/CYLTabBarController.xcodeproj" -scheme CYLAnimatedItem \
      -destination "$destination" -archivePath "$WORK/$name-item.xcarchive" -derivedDataPath "$WORK/DerivedData" \
      SKIP_INSTALL=NO CODE_SIGNING_ALLOWED=NO BUILD_LIBRARY_FOR_DISTRIBUTION=NO -quiet
    item_args+=(-framework "$WORK/$name-item.xcarchive/Products/Library/Frameworks/CYLAnimatedItem.framework")
  else
    # Older layout: CYLTabBarController-Framework compiles CYLAnimatedItemView and the animation engine but marks their
    # headers as project headers, so the framework does not ship them (docs/Task-Log.md, TODO for upstream). Copy them
    # in; their quoted imports resolve inside Headers/, and the classes are in the binary.
    for header in "$CHECKOUT"/CYLTabBarController/CYLAnimatedItem/*.h "$CHECKOUT"/CYLTabBarController/CYLTabBarItemAnimation/*.h; do
      [[ -f "$framework/Headers/$(basename "$header")" ]] || cp "$header" "$framework/Headers/"
    done
  fi
  tabbar_args+=(-framework "$framework")
done
rm -rf "$OUTPUT" "$ITEM_OUTPUT" Carthage/Build/.CYLTabBarController.*
mkdir -p Carthage/Build
# No .swiftinterface: the same Xcode builds this framework and its users, which then load the binary .swiftmodule. Swift 6.2
# (Xcode 26.6) crashed rebuilding CYLTabBarController's module from its interface ("Redundant conformance requirements
# in signature <Self where Self : CYLBadgeTextDisplaying>", Demo . on d214229; docs/Task-Log.md).
xcodebuild -create-xcframework "${tabbar_args[@]}" -allow-internal-distribution -output "$OUTPUT"
if [[ "$split" == 1 ]]; then
  xcodebuild -create-xcframework "${item_args[@]}" -allow-internal-distribution -output "$ITEM_OUTPUT"
fi
touch "$STAMP"
echo "$OUTPUT ($SHA, $SLICES)"
