#!/bin/bash
# Usage: scripts/ci-build-example.sh <demo folder>    e.g. . or Examples/Example-objc-01
#
# Installs the demo's pods and builds it for the simulator, like CYLTabBarController's scripts/ci-build-example.sh.
# Writes a row to build/summary.md for the job summary.
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT=$PWD
DEMO="${1:?usage: scripts/ci-build-example.sh <demo folder>}"
mkdir -p build
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
export XCODE_XCCONFIG_FILE="$ROOT/scripts/pod-lint.xcconfig"
case "$DEMO" in
  .) SCHEME=CYLTableViewPlaceHolder ;;
  Examples/Example-objc-01) SCHEME=ExampleObjC01 ;;
  Examples/Example-objc-02) SCHEME=ExampleObjC02 ;;
  Examples/Example-SwiftUI) SCHEME=ExampleSwiftUI ;;
  *) echo "Unknown demo: $DEMO" >&2; exit 2 ;;
esac
cd "$DEMO"
pod install
WORKSPACE=$(find . -maxdepth 1 -name "*.xcworkspace" | head -1)
LOG="$ROOT/build/$(basename "$ROOT/$DEMO").log"
DERIVED_DATA=$(mktemp -d "${TMPDIR:-/tmp}/cyl-example.XXXXXX")
trap 'rm -rf "$DERIVED_DATA"' EXIT
status=0
xcodebuild build -workspace "$WORKSPACE" -scheme "$SCHEME" -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO 2>&1 | tee "$LOG" || status=$?
result=$([[ $status -eq 0 ]] && echo "✅" || echo "❌")
echo "| $DEMO | $SCHEME | $result | $(grep -c ': warning: ' "$LOG" || true) |" > "$ROOT/build/summary.md"
exit "$status"
