#!/bin/bash
# Usage: scripts/device-tests.sh <device UDID> <Apple Developer team ID> [deployment target, default 12.0]
#
# Runs the unit suite (Tests/run-tests.rb) on a connected physical device, built at the given deployment target —
# the evidence for the podspec's iOS 12 minimum, which no simulator on a current Mac can run. Needs an Xcode that still
# targets iOS 12 (Xcode 16 or earlier: select it with DEVELOPER_DIR or xcode-select) and the device trusted, unlocked
# and in Developer Mode where applicable. List devices with: xcrun xctrace list devices
# The log is build/device-tests.log.
set -euo pipefail
cd "$(dirname "$0")/.."
UDID="${1:?usage: scripts/device-tests.sh <device UDID> <team ID> [deployment target]}"
TEAM="${2:?usage: scripts/device-tests.sh <device UDID> <team ID> [deployment target]}"
DEPLOYMENT="${3:-12.0}"
mkdir -p build
xcodebuild -version
set +e
DESTINATION="platform=iOS,id=$UDID" DEVELOPMENT_TEAM="$TEAM" TEST_DEPLOYMENT_TARGET="$DEPLOYMENT" \
  ruby Tests/run-tests.rb 2>&1 | tee build/device-tests.log
STATUS=$?
set -e
grep -E 'Executed [0-9]+ tests' build/device-tests.log | tail -1 || true
exit "$STATUS"
