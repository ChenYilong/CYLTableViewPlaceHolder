---
name: cyl-harmonyos-setup
description: Prepare DevEco Studio and the HarmonyOS emulator for CrossPlatform/harmonyos-cylplaceholder - IDE setup, emulator prerequisites, and the China region setting in country.region.xml that the emulator needs.
---

# HarmonyOS IDE and emulator setup

Use this skill before building, running or screenshotting the HarmonyOS port
(`CrossPlatform/harmonyos-cylplaceholder`), and whenever DevEco Studio's Device Manager shows no emulator images,
refuses to download one, or the emulator will not start. The project rules are in `instructions.md`, "HarmonyOS";
the status and score are in `docs/HarmonyOS.md`.

## 1. IDE preparation

- Install **DevEco Studio 6.0.1.251** (it bundles hvigor, ohpm, Node and the emulator) and the **HarmonyOS SDK
  6.0.1.112 (API 21)**. On Windows the SDK lives in `%LOCALAPPDATA%\Huawei\Sdk`, emulator images in
  `%LOCALAPPDATA%\Huawei\Sdk\system-image`, and deployed emulators in `%LOCALAPPDATA%\Huawei\Emulator\deployed`.
- Sign in to a **Huawei developer account** in DevEco Studio (needed for emulator images and automatic signing).
- Open `CrossPlatform/harmonyos-cylplaceholder`, run ohpm install, and set up automatic signing (File > Project
  Structure > Signing Configs) for the example HAP `entry`. Never commit signing material.
- Build with `CrossPlatform/harmonyos-cylplaceholder/scripts/build.sh`: in place from an ASCII path (the checkout
  now is), mirrored to an ASCII directory (`C:\cylbuild`) from a path with non-ASCII characters.
