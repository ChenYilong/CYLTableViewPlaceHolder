#!/bin/sh
# Usage: scripts/unit-tests.sh [simulator name]
#
# Runs Tests/run-tests.rb (placeholder, refresh, built-in GIF and the shared animation module) on an iOS simulator.
# Without a name, the first iPhone of the newest runtime. The log is build/unit-tests.log.
set -eu
cd "$(dirname "$0")/.."
mkdir -p build
DESTINATION=$(scripts/ci-destination.sh "${1:-}" 15)
echo "Destination: $DESTINATION"
xcodebuild -version
set +e
DESTINATION="$DESTINATION" ruby Tests/run-tests.rb 2>&1 | tee build/unit-tests.log
STATUS=$?
set -e
grep -E 'Executed [0-9]+ tests' build/unit-tests.log | tail -1 || true
exit "$STATUS"
