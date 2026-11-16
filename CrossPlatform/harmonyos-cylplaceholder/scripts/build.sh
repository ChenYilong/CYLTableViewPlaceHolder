#!/usr/bin/env bash
# Builds the HarmonyOS project with DevEco Studio's command-line tools (hvigor, ohpm, the bundled SDK and JBR).
# hvigor refuses a project path with non-ASCII characters (and resolves junctions and subst drives back to the real
# path), so a checkout under such a path (for example ".../文档/GitHub/...") is mirrored to an ASCII directory first
# (CYL_HARMONY_BUILD_DIR, default C:/cylbuild/harmonyos-cylplaceholder) and built there. A checkout at an ASCII path
# (for example C:/dev/CYLTableViewPlaceHolder, the one to open in DevEco Studio) is built in place.
#
#   scripts/build.sh                 the example HAP (entry) and the library HAR (cylplaceholder)
#   scripts/build.sh test            also the ohosTest HAP (when entry/src/ohosTest exists) and the host-run local unit tests (cylplaceholder/src/test)
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
DEVECO="${DEVECO_STUDIO:-/c/Program Files/Huawei/DevEco Studio}"
if printf '%s' "$HERE" | LC_ALL=C grep -q '[^ -~]'; then
  OUT="${CYL_HARMONY_BUILD_DIR:-/c/cylbuild/harmonyos-cylplaceholder}"
else
  OUT="$HERE"
fi
export DEVECO_SDK_HOME="$(cygpath -w "$DEVECO/sdk")"
export PATH="$DEVECO/jbr/bin:$DEVECO/tools/node:$DEVECO/tools/ohpm/bin:$DEVECO/tools/hvigor/bin:$PATH"
if [ "$OUT" != "$HERE" ]; then
  mkdir -p "$OUT"
  # Mirror the sources (not the build outputs) to the ASCII directory.
  powershell.exe -NoProfile -Command "robocopy '$(cygpath -w "$HERE")' '$(cygpath -w "$OUT")' /MIR /XD build .hvigor oh_modules .idea /NFL /NDL /NJH /NJS /NP | Out-Null; exit 0"
fi
cd "$OUT"
# Signing stays out of the repository: a build-profile.json5 with signingConfigs (made by DevEco Studio's automatic
# signing in the mirror) is kept at CYL_HARMONY_SIGNED_PROFILE (default ~/.cyl-harmony/build-profile.json5) and
# copied over the mirror's profile, so the HAP comes out signed and can be installed on the emulator.
SIGNED="${CYL_HARMONY_SIGNED_PROFILE:-$HOME/.cyl-harmony/build-profile.json5}"
# Only in the mirror: in place it would overwrite the tracked build-profile.json5.
if [ -f "$SIGNED" ] && [ "$OUT" != "$HERE" ]; then cp "$SIGNED" build-profile.json5; fi
ohpm install >/dev/null
hvigorw.bat assembleHap --mode module -p module=entry@default -p product=default --no-daemon
hvigorw.bat assembleHar --mode module -p module=cylplaceholder@default -p product=default --no-daemon
if [ "${1:-}" = "test" ]; then
  if [ -d entry/src/ohosTest ]; then
    hvigorw.bat --mode module -p module=entry@ohosTest -p isOhosTest=true -p buildMode=test assembleHap --no-daemon
  fi
  hvigorw.bat test -p module=cylplaceholder@default -p product=default --no-daemon
  tail -n 1 cylplaceholder/.test/default/intermediates/test/coverage_data/test_result.txt
fi
ls "$OUT"/entry/build/default/outputs/default/entry-default-*.hap
