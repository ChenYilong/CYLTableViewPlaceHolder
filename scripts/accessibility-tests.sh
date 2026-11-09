#!/bin/sh
# Usage: scripts/accessibility-tests.sh [simulator name]
#
# Runs Tests/run-accessibility-tests.rb: XCUITests that read the accessibility tree VoiceOver reads, and Apple's
# accessibility audit (needs an iOS 17 or later simulator). The log is build/accessibility-tests.log.
set -eu
cd "$(dirname "$0")/.."
mkdir -p build
DESTINATION=$(scripts/ci-destination.sh "${1:-}" 17)
echo "Destination: $DESTINATION"
set +e
DESTINATION="$DESTINATION" ruby Tests/run-accessibility-tests.rb 2>&1 | tee build/accessibility-tests.log
STATUS=$?
set -e
grep -E 'Executed [0-9]+ tests|CYLAccessibilityAudit' build/accessibility-tests.log | sort -u | tail -20 || true
exit "$STATUS"
