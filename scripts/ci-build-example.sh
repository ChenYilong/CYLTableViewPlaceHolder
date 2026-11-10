#!/bin/bash
# Usage: scripts/ci-build-example.sh <demo folder>    e.g. . or Examples/Example-Scenarios
#
# Installs the demo's pods, builds it for the simulator (like CYLTabBarController's scripts/ci-build-example.sh),
# then installs and launches the app on a booted simulator and saves a screenshot to build/screenshots/<scheme>.png.
# A build without a screenshot fails: every CI build must show the example running (see instructions.md).
# Writes a row to build/summary.md for the job summary. SCREENSHOT_DELAY (seconds, default 8) waits for the first frame.
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT=$PWD
DEMO="${1:?usage: scripts/ci-build-example.sh <demo folder>}"
mkdir -p build/screenshots
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
export XCODE_XCCONFIG_FILE="$ROOT/scripts/pod-lint.xcconfig"
case "$DEMO" in
  .) SCHEME=CYLTableViewPlaceHolder ;;
  Examples/Example-objc-01) SCHEME=ExampleObjC01 ;;
  Examples/Example-objc-02) SCHEME=ExampleObjC02 ;;
  Examples/Example-SwiftUI) SCHEME=ExampleSwiftUI ;;
  Examples/Example-Scenarios) SCHEME=ExampleScenarios ;;
  *) echo "Unknown demo: $DEMO" >&2; exit 2 ;;
esac
cd "$DEMO"
pod install
WORKSPACE=$(find . -maxdepth 1 -name "*.xcworkspace" | head -1)
LOG="$ROOT/build/$SCHEME.log"
SCREENSHOT="$ROOT/build/screenshots/$SCHEME.png"
DERIVED_DATA=$(mktemp -d "${TMPDIR:-/tmp}/cyl-example.XXXXXX")
UDID=""
# Shut the simulator down (if one was booted) and remove the build products on exit.
trap '[[ -n "$UDID" ]] && xcrun simctl shutdown "$UDID" >/dev/null 2>&1; rm -rf "$DERIVED_DATA"' EXIT

# set -e does not apply inside a function called from an if, so every step returns on failure explicitly.
capture_screenshot() {
  local destination app bundle_id
  destination=$("$ROOT/scripts/ci-destination.sh") || return 1
  UDID=${destination##*id=}
  app=$(find "$DERIVED_DATA/Build/Products" -maxdepth 2 -name "*.app" ! -name "*-Runner.app" | head -1)
  [[ -n "$app" ]] || { echo "No .app found in $DERIVED_DATA/Build/Products" >&2; return 1; }
  bundle_id=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$app/Info.plist") || return 1
  echo "Launching $bundle_id from $app on $UDID"
  xcrun simctl bootstatus "$UDID" -b || return 1
  xcrun simctl install "$UDID" "$app" || return 1
  xcrun simctl launch "$UDID" "$bundle_id" || return 1
  sleep "${SCREENSHOT_DELAY:-8}"
  xcrun simctl io "$UDID" screenshot "$SCREENSHOT" || return 1
  [[ -s "$SCREENSHOT" ]]
}

build_status=0
xcodebuild build -workspace "$WORKSPACE" -scheme "$SCHEME" -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO 2>&1 | tee "$LOG" || build_status=$?

status=$build_status
shot="❌"
if [[ $build_status -eq 0 ]]; then
  if capture_screenshot; then
    shot="✅"
    echo "Screenshot: $SCREENSHOT"
  else
    echo "error: $SCHEME built but no screenshot of it running could be captured" >&2
    status=1
  fi
fi

result=$([[ $build_status -eq 0 ]] && echo "✅" || echo "❌")
echo "| $DEMO | $SCHEME | $result | $(grep -c ': warning: ' "$LOG" || true) | $shot |" > "$ROOT/build/summary.md"
exit "$status"
