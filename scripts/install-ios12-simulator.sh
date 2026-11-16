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
  # The package targets a path on the read-only system volume; copy its runtime bundle instead, as `xcodes` does.
  pkgutil --expand-full "$pkg" "$work/expanded"
  hdiutil detach "$mount" >/dev/null || true
  simruntime=$(find "$work/expanded" -maxdepth 6 -name '*.simruntime' -type d | head -1)
  # In this package the payload itself is the runtime bundle (Payload/Contents/MacOS/iOS 12.4).
  if [[ -z "$simruntime" && -d "$work/expanded/Payload/Contents" ]]; then
    simruntime="$work/expanded/Payload"
  fi
  if [[ -z "$simruntime" ]]; then
    payload=$(find "$work/expanded" -maxdepth 3 -name Payload -type d | head -1)
    echo "No .simruntime in the package; payload: $payload" >&2
    find "$work/expanded" -maxdepth 4 | head -40 >&2
    exit 1
  fi
  sudo mkdir -p /Library/Developer/CoreSimulator/Profiles/Runtimes
  sudo cp -R "$simruntime" "/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 12.4.simruntime"
  sudo killall -9 com.apple.CoreSimulator.CoreSimulatorService 2>/dev/null || true
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
