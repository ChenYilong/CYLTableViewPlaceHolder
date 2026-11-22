#!/bin/bash
# Usage: scripts/ci-build-example.sh <demo folder>    e.g. . or Examples/Example-Scenarios
#
# Resolves CYLTabBarController's latest commit into the demo's Podfile, installs the demo's pods, builds it for the simulator (like CYLTabBarController's scripts/ci-build-example.sh),
# then installs and launches the app on a booted simulator and saves a screenshot to build/screenshots/<scheme>.png.
# A build without a screenshot fails: every CI build must show the example running (see instructions.md).
# ExampleObjC02 then runs its collection UI tests, which save step screenshots to build/screenshots too.
# Demos with an example bundle then run their localization self-check (-localizationCheck): every key of the example
# table must resolve in every core language and follow CYLPlaceholderLocalization.effectiveLanguage.
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
# The main example embeds the framework target, which links CYLTabBarController.xcframework (the Cartfile's commit).
if [[ "$DEMO" == . ]]; then
  "$ROOT/scripts/resolve-cyltabbarcontroller-commit.sh" --write "$ROOT/Cartfile"
  "$ROOT/scripts/cyltabbarcontroller-xcframework.sh" simulator
fi
cd "$DEMO"
# CYLTabBarController is always its newest commit on any branch (instructions.md, "Depending on CYLTabBarController").
if grep -Eq "pod '(CYLTabBarController|CYLAnimatedItem)'.*:commit" Podfile; then
  "$ROOT/scripts/resolve-cyltabbarcontroller-commit.sh" --write "$PWD/Podfile"
fi
# pod install clones CYLTabBarController; GitHub sometimes drops an anonymous clone on CI (2026-11-22): never prompt,
# retry up to 4 times.
export GIT_TERMINAL_PROMPT=0
for attempt in 1 2 3 4; do
  pod install && break
  [[ $attempt -lt 4 ]] || { echo "error: pod install failed after $attempt attempts" >&2; exit 1; }
  echo "pod install failed (attempt $attempt), retrying" >&2
  sleep $((attempt * 5))
done
WORKSPACE=$(find . -maxdepth 1 -name "*.xcworkspace" | head -1)
LOG="$ROOT/build/$SCHEME.log"
SCREENSHOT="$ROOT/build/screenshots/$SCHEME.png"
DERIVED_DATA=$(mktemp -d "${TMPDIR:-/tmp}/cyl-example.XXXXXX")
UDID=""
BUNDLE_ID=""
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
  BUNDLE_ID=$bundle_id
  echo "Launching $bundle_id from $app on $UDID"
  xcrun simctl bootstatus "$UDID" -b || return 1
  xcrun simctl install "$UDID" "$app" || return 1
  xcrun simctl launch "$UDID" "$bundle_id" || return 1
  sleep "${SCREENSHOT_DELAY:-8}"
  xcrun simctl io "$UDID" screenshot "$SCREENSHOT" || return 1
  [[ -s "$SCREENSHOT" ]]
}

# Demos with UI tests run after the launch screenshot; objc-02's also save step screenshots (CYL_SCREENSHOT_DIR).
# The SwiftUI tests guard MJRefresh#1628 (the header stays visible through a SwiftUI data update, real pull included);
# SwiftUIIntrospect 26.0.0 has no iOS 27 selector, so they need an iOS 26 or earlier simulator, as on the CI runner.
ui_tests_for_scheme() {
  case "$SCHEME" in
    ExampleObjC02) echo "ExampleObjC02UITests/CYLCollectionAnimationUITests ExampleObjC02UITests/CYLPagingUITests ExampleObjC02UITests/CYLSectionsUITests ExampleObjC02UITests/CYLLocalizationUITests" ;;
    ExampleSwiftUI) echo "ExampleSwiftUIUITests/CYLExampleSwiftUIUITests" ;;
  esac
}

run_ui_tests() {
  local only selection=()
  only=$(ui_tests_for_scheme)
  [[ -n "$only" ]] || return 0
  for name in $only; do selection+=("-only-testing:$name"); done
  echo "UI tests: $only on $UDID"
  TEST_RUNNER_CYL_SCREENSHOT_DIR="$ROOT/build/screenshots" xcodebuild test -workspace "$WORKSPACE" -scheme "$SCHEME" \
    -destination "id=$UDID" -derivedDataPath "$DERIVED_DATA" "${selection[@]}" 2>&1 | tee "$ROOT/build/$SCHEME-uitests.log"
}

# The example layer's localization self-check (the example's *Localization.swift): the app starts with
# -localizationCheck -exitAfterLocalizationCheck, prints CYL_LOCALIZATION_CHECK PASS <lookups> or FAIL with each
# problem, and exits. Only the demos with an example bundle have it.
run_localization_check() {
  local output
  case "$SCHEME" in
    CYLTableViewPlaceHolder|ExampleScenarios|ExampleObjC02) ;;
    *) return 0 ;;
  esac
  echo "Localization check: $BUNDLE_ID on $UDID"
  output=$(xcrun simctl launch --console-pty --terminate-running-process "$UDID" "$BUNDLE_ID" \
    -localizationCheck -exitAfterLocalizationCheck 2>&1) || true
  echo "$output" | grep "CYL_LOCALIZATION_CHECK" -A 40 | tee "$ROOT/build/$SCHEME-localization.log"
  grep -q "CYL_LOCALIZATION_CHECK PASS" "$ROOT/build/$SCHEME-localization.log"
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
    if ! run_ui_tests; then
      echo "error: $SCHEME UI tests failed; see build/$SCHEME-uitests.log" >&2
      status=1
    fi
    if ! run_localization_check; then
      echo "error: $SCHEME localization check failed; see build/$SCHEME-localization.log" >&2
      status=1
    fi
  else
    echo "error: $SCHEME built but no screenshot of it running could be captured" >&2
    status=1
  fi
fi

result=$([[ $build_status -eq 0 ]] && echo "✅" || echo "❌")
echo "| $DEMO | $SCHEME | $result | $(grep -c ': warning: ' "$LOG" || true) | $shot |" > "$ROOT/build/summary.md"
exit "$status"
