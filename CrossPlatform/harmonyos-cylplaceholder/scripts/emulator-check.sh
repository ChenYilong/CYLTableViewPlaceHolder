#!/usr/bin/env bash
# Installs the entry HAP (unsigned is fine on the emulator) on the running emulator (hdc), launches it and saves a screenshot, for the emulator
# rows (Q9-Q18) of docs/HarmonyOS.md "Full-marks standard". Build first with `scripts/build.sh` and a signed profile
# (see build.sh).
#
# x86_64 emulator (cylanimateditem/README.md, "x86_64 emulator"): @ohos/rive and @tencent/libpag ship arm64-v8a native
# libraries only. The HAP of the "emulator" target (scripts/build.sh emulator) has none and is used when present on a
# device without arm64-v8a; any HAP is installed through CYLTabBarController's cylanimateditem/tools/cyl_hap_x86_64.py,
# which asks the device for its ABIs and leaves out the libraries it cannot load (CYL_HAP_STRIP_LIBS=1 / 0 forces it).
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
EMULATOR_HAP=$(ls "$OUT"/entry/build/default/outputs/emulator/entry-emulator-*.hap 2>/dev/null | head -1 || true)
case "$ABIS" in *arm64-v8a*) ;; *) [ -n "$EMULATOR_HAP" ] && HAP="$EMULATOR_HAP" ;; esac
# The emulator takes the unsigned HAP (no signing needed for emulator tests); a signed one is used when present. The
# tool finds DevEco Studio's hdc itself.
# On Windows hdc reads a forward-slash "C:/..." path as relative: hand the tool a native path.
TOOL="$HERE/cylanimateditem/tools/cyl_hap_x86_64.py"
if command -v cygpath >/dev/null 2>&1; then HAP="$(cygpath -w "$HAP")"; TOOL="$(cygpath -w "$TOOL")"; fi
py -3 "$TOOL" install "$HAP" 2>/dev/null || python3 "$TOOL" install "$HAP"
"$HDC" shell aa start -a EntryAbility -b "$BUNDLE"
sleep 4
shot launch