- **Opening it in DevEco Studio (Windows):** DevEco Studio / hvigor refuse a project path with non-ASCII characters
  ("00306003 Specification Limit Violation: Invalid project path"). The checkout used to sit under `文档`: OneDrive's
  Known Folder Move had created Documents / Pictures / Desktop with Chinese names (`文档` / `图片` / `桌面`; Explorer only
  showed them as "Documents" through `desktop.ini`). On 2026-11-17 they were renamed to `Documents` / `Pictures` /
  `Desktop`, with the known-folder registry entries (`User Shell Folders`, `Shell Folders`) updated and the git
  worktrees repaired, so the checkout is now at `C:\Users\Chen Yilong\OneDrive - AUT University\Documents\GitHub\
  CYLTableViewPlaceHolder` and DevEco Studio opens `CrossPlatform\harmonyos-cylplaceholder` there directly (it builds
  in place: `ohpm install`, Build > Build Hap(s), or `scripts/build.sh`). Keep project paths ASCII: a directory
  junction or a `subst` drive does not work around a non-ASCII path (hvigor resolves both back to the real path with
  Node's native `realpath`: "Invalid project path" / "Path not found"); use a clone at an ASCII path instead. Scripts
  with non-ASCII text for Windows PowerShell 5.1 must be saved as UTF-8 with a BOM, or they read `文档` as `鏂囨。`.
- **x86_64 emulator: the HAP does not install because its Rive and PAG libraries are arm64-only.** The Windows
  emulator is x86_64, but `@tencent/libpag` and `@ohos/rive` ship arm64-v8a native libraries only
  (`libs/arm64-v8a/*.so`, with `libc++_shared.so`), so the normal HAP does not install ("install parse native so
  failed", error 9568347). The fix comes from CYLTabBarController's HarmonyOS CYLAnimatedItem (882ece17,
  `cylanimateditem/README.md`, "x86_64 emulator"), so every app and library that depends on the item tests the same way:
  1. Build the `emulator` target, which leaves out every arm64-v8a library: `scripts/build.sh emulator` (output
     `entry/build/default/outputs/emulator/entry-emulator-unsigned.hap`; UI tests: build mode `emulatorTest`).
  2. Install it with `python3 cylanimateditem/tools/cyl_hap_x86_64.py install <app.hap>` (on Windows `py -3`): it reads
     the device ABIs (`hdc shell param get const.product.cpu.abilist`), leaves out what the device cannot load, and runs
     `hdc install -r`; `CYL_HAP_STRIP_LIBS=1` / `0` forces stripping. `scripts/emulator-check.sh` does steps 1-2 for
     you when the emulator HAP exists.
  3. Expect still images for Rive and PAG items: `CYLAnimatedItemEngines.canPlay` is false without arm64-v8a
     (`isSupportedOnDevice`, `unsupportedReason`). Views created outside `animationBuilder` check
     `isSupportedOnDevice(type)` first.
  4. Testable on x86_64: Lottie, SVGA, GIF, still images, placeholders, `showsImageWhenAnimationEnds` with Lottie or
     SVGA, layout, dark mode, accessibility, localization. Rive and PAG playback need an arm64 device or arm64 emulator
     with the `default` target. Never commit a stripped HAP.

## 2. Emulator prerequisites

All of these must hold, or Device Manager lists nothing or the emulator fails to boot:

1. **Region set to China** in DevEco Studio's `country.region.xml` (section 3). Outside the China region the
   emulator is not offered, even when the machine is physically elsewhere (for example New Zealand).
2. **Hardware virtualization on:** VT-x / AMD-V enabled in the BIOS / UEFI.
3. **Windows features on:** Hyper-V and Windows Hypervisor Platform (Control Panel > Turn Windows features on or
   off), then reboot. Check in PowerShell: `(Get-CimInstance Win32_ComputerSystem).HypervisorPresent` must be
   `True` (`VirtualizationFirmwareEnabled` reads `False` once a hypervisor is running; that is normal).
4. **Resources:** 16 GB RAM or more recommended, and several GB of free disk space for an image on the SDK drive.
5. **A listed device type:** `compatibleSdkVersion` stays at 5.1.0(18) so Device Manager offers phone emulator
   images; do not raise it without checking the Device Manager list.
6. **Signed in** to the Huawei account, with the HarmonyOS 6.0.1 phone image downloaded in Device Manager.

## 3. Region: set `country.region.xml` to China

The region file is in DevEco Studio's options folder:

- Windows: `%APPDATA%\Huawei\DevEcoStudio6.0\options\country.region.xml`
- macOS: `~/Library/Application Support/Huawei/DevEcoStudio6.0/options/country.region.xml`

Steps:

1. Quit DevEco Studio (it rewrites the file on exit).
2. Back up the current file (for example `country.region.xml.bak-NZ` when the region was New Zealand).
3. Change the region to China (`CN`):

   ```xml
   <application>
       <component name="CountryRegionSetting">
           <countryregion name="CN"/>
       </component>
   </application>
   ```

4. **Make sure the region file now says China:** it must contain `<countryregion name="CN"/>`. Check before
   restarting DevEco Studio:

   ```sh
   grep -n 'countryregion name="CN"' "$APPDATA/Huawei/DevEcoStudio6.0/options/country.region.xml"
   ```

   ```powershell
   Select-String -Path "$env:APPDATA\Huawei\DevEcoStudio6.0\options\country.region.xml" -Pattern 'countryregion name="CN"'
   ```

   No match means the change did not stick: repeat with DevEco Studio closed.
5. Start DevEco Studio, open Device Manager, and download / start the HarmonyOS 6.0.1 phone emulator.
6. **Check the region again before every emulator start.** A DevEco Studio that was open while the file was edited
   writes its own region back when it exits: on 2026-11-17 the file said `NZ` again although it had been set to
   `CN` the day before. Before starting the emulator (from Device Manager or from the command line, `Emulator.exe
   -hvd "<device>" -path "%LOCALAPPDATA%HuaweiEmulatordeployed"`), run the check in step 4; if it says `NZ`, quit
   DevEco Studio, set `CN` again, and only then start DevEco Studio and the emulator.

The region is first chosen in the IDE at first launch; editing the file is the reliable fix once the IDE has picked
another region (NZ on the owner's machine).

## 4. After setup

- Build with `scripts/build.sh`, install the `entry` HAP on the emulator, and follow `instructions.md`
  ("Screenshots of local builds and CI/CD") when recording results.
- Record emulator results in `docs/HarmonyOS.md`; pages verified only by compiling say "no emulator".

## 5. A hung or unopenable emulator: restart it

- An emulator that stays hung (hdc / adb commands time out, the screen does not respond) stays hung until it is
  restarted. **Tell the other sessions first** (`SendMessage`: "taking 127.0.0.1:5555, restarting it"), **then
  restart it** from the command line. Do not ask the owner whether to restart.
- An emulator that does not open (does not boot, not listed by `hdc list targets`): restarting is the first strategy,
  before any other fix. Check the region (section 3) before the new start.
- Restart only the hung emulator (end that device's `Emulator.exe`, then `Emulator -hvd "Mate 70 Pro" ...` again);
  leave the Android emulator running. Tell the other sessions "done" afterwards.
- Full rule: `instructions.md`, "Shared emulators: restart a hung emulator".
