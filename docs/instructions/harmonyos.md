# HarmonyOS scenario (`harmonyos`)

Full text of the `harmonyos` rules (the HarmonyOS port, DevEco Studio, the emulator, arm64-only Rive and PAG), moved verbatim from `instructions.md` and `AGENTS.md` on 2026-11-22 (owner's
rule: instruction files by tag, at most 200 lines each). Summaries: [instructions.md](../../instructions.md) and
[AGENTS.md](../../AGENTS.md), heading "Tag: HarmonyOS scenario". English only.

## HarmonyOS (owner's rule, 2026-11-16)

- **Version:** HarmonyOS 6.0.1 (API 21, Release); HarmonyOS SDK 6.0.1.112, `compileSdkVersion` / `targetSdkVersion`
  and the minimum `compatibleSdkVersion` 5.1.0(18) (lowest the dependencies and APIs allow; lets Device Manager list phone emulators); DevEco Studio 6.0.1.251; ArkTS / ArkUI, Stage model. Code:
  `CrossPlatform/harmonyos-cylplaceholder` (HAR `cylplaceholder`, example HAP `entry`).
- **The API matches iOS:** every public symbol of the iOS library has a HarmonyOS counterpart with the iOS name
  (types, enums, constants, methods in camelCase without the Objective-C colons).
- **The example matches iOS:** the HarmonyOS example is a 1:1 copy of `Examples/Example-Scenarios`: the same tabs,
  pages, rows, texts, behaviors and order.
- **The implementation follows Android:** the internals are migrated from the Kotlin source under `android/`
  (`android/placeholder`, `android/merged`), translated to ArkTS; iOS headers define the contract, Kotlin the
  behavior.
- **Tracking and score:** `docs/HarmonyOS.md` lists every iOS public API (table 1) and every iOS example demo
  (table 2); the second column is the HarmonyOS implementation, TODO until done. Score = rows without TODO ÷
  counted rows (both tables together), recomputed by `node scripts/harmony-port-tables.js` after every finished
  feature; remove one TODO per finished feature until the score is 100.
- **Build:** `CrossPlatform/harmonyos-cylplaceholder/scripts/build.sh` (hvigor refuses non-ASCII project paths, so
  from a checkout under such a path the script mirrors the project to an ASCII directory and builds there; from a
  checkout at an ASCII path it builds in place).
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
- **IDE and emulator setup:** follow the skill `cyl-harmonyos-setup` (`.agents/skills/cyl-harmonyos-setup/SKILL.md`)
  before building or running. Emulator prerequisites: a Huawei developer account signed in to DevEco Studio; VT-x /
  AMD-V enabled in the BIOS; Hyper-V and Windows Hypervisor Platform turned on (`HypervisorPresent` is `True`);
  16 GB RAM or more and free disk space for the image; `compatibleSdkVersion` 5.1.0(18) so phone images are listed;
  and **the region set to China**. The region lives in DevEco Studio's `country.region.xml`
  (Windows: `%APPDATA%\Huawei\DevEcoStudio6.0\options\country.region.xml`; macOS:
  `~/Library/Application Support/Huawei/DevEcoStudio6.0/options/country.region.xml`). With DevEco Studio closed,
  back the file up (for example `country.region.xml.bak-NZ` when it was New Zealand) and change the region to China
  (CN). Make sure the region file now says China: `<countryregion name="CN"/>`; without it Device Manager offers no
  emulator. **Check it again before every emulator start**: a DevEco Studio left open while the file is edited writes
  its own region back on exit (2026-11-17 it said `NZ` again), so quit DevEco Studio, set `CN`, then start it and the
  emulator (skill `cyl-harmonyos-setup`, section 3).

### HarmonyOS accessibility and localization (owner's rule, 2026-11-16)

- **All HarmonyOS code of this project supports visual assistance and blind users** (screen readers, large text,
  high contrast) **and internationalization / localization.** If you find code that does not, add the support first.
- **Accessibility:** every tappable element has a role and a localized label (`accessibilityRole`, visible text or
  `accessibilityText`); rows group their content (`accessibilityGroup`); decorative images and animations are hidden
  (`accessibilityLevel('no')`); hidden controls are not read; selected items say so; library views follow the iOS
  VoiceOver behavior (placeholder, status bar, HUD, refresh controls).
- **Localization:** no hard-coded user-visible or spoken text. Library texts: `CYLPlaceholderLocalization`; example
  texts: `t('Key')` in seven languages (en, zh-Hans, zh-Hant, ja, ko, ru, uk); tab bar texts (Selected, Plus button,
  Close, Play / Stop, Badges): copied from CYLTabBarController's string table, only the keys this project uses, by
  `CrossPlatform/harmonyos-cylplaceholder/scripts/import-tabbar-strings.js`. Check with
  `node scripts/harmony-l10n-check.js`.
