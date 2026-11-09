#!/bin/bash
# Usage: scripts/framework-build.sh
#
# Builds and analyzes the CYLTableViewPlaceHolderFramework scheme (the target Carthage builds), as CYLTabBarController's
# "Framework build and analyze" job does. Fails on a warning in the placeholder's own sources
# (CYLTableViewPlaceHolder/CYLTableViewPlaceHolder, CYLPlaceholderAnimation); CYLRefresh warnings are reported only
# (pre-existing iOS 13 deprecations, tracked in docs/issue-progress.md). Logs are in build/.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build
export XCODE_XCCONFIG_FILE="$PWD/scripts/pod-lint.xcconfig"
DERIVED_DATA=$(mktemp -d "${TMPDIR:-/tmp}/cyl-framework.XXXXXX")
trap 'rm -rf "$DERIVED_DATA"' EXIT
common=(-project CYLTableViewPlaceHolder.xcodeproj -scheme CYLTableViewPlaceHolderFramework
        -destination 'generic/platform=iOS Simulator' -derivedDataPath "$DERIVED_DATA" CODE_SIGNING_ALLOWED=NO)
xcodebuild build "${common[@]}" 2>&1 | tee build/framework.log
xcodebuild analyze "${common[@]}" CLANG_ANALYZER_OUTPUT=plist-html \
  CLANG_ANALYZER_OUTPUT_DIR="$PWD/build/analyzer" 2>&1 | tee build/analyze.log
warnings() {
  grep -h '\.[mh]:[0-9]*:[0-9]*: warning: ' build/framework.log build/analyze.log | grep "$1" | sort -u || true
}
own=$(warnings 'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/\|CYLPlaceholderAnimation/')
refresh=$(warnings 'CYLRefresh/')
echo "Placeholder source warnings: $(printf '%s' "$own" | grep -c . || true)"
echo "CYLRefresh source warnings (reported only): $(printf '%s' "$refresh" | grep -c . || true)"
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  {
    echo "### Framework warnings"
    echo
    echo '```'
    printf '%s\n%s\n' "$own" "$refresh" | sed "s|$PWD/||" | grep . | head -200 || true
    echo '```'
  } >> "$GITHUB_STEP_SUMMARY"
fi
if [[ -n "$own" ]]; then
  echo "$own"
  exit 1
fi
