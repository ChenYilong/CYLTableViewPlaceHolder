#!/usr/bin/env bash
# Installs the signed entry HAP on the running emulator (hdc), launches it and saves a screenshot, for the emulator
# rows (Q9-Q18) of docs/HarmonyOS.md "Full-marks standard". Build first with `scripts/build.sh` and a signed profile
# (see build.sh).
#
#   scripts/emulator-check.sh            install, launch, screenshot to docs/assets/harmonyos-launch.png
#   scripts/emulator-check.sh shot NAME  screenshot only, to docs/assets/harmonyos-NAME.png
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
DEVECO="${DEVECO_STUDIO:-/c/Program Files/Huawei/DevEco Studio}"
HDC="$DEVECO/sdk/default/openharmony/toolchains/hdc.exe"
OUT="${CYL_HARMONY_BUILD_DIR:-/c/cylbuild/harmonyos-cylplaceholder}"
ASSETS="$HERE/../../docs/assets"
BUNDLE=com.cyl.placeholder.harmonyos

shot() {
  "$HDC" shell snapshot_display -f /data/local/tmp/cyl.jpeg >/dev/null
  "$HDC" file recv /data/local/tmp/cyl.jpeg "$ASSETS/harmonyos-$1.jpeg" >/dev/null
  echo "saved docs/assets/harmonyos-$1.jpeg"
}

if [ "${1:-}" = "shot" ]; then
  shot "${2:?name}"
  exit 0
fi
"$HDC" list targets
HAP="$OUT/entry/build/default/outputs/default/entry-default-signed.hap"
[ -f "$HAP" ] || { echo "no signed HAP: set up signing (build.sh) and rebuild"; exit 1; }
"$HDC" install -r "$HAP"
"$HDC" shell aa start -a EntryAbility -b "$BUNDLE"
sleep 4
shot launch