- **Automated UI tests use these features first to locate controls**: find a control by its accessibility label
  (`ON.description`) or its localized text (`ON.text`), in any of the example's languages, and fall back to component
  ids only when needed; trigger taps, complex flows and consecutive operations through those lookups
  (`entry/src/ohosTest/ets/test/ExampleUi.test.ets`).
- Checklists and the test pattern: skill `cyl-harmonyos-a11y-l10n` (`.agents/skills/cyl-harmonyos-a11y-l10n/SKILL.md`).

## HarmonyOS: IDE preparation and emulator prerequisites (added 2026-11-16)

Before any HarmonyOS work (building, installing or running a HAP, taking emulator screenshots), check these:

1. **DevEco Studio is installed**: `/Applications/DevEco-Studio.app` (DevEco Studio 6.0). The SDK is the bundled one:
   `DEVECO_SDK_HOME=/Applications/DevEco-Studio.app/Contents/sdk`; `hdc` is at
   `sdk/default/openharmony/toolchains/hdc`; build with the bundled node running
   `tools/hvigor/bin/hvigorw.js assembleHap --no-daemon`.
2. **The region is China.** The emulator (Device Manager, emulator images) is only offered when DevEco Studio's region
   is China. The region file is
   `~/Library/Application Support/Huawei/DevEcoStudio6.0/options/country.region.xml` (the folder follows the DevEco
   version). It must say `<countryregion name="CN"/>`, not another region such as `NZ`:

   ```xml
   <application>
       <component name="CountryRegionSetting">
           <countryregion name="CN"/>
       </component>
   </application>
   ```

   Check it with `grep countryregion "$HOME/Library/Application Support/Huawei/DevEcoStudio"*/options/country.region.xml`.
   If it is not `CN`: quit DevEco Studio first (it writes its settings back on exit), keep a copy of the file, change
   the value to `CN`, start DevEco Studio again and check the file once more.
3. **An emulator image is installed and the emulator starts**: the Mate 70 Pro image under `~/.Huawei/Emulator/deployed`
   (`Emulator -hvd "Mate 70 Pro" -path ~/.Huawei/Emulator/deployed -imageRoot ~/Library/Huawei/Sdk`, from
   `/Applications/DevEco-Studio.app/Contents/tools/emulator/`), signed in to a Huawei account in DevEco Studio when
   the image download asks for it, with hardware virtualization available on the Mac.
4. **Signing is not needed on the emulator**: it installs the unsigned `entry-default-unsigned.hap`
   (`hdc install -r`). Do not ask the owner for a signing setup for emulator runs.
