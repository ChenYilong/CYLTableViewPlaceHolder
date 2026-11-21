#!/usr/bin/env python3
"""
Copy a HAP without its native libraries, so it installs on the x86_64 HarmonyOS emulator.

The example `entry` depends on @ohos/rive and @tencent/libpag, which ship native libraries (`libs/arm64-v8a/*.so`)
for arm64-v8a only. The x86_64 emulator (DevEco Studio's emulator on Windows and Intel hosts) refuses such a HAP:
"install parse native so failed". This script writes a copy of the HAP with every `libs/` entry removed. The copy
installs and runs on the x86_64 emulator; the example then registers no Rive engine (cylRiveIsSupported() checks the
device ABI) and PAG cannot load, so Rive and PAG files show their still images. Use the unmodified HAP on arm64
devices and arm64 emulators.

Usage:
    python3 scripts/strip-hap-native-libs.py <input.hap> <output.hap>
"""
import sys
import zipfile


def strip_native_libs(source: str, target: str) -> int:
    """
    Write `target` as `source` without its `libs/` entries; return how many entries were removed.
    """
    removed = 0
    with zipfile.ZipFile(source) as src, zipfile.ZipFile(target, "w", zipfile.ZIP_DEFLATED) as dst:
        for info in src.infolist():
            if info.filename.startswith("libs/"):
                removed += 1
                continue
            dst.writestr(info, src.read(info.filename))
    return removed


def main() -> int:
    """
    Command line entry point.
    """
    if len(sys.argv) != 3:
        print(__doc__.strip())
        return 2
    removed = strip_native_libs(sys.argv[1], sys.argv[2])
    print(f"wrote {sys.argv[2]} without {removed} native library entries (libs/)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
