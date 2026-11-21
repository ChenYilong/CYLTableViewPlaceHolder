#!/usr/bin/env bash
# Installs the entry HAP (unsigned is fine on the emulator) on the running emulator (hdc), launches it and saves a screenshot, for the emulator
# rows (Q9-Q18) of docs/HarmonyOS.md "Full-marks standard". Build first with `scripts/build.sh` and a signed profile
# (see build.sh).
#
# x86_64 emulator: @ohos/rive and @tencent/libpag ship arm64-v8a native libraries only, so the normal HAP does not
# install there ("install parse native so failed"). When the device's ABI list (const.product.cpu.abilist) has no
# arm64-v8a, or CYL_HAP_STRIP_LIBS=1, this script installs a copy without libs/ (scripts/strip-hap-native-libs.py);
# Rive and PAG files then show their still images. Set CYL_HAP_STRIP_LIBS=0 to install the HAP as built.
#
#   scripts/emulator-check.sh            install, launch, screenshot to docs/assets/harmonyos-launch.png
#   scripts/emulator-check.sh shot NAME  screenshot only, to docs/assets/harmonyos-NAME.png
#   scripts/emulator-check.sh uitest     run the UI tests (entry/src/ohosTest) and copy their screenshots
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

if [ "${1:-}" = "uitest" ]; then
  # The UI test suite (entry/src/ohosTest, built by `scripts/build.sh test`): installs the app and the test HAP, runs
  # the tests (launch, every tab, a scenario, the playback controls, Publish) and copies their screenshots.
  "$HDC" install -r "$(ls "$OUT"/entry/build/default/outputs/default/entry-default-*.hap | head -1)"
  "$HDC" install -r "$(ls "$OUT"/entry/build/default/outputs/ohosTest/entry-ohosTest-*.hap | head -1)"
  "$HDC" shell aa test -b "$BUNDLE" -m entry_test -s unittest OpenHarmonyTestRunner -s timeout 60000
  # The tests write to the app context's files directory: entry's or entry_test's, depending on the runner.
  for FILES in "/data/app/el2/100/base/$BUNDLE/haps/entry/files" "/data/app/el2/100/base/$BUNDLE/haps/entry_test/files"; do
    for f in $("$HDC" shell ls "$FILES" 2>/dev/null | tr -d '\r' | grep '^harmonyos-.*png$'); do
      "$HDC" file recv "$FILES/$f" "$ASSETS/$f" >/dev/null && echo "saved docs/assets/$f"
    done
  done
  exit 0
fi
if [ "${1:-}" = "shot" ]; then
  shot "${2:?name}"
  exit 0
fi
"$HDC" list targets
HAP=$(ls "$OUT"/entry/build/default/outputs/default/entry-default-signed.hap 2>/dev/null || ls "$OUT"/entry/build/default/outputs/default/entry-default-unsigned.hap)
ABIS=$("$HDC" shell param get const.product.cpu.abilist 2>/dev/null | tr -d '\r' || true)
STRIP="${CYL_HAP_STRIP_LIBS:-}"
if [ -z "$STRIP" ]; then
  case "$ABIS" in *arm64-v8a*) STRIP=0 ;; *) STRIP=1 ;; esac
fi
if [ "$STRIP" = "1" ]; then
  # arm64-only Rive and PAG libraries: install a copy without libs/ (see the header).
  STRIPPED="${TMPDIR:-/tmp}/entry-default-no-native-libs.hap"
  py -3 "$HERE/scripts/strip-hap-native-libs.py" "$HAP" "$STRIPPED" 2>/dev/null || python3 "$HERE/scripts/strip-hap-native-libs.py" "$HAP" "$STRIPPED"
  echo "device ABIs '${ABIS}': installing without arm64-only native libraries (Rive / PAG show still images)"
  HAP="$STRIPPED"
fi
# The emulator takes the unsigned HAP (no signing needed for emulator tests); a signed one is used when present.
"$HDC" install -r "$HAP"
"$HDC" shell aa start -a EntryAbility -b "$BUNDLE"
sleep 4
shot launch
