#!/bin/bash
# Usage: scripts/install-ios12-simulator.sh
#
# Installs Apple's iOS 12.4 simulator runtime (public download, Intel Macs only) if it is missing, creates an
# "iPhone 8 (iOS 12.4)" device, and prints its xcodebuild destination on the last line.
set -euo pipefail
RUNTIME=com.apple.CoreSimulator.SimRuntime.iOS-12-4
URL=https://devimages-cdn.apple.com/downloads/xcode/simulators/com.apple.pkg.iPhoneSimulatorSDK12_4-12.4.1.1568665771.dmg
if ! xcrun simctl list runtimes | grep -q "$RUNTIME"; then
  work=$(mktemp -d "${TMPDIR:-/tmp}/ios12.XXXXXX")
  echo "Downloading the iOS 12.4 simulator runtime…" >&2
  curl -fsSL -o "$work/runtime.dmg" "$URL"
  mount=$(hdiutil attach -nobrowse -readonly "$work/runtime.dmg" | awk -F'\t' '/\/Volumes\//{print $NF}' | tail -1)
  pkg=$(find "$mount" -maxdepth 2 -name '*.pkg' | head -1)
  echo "Installing $pkg" >&2
  sudo installer -pkg "$pkg" -target / >&2
  hdiutil detach "$mount" >/dev/null || true
  rm -rf "$work"
fi
xcrun simctl list runtimes >&2
NAME="iPhone 8 (iOS 12.4)"
ID=$(xcrun simctl list devices -j | python3 -c '
import json, sys
for runtime, devices in json.load(sys.stdin)["devices"].items():
    if runtime == sys.argv[1]:
        for device in devices:
            if device["name"] == sys.argv[2]:
                print(device["udid"]); sys.exit(0)
' "$RUNTIME" "$NAME" || true)
if [[ -z "$ID" ]]; then
  ID=$(xcrun simctl create "$NAME" com.apple.CoreSimulator.SimDeviceType.iPhone-8 "$RUNTIME")
fi
xcrun simctl boot "$ID" >&2 || true
xcrun simctl bootstatus "$ID" -b >&2 || true
echo "platform=iOS Simulator,id=$ID"
