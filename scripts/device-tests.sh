#!/bin/bash
# Usage: scripts/device-tests.sh <device UDID> <Apple Developer team ID> [deployment target, default 15.0]
#
# Runs the unit suite (Tests/run-tests.rb) on a connected physical device, built at the given deployment target —
# real-device evidence at that target (15.0 is the lowest the Xcode 26/27 SDKs allow; iOS 12 is no longer buildable because
# the pinned CYLAnimatedItem pod needs iOS 13+). Needs the device trusted, unlocked and in Developer Mode where applicable. List devices with: xcrun xctrace list devices
# The log is build/device-tests.log.
set -euo pipefail
cd "$(dirname "$0")/.."
UDID="${1:?usage: scripts/device-tests.sh <device UDID> <team ID> [deployment target]}"
TEAM="${2:?usage: scripts/device-tests.sh <device UDID> <team ID> [deployment target]}"
DEPLOYMENT="${3:-15.0}"
mkdir -p build
xcodebuild -version
set +e
DESTINATION="platform=iOS,id=$UDID" DEVELOPMENT_TEAM="$TEAM" TEST_DEPLOYMENT_TARGET="$DEPLOYMENT" \
  ruby Tests/run-tests.rb 2>&1 | tee build/device-tests.log
STATUS=$?
set -e
grep -E 'Executed [0-9]+ tests' build/device-tests.log | tail -1 || true
exit "$STATUS"
