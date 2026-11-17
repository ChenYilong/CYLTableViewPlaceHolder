#!/usr/bin/env bash
# Usage: scripts/cyltabbarcontroller-xcframework.sh [simulator|all]
#
# Builds Carthage/Build/CYLTabBarController.xcframework, the dependency the CYLTableViewPlaceHolderFramework target, the
# main example and Tests/run-tests.rb link (CYLPlaceholderView is a subclass of CYLTabBarController's CYLAnimatedItemView).
# Same layout as `carthage bootstrap --use-xcframeworks --platform iOS`, without needing Carthage: checks out the commit
# the Cartfile pins into Carthage/Checkouts/CYLTabBarController and archives its CYLTabBarController-Framework scheme.
# "simulator" (CI test jobs) builds only the simulator slice; "all" (default) adds the device slice.
# CYL_TABBARCONTROLLER_URL overrides the repository; XCODE_XCCONFIG_FILE (e.g. scripts/pod-lint.xcconfig) applies.
set -euo pipefail
cd "$(dirname "$0")/.."
SLICES="${1:-all}"
SHA=$(sed -nE 's/^github "ChenYilong\/CYLTabBarController" "([0-9a-f]{40})".*/\1/p' Cartfile)
[[ -n "$SHA" ]] || { echo "error: Cartfile pins no CYLTabBarController commit" >&2; exit 1; }
OUTPUT=Carthage/Build/CYLTabBarController.xcframework
STAMP=Carthage/Build/.CYLTabBarController.$SLICES.$SHA
if [[ -f "$OUTPUT/Info.plist" && ( -f "$STAMP" || ( "$SLICES" == simulator && -f "Carthage/Build/.CYLTabBarController.all.$SHA" ) ) ]]; then
  echo "$OUTPUT ($SHA, up to date)"
  exit 0
fi
CHECKOUT=$(scripts/cyltabbarcontroller-checkout.sh)
WORK=$(mktemp -d "${TMPDIR:-/tmp}/cyltbc-xcframework.XXXXXX")
trap 'rm -rf "${WORK:?}"' EXIT
destinations=('generic/platform=iOS Simulator')
[[ "$SLICES" == simulator ]] || destinations+=('generic/platform=iOS')
args=()
for destination in "${destinations[@]}"; do
  name=${destination##*=}
  name=${name// /-}
  xcodebuild archive -project "$CHECKOUT/CYLTabBarController.xcodeproj" -scheme CYLTabBarController-Framework \
    -destination "$destination" -archivePath "$WORK/$name.xcarchive" -derivedDataPath "$WORK/DerivedData" \
    SKIP_INSTALL=NO CODE_SIGNING_ALLOWED=NO -quiet
  args+=(-framework "$WORK/$name.xcarchive/Products/Library/Frameworks/CYLTabBarController.framework")
done
rm -rf "$OUTPUT" Carthage/Build/.CYLTabBarController.*
mkdir -p Carthage/Build
xcodebuild -create-xcframework "${args[@]}" -output "$OUTPUT"
touch "$STAMP"
echo "$OUTPUT ($SHA, $SLICES)"