5. **x86_64 emulator: install a HAP without the arm64-only Rive and PAG libraries.** The Windows (and Intel) emulator
   is x86_64, but the example `entry` depends on `@ohos/rive` and `@tencent/libpag`, which ship native libraries for
   arm64-v8a only (`libs/arm64-v8a/*.so`, with `libc++_shared.so`), so `hdc install` refuses the HAP as built
   ("install parse native so failed", error 9568347). The test path lives in CYLTabBarController's HarmonyOS
   CYLAnimatedItem (owner's direction, 2026-11-22; CYLTabBarController 143fadff, `cylanimateditem/README.md`, "x86_64
   emulator"), so every example and library that depends on the item tests the same way:
   - **Build the emulator target:** `entry/build-profile.json5` has an `emulator` target that leaves out every
     arm64-v8a library (and an `emulatorTest` build mode for `ohosTest`). `CrossPlatform/harmonyos-cylplaceholder/scripts/build.sh
     emulator` builds `entry/build/default/outputs/emulator/entry-emulator-unsigned.hap`.
   - **Install:** `python3 CrossPlatform/harmonyos-cylplaceholder/cylanimateditem/tools/cyl_hap_x86_64.py install <app.hap>`
     asks the device for its ABIs, leaves out the libraries it cannot load and runs `hdc install -r`
     (`CYL_HAP_STRIP_LIBS=1` / `0` forces it); `scripts/emulator-check.sh` uses the emulator HAP and this tool.
   - **At run time:** `CYLAnimatedItemEngines` reads `deviceInfo.abiList`; without arm64-v8a, `canPlay` is false for
     Rive and PAG, so the item shows its still image (`isSupportedOnDevice`, `unsupportedReason`). Code that creates
     Rive or PAG views outside `animationBuilder` checks `CYLAnimatedItemEngines.isSupportedOnDevice(type)` first.
   - **What x86_64 verifies:** Lottie, SVGA and GIF playback, still images and placeholders, Rive / PAG items on their
     still images, `showsImageWhenAnimationEnds` with Lottie or SVGA, layout, dark mode, accessibility, localization.
     Rive and PAG playback (and their end) need an arm64 device or arm64 emulator with the `default` target; say in
     every report which part ran where. Never commit a stripped HAP; phones and releases use the `default` target.

### Rive and PAG: tests that only run on arm64 (owner's rule, 2026-11-22)

`@ohos/rive` and `@tencent/libpag` ship native libraries for arm64-v8a only, so Rive and PAG playback cannot be tested
on the x86_64 HarmonyOS emulator today. For every test that can only run on arm64, use these two options, in order:

1. **Option 1: x86_64 libraries in CYLTabBarController's CYLAnimatedItemView.** Change CYLTabBarController's
   HarmonyOS CYLAnimatedItem (`CYLAnimatedItemView` / `CYLAnimatedItemEngines`) so that it brings in x86_64 builds of
   the Rive and PAG native libraries from GitHub (built from the libraries' own GitHub sources, with their licenses
   kept), and plays Rive and PAG on the x86_64 emulator with them.
   - **Guard condition:** the architecture of the running system: the x86_64 libraries are used only when the device
     ABI list (`deviceInfo.abiList`) is x86_64 (no arm64-v8a). arm64 devices keep the official arm64 libraries.
   - **Order of work:** first the x86_64 build must compile and must not crash or break any other feature (every other
     engine, the still-image fallback, layout, accessibility); only then make Rive and PAG playback work correctly.
   - **Debug guard:** until option 1 has passed its tests, it is also guarded by a debug build option (debug builds
     only), because today it only matters when running on the emulator. Remove the debug guard only after option 1 is
     verified, and **only with the owner's approval**: ask first, never remove it on your own.
2. **Option 2: hand the test to a macOS session.** If option 1 fails, forward the arm64-only tests to an active
   session running on macOS (Apple silicon is arm64; a session whose name starts with `Mac`, see "Session roles"),
   with the build, the HAP, the steps and the expected result, and record which tests it ran and their results. When no
   macOS session is active, record the tests as a `TODO` for the next macOS session.

Until one option has passed, report Rive and PAG playback as not verified on x86_64 (still images only), and say in
every report and screenshot footer which part ran on x86_64 and which needs arm64.

## AGENTS.md: Source of truth

- HarmonyOS (HarmonyOS 6.0.1, API 21): the API matches iOS, the example is a 1:1 copy of the iOS example, and the
  implementation is migrated from the Kotlin source under `android/`. Rules: `instructions.md` "HarmonyOS"; status
  and score: `docs/HarmonyOS.md`.

- HarmonyOS IDE and emulator setup (prerequisites; the region set to China in DevEco Studio's `country.region.xml`,
  which must say `<countryregion name="CN"/>`): skill `cyl-harmonyos-setup`.

- HarmonyOS accessibility and localization: all HarmonyOS code supports visual assistance / blind users and
  localization (add it first where missing); UI tests locate controls by accessibility label or localized text before
  ids, also for taps and multi-step flows. Rule: `instructions.md` "HarmonyOS accessibility and localization"; skill
  `cyl-harmonyos-a11y-l10n`.

## AGENTS.md: HarmonyOS: IDE preparation and emulator prerequisites (added 2026-11-16)

Before any HarmonyOS work (building, installing or running a HAP, taking emulator screenshots), check these:

1. **DevEco Studio is installed**: `/Applications/DevEco-Studio.app` (DevEco Studio 6.0). The SDK is the bundled one:
   `DEVECO_SDK_HOME=/Applications/DevEco-Studio.app/Contents/sdk`; `hdc` is at
   `sdk/default/openharmony/toolchains/hdc`; build with the bundled node running
   `tools/hvigor/bin/hvigorw.js assembleHap --no-daemon`.

2. **The region is China.** The emulator (Device Manager, emulator images) is only offered when DevEco Studio's region
   is China. The region file is
   `~/Library/Application Support/Huawei/DevEcoStudio6.0/options/country.region.xml` (the folder follows the DevEco
   version). It must say `<countryregion name="CN"/>`, not another region such as `NZ`:

   ```xml
   <application>
       <component name="CountryRegionSetting">
           <countryregion name="CN"/>
       </component>
   </application>
   ```

   Check it with `grep countryregion "$HOME/Library/Application Support/Huawei/DevEcoStudio"*/options/country.region.xml`.
   If it is not `CN`: quit DevEco Studio first (it writes its settings back on exit), keep a copy of the file, change
   the value to `CN`, start DevEco Studio again and check the file once more.

3. **An emulator image is installed and the emulator starts**: the Mate 70 Pro image under `~/.Huawei/Emulator/deployed`
   (`Emulator -hvd "Mate 70 Pro" -path ~/.Huawei/Emulator/deployed -imageRoot ~/Library/Huawei/Sdk`, from
   `/Applications/DevEco-Studio.app/Contents/tools/emulator/`), signed in to a Huawei account in DevEco Studio when
   the image download asks for it, with hardware virtualization available on the Mac.

4. **Signing is not needed on the emulator**: it installs the unsigned `entry-default-unsigned.hap`
   (`hdc install -r`). Do not ask the owner for a signing setup for emulator runs.

5. **x86_64 emulator: install a HAP without the arm64-only Rive and PAG libraries.** The Windows (and Intel) emulator
   is x86_64, but the example `entry` depends on `@ohos/rive` and `@tencent/libpag`, which ship native libraries for
   arm64-v8a only (`libs/arm64-v8a/*.so`, with `libc++_shared.so`), so `hdc install` refuses the HAP as built
   ("install parse native so failed", error 9568347). The test path lives in CYLTabBarController's HarmonyOS
   CYLAnimatedItem (owner's direction, 2026-11-22; CYLTabBarController 143fadff, `cylanimateditem/README.md`, "x86_64
   emulator"), so every example and library that depends on the item tests the same way:
   - **Build the emulator target:** `entry/build-profile.json5` has an `emulator` target that leaves out every
     arm64-v8a library (and an `emulatorTest` build mode for `ohosTest`). `CrossPlatform/harmonyos-cylplaceholder/scripts/build.sh
     emulator` builds `entry/build/default/outputs/emulator/entry-emulator-unsigned.hap`.
   - **Install:** `python3 CrossPlatform/harmonyos-cylplaceholder/cylanimateditem/tools/cyl_hap_x86_64.py install <app.hap>`
     asks the device for its ABIs, leaves out the libraries it cannot load and runs `hdc install -r`
     (`CYL_HAP_STRIP_LIBS=1` / `0` forces it); `scripts/emulator-check.sh` uses the emulator HAP and this tool.
   - **At run time:** `CYLAnimatedItemEngines` reads `deviceInfo.abiList`; without arm64-v8a, `canPlay` is false for
     Rive and PAG, so the item shows its still image (`isSupportedOnDevice`, `unsupportedReason`). Code that creates
     Rive or PAG views outside `animationBuilder` checks `CYLAnimatedItemEngines.isSupportedOnDevice(type)` first.
   - **What x86_64 verifies:** Lottie, SVGA and GIF playback, still images and placeholders, Rive / PAG items on their
     still images, `showsImageWhenAnimationEnds` with Lottie or SVGA, layout, dark mode, accessibility, localization.
     Rive and PAG playback (and their end) need an arm64 device or arm64 emulator with the `default` target; say in
     every report which part ran where. Never commit a stripped HAP; phones and releases use the `default` target.

### Rive and PAG: tests that only run on arm64 (owner's rule, 2026-11-22)

`@ohos/rive` and `@tencent/libpag` ship native libraries for arm64-v8a only, so Rive and PAG playback cannot be tested
on the x86_64 HarmonyOS emulator today. For every test that can only run on arm64, use these two options, in order:

1. **Option 1: x86_64 libraries in CYLTabBarController's CYLAnimatedItemView.** Change CYLTabBarController's
   HarmonyOS CYLAnimatedItem (`CYLAnimatedItemView` / `CYLAnimatedItemEngines`) so that it brings in x86_64 builds of
   the Rive and PAG native libraries from GitHub (built from the libraries' own GitHub sources, with their licenses
   kept), and plays Rive and PAG on the x86_64 emulator with them.
   - **Guard condition:** the architecture of the running system: the x86_64 libraries are used only when the device
     ABI list (`deviceInfo.abiList`) is x86_64 (no arm64-v8a). arm64 devices keep the official arm64 libraries.
   - **Order of work:** first the x86_64 build must compile and must not crash or break any other feature (every other
     engine, the still-image fallback, layout, accessibility); only then make Rive and PAG playback work correctly.
   - **Debug guard:** until option 1 has passed its tests, it is also guarded by a debug build option (debug builds
     only), because today it only matters when running on the emulator. Remove the debug guard only after option 1 is
     verified, and **only with the owner's approval**: ask first, never remove it on your own.

2. **Option 2: hand the test to a macOS session.** If option 1 fails, forward the arm64-only tests to an active
   session running on macOS (Apple silicon is arm64; a session whose name starts with `Mac`, see "Session roles"),
   with the build, the HAP, the steps and the expected result, and record which tests it ran and their results. When no
   macOS session is active, record the tests as a `TODO` for the next macOS session.

Until one option has passed, report Rive and PAG playback as not verified on x86_64 (still images only), and say in
every report and screenshot footer which part ran on x86_64 and which needs arm64.
