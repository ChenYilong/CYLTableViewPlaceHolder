#!/bin/bash
# Usage: scripts/install-ios15-simulator.sh
#
# Makes an iOS 15.x simulator available and prints its xcodebuild destination on the last line. Uses an installed iOS 15
# runtime, else downloads one with `xcodebuild -downloadPlatform iOS -buildVersion 15.5` (Apple's runtime download), then
# creates an "iPhone 13 (iOS 15)" device if none exists. Exits non-zero when no iOS 15 runtime can be had (the workflow
# then falls back to the newest simulator and warns).
set -euo pipefail
runtime_id() {
  xcrun simctl list runtimes -j | python3 -c '
import json, re, sys
best = None
for r in json.load(sys.stdin)["runtimes"]:
    m = re.match(r"(\d+)\.(\d+)", r.get("version", ""))
    if r.get("isAvailable") and r.get("platform", "iOS") == "iOS" and m and m.group(1) == "15":
        v = (int(m.group(1)), int(m.group(2)))
        if best is None or v > best[0]:
            best = (v, r["identifier"])
print(best[1] if best else "")'
}
RUNTIME=$(runtime_id)
if [ -z "$RUNTIME" ]; then
  echo "No iOS 15 simulator runtime installed; downloading iOS 15.5…" >&2
  xcodebuild -downloadPlatform iOS -buildVersion 15.5 >&2 || true
  RUNTIME=$(runtime_id)
fi
[ -n "$RUNTIME" ] || { echo "iOS 15 simulator runtime unavailable" >&2; xcrun simctl list runtimes >&2; exit 1; }
ID=$(xcrun simctl list devices available -j | python3 -c '
import json, sys
for d in json.load(sys.stdin)["devices"].get(sys.argv[1], []):
    if d["name"].startswith("iPhone"):
        print(d["udid"]); break' "$RUNTIME")
if [ -z "$ID" ]; then
  TYPE=$(xcrun simctl list devicetypes -j | python3 -c '
import json, sys
types = [t["identifier"] for t in json.load(sys.stdin)["devicetypes"] if t["name"] in ("iPhone 13", "iPhone 12", "iPhone 11")]
print(types[0] if types else "")')
  [ -n "$TYPE" ] || TYPE=com.apple.CoreSimulator.SimDeviceType.iPhone-13
  ID=$(xcrun simctl create "iPhone (iOS 15)" "$TYPE" "$RUNTIME")
fi
xcrun simctl boot "$ID" >&2 || true
xcrun simctl bootstatus "$ID" -b >&2 || true
echo "platform=iOS Simulator,id=$ID"
