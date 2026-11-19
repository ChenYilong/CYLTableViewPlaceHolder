#!/bin/bash
# Usage: scripts/ios12-build.sh
#
# Builds Core (the library sources, with the CYLAnimatedItem pod and its engine, as CocoaPods ships them) at the podspec's
# iOS 12.0 deployment target, with every use of a newer API not guarded by @available an error. Needs an Xcode that still
# targets iOS 12 (Xcode 16 or earlier); Xcode 26/27 SDKs require iOS 15. Select it with DEVELOPER_DIR or xcode-select.
# It builds Tests/run-tests.rb's project without running it: the framework target links CYLTabBarController.xcframework,
# which only Xcode 26 can build (iOS 26 SDK APIs) and Xcode 16 cannot import, while CocoaPods builds the CYLAnimatedItem
# pod with the selected Xcode.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build
xcodebuild -version
pod --version
TEST_DEPLOYMENT_TARGET=12.0 CYL_TEST_ACTION=build-for-testing \
  CYL_EXTRA_CFLAGS='-Werror=unguarded-availability' \
  ruby Tests/run-tests.rb 2>&1 | tee build/ios12-build.log
grep -q 'ios12.0' build/ios12-build.log
echo "Built at iOS 12.0 with unguarded-availability errors."
