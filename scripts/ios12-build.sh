#!/bin/bash
# Usage: scripts/ios12-build.sh
#
# Builds the CYLTableViewPlaceHolderFramework scheme (Core, as Carthage ships it) at the podspec's iOS 12.0 deployment
# target, with every use of a newer API not guarded by @available an error. Needs an Xcode that still targets iOS 12
# (Xcode 16 or earlier); Xcode 26/27 SDKs require iOS 15. Select it with DEVELOPER_DIR or xcode-select.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build
xcodebuild -version
DERIVED_DATA=$(mktemp -d "${TMPDIR:-/tmp}/cyl-ios12.XXXXXX")
trap 'rm -rf "$DERIVED_DATA"' EXIT
# $(inherited) is an Xcode build-setting macro, expanded by xcodebuild, not by the shell.
# shellcheck disable=SC2016
cflags='$(inherited) -Werror=unguarded-availability -Werror=unguarded-availability-new'
xcodebuild build -project CYLTableViewPlaceHolder.xcodeproj -scheme CYLTableViewPlaceHolderFramework \
  -destination 'generic/platform=iOS Simulator' -derivedDataPath "$DERIVED_DATA" CODE_SIGNING_ALLOWED=NO \
  IPHONEOS_DEPLOYMENT_TARGET=12.0 OTHER_CFLAGS="$cflags" 2>&1 | tee build/ios12-build.log
grep -q 'IPHONEOS_DEPLOYMENT_TARGET=12.0\|-target arm64-apple-ios12.0-simulator\|ios12.0' build/ios12-build.log
echo "Built at iOS 12.0 with unguarded-availability errors."
