#!/bin/sh
# Usage: scripts/ci-destination.sh [simulator name] [minimum iOS major]
#
# Prints an xcodebuild destination for an available iPhone simulator: the named one, or else the first iPhone of the
# newest iOS runtime at or above the minimum (default 17, needed by the accessibility audit). Adapted from
# CYLTabBarController's scripts/unit-tests.sh. Fails with the list of devices when none matches.
set -eu
NAME="${1:-}"
MINIMUM="${2:-17}"
ID=$(xcrun simctl list devices available -j | python3 -c '
import json, re, sys
name, minimum = sys.argv[1], int(sys.argv[2])
devices = json.load(sys.stdin)["devices"]
def version(runtime):
    match = re.search(r"iOS-(\d+)-(\d+)", runtime)
    return (int(match.group(1)), int(match.group(2))) if match else (0, 0)
for runtime in sorted(devices, key=version, reverse=True):
    if version(runtime)[0] < minimum:
        continue
    for device in devices[runtime]:
        if (name and device["name"] == name) or (not name and device["name"].startswith("iPhone")):
            print(device["udid"]); sys.exit(0)
sys.exit(1)' "$NAME" "$MINIMUM") || {
  echo "No iPhone simulator${NAME:+ named $NAME} with iOS $MINIMUM or later" >&2
  xcrun simctl list devices available >&2
  exit 1
}
echo "platform=iOS Simulator,id=$ID"
