#!/bin/bash
# Usage: scripts/animation-tests.sh [static|dynamic] [PAG|PAGEnterprise] [simulator name]
#
# Runs Tests/run-animation-tests.rb: LottieSwift, GIF, PAG (or PAGEnterprise) and Rive installed with CocoaPods into a
# temporary project. Fixtures come from a CYLTabBarController checkout: ../CYLTabBarController, or CYL_FIXTURES_ROOT
# (CI checks it out inside the workspace). The log is build/animation-tests-<linkage>-<pag>.log.
set -euo pipefail
cd "$(dirname "$0")/.."
LINKAGE="${1:-static}"
PAG_SUBSPEC="${2:-PAG}"
mkdir -p build
FIXTURES="${CYL_FIXTURES_ROOT:-../CYLTabBarController}"
# Absolute: the test runner builds in a temporary folder.
FIXTURES=$(cd "$FIXTURES" 2>/dev/null && pwd || echo "$PWD/$FIXTURES")
export PAG_FIXTURE="${PAG_FIXTURE:-$FIXTURES/Example-Shared/PAGResources/tab-icons/tab_home.pag}"
# CYLTabBarController does not keep .pag files in git: like its scripts/fetch-animation-resources.py, download the
# pinned file (Tencent/libpag assets/refreshing.pag, Apache-2.0, Git LFS) and check its SHA-256.
PAG_SHA256=069f7cf1b54f5d7a896deffc6fafd622e3ed439550a64df2ec329e1b99a6d72f
if [[ ! -f "$PAG_FIXTURE" ]]; then
  PAG_FIXTURE="$PWD/build/fixtures/tab_home.pag"
  mkdir -p build/fixtures
  curl -fsSL -o "$PAG_FIXTURE" \
    "https://media.githubusercontent.com/media/Tencent/libpag/5faac72964023cc3ebc2f4395d78023d3a187ae4/assets/refreshing.pag"
fi
echo "$PAG_SHA256  $PAG_FIXTURE" | shasum -a 256 -c -
export PAG_FIXTURE
# A Rive file with a data-bound view model (Boolean, Color, Trigger Red), from rive-app/rive-ios's tests (MIT).
RIVE_BINDING_SHA256=47e0c2e7ef8c1b001bb14094d00c285d1bd856a2d6ae58eb87e6aa74b9c0b694
export RIVE_BINDING_FIXTURE="${RIVE_BINDING_FIXTURE:-$PWD/build/fixtures/data_binding_test.riv}"
if [[ ! -f "$RIVE_BINDING_FIXTURE" ]]; then
  mkdir -p "$(dirname "$RIVE_BINDING_FIXTURE")"
  curl -fsSL -o "$RIVE_BINDING_FIXTURE" \
    "https://raw.githubusercontent.com/rive-app/rive-ios/921d6ff62e1db177079146d61ff9ed517d15af50/Tests/Assets/data_binding_test.riv"
fi
echo "$RIVE_BINDING_SHA256  $RIVE_BINDING_FIXTURE" | shasum -a 256 -c -
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
