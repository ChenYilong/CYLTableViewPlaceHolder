#!/bin/bash
# Usage: scripts/ios15-build.sh
#
# Builds Core (the library sources, with the CYLAnimatedItem pod and its engine, as CocoaPods ships them) at the iOS 15.0
# deployment target, with every use of a newer API not guarded by @available an error. iOS 15 is the lowest deployment
# target the Xcode 26/27 SDKs allow, so the newest Xcode builds it; select another with DEVELOPER_DIR or xcode-select.
# (iOS 12 is no longer a CI target: the pinned CYLAnimatedItem pod uses UITabBarItemAppearance, iOS 13+; 2026-11-20.)
# It builds Tests/run-tests.rb's project without running it (generic simulator destination); the tests run in
# .github/workflows/ios15-runtime.yml.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build
xcodebuild -version
pod --version
TEST_DEPLOYMENT_TARGET=15.0 CYL_TEST_ACTION=build-for-testing \
  CYL_EXTRA_CFLAGS='-Werror=unguarded-availability' \
  ruby Tests/run-tests.rb 2>&1 | tee build/ios15-build.log
grep -q 'ios15.0' build/ios15-build.log
echo "Built at iOS 15.0 with unguarded-availability errors."
