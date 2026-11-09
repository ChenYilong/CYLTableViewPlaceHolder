#!/bin/sh
# Usage: scripts/animation-tests.sh [static|dynamic] [PAG|PAGEnterprise] [simulator name]
#
# Runs Tests/run-animation-tests.rb: LottieSwift, GIF, PAG (or PAGEnterprise) and Rive installed with CocoaPods into a
# temporary project. Fixtures come from a CYLTabBarController checkout: ../CYLTabBarController, or CYL_FIXTURES_ROOT
# (CI checks it out inside the workspace). The log is build/animation-tests-<linkage>-<pag>.log.
set -eu
cd "$(dirname "$0")/.."
LINKAGE="${1:-static}"
PAG_SUBSPEC="${2:-PAG}"
mkdir -p build
FIXTURES="${CYL_FIXTURES_ROOT:-../CYLTabBarController}"
export PAG_FIXTURE="${PAG_FIXTURE:-$FIXTURES/Example-Shared/PAGResources/tab-icons/tab_home.pag}"
export RIVE_FIXTURE="${RIVE_FIXTURE:-$FIXTURES/Example-SwiftUI-Rive/AnimatedApp/RiveAssets/icons.riv}"
export RIVE_TRIGGER_FIXTURE="${RIVE_TRIGGER_FIXTURE:-$FIXTURES/Example-SwiftUI-Rive/AnimatedApp/RiveAssets/check.riv}"
export RIVE_LINEAR_FIXTURE="${RIVE_LINEAR_FIXTURE:-$FIXTURES/Example-SwiftUI-Rive/AnimatedApp/RiveAssets/button.riv}"
# CocoaPods fails on non-UTF-8 locales.
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
DESTINATION=$(scripts/ci-destination.sh "${3:-}" 15)
echo "Destination: $DESTINATION"
LOG="build/animation-tests-$LINKAGE-$PAG_SUBSPEC.log"
set +e
LINKAGE="$LINKAGE" PAG_SUBSPEC="$PAG_SUBSPEC" DESTINATION="$DESTINATION" ruby Tests/run-animation-tests.rb 2>&1 | tee "$LOG"
STATUS=$?
set -e
grep -E 'Executed [0-9]+ tests' "$LOG" | tail -1 || true
exit "$STATUS"
