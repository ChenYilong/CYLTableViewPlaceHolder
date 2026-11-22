# Folder instructions

This folder contains the HarmonyOS (ArkTS) port: the ohpm package `cylplaceholder` and the example `entry`. It inherits
the repository root `instructions.md` (see "HarmonyOS") and `AGENTS.md`.

## Tag: HarmonyOS scenario (`harmonyos`)

### x86_64 emulator: arm64-only Rive and PAG libraries

The default HAP of `entry` does not install on the x86_64 emulator ("install parse native so failed"): `@ohos/rive`
and `@tencent/libpag` ship native libraries for arm64-v8a only. The test path comes from CYLTabBarController's
HarmonyOS CYLAnimatedItem (`cylanimateditem/README.md`, "x86_64 emulator", pinned at 882ece17), shared by every app and
library that depends on the item:

```sh
scripts/build.sh emulator    # entry/build/default/outputs/emulator/entry-emulator-unsigned.hap, no arm64-v8a libraries
python3 cylanimateditem/tools/cyl_hap_x86_64.py install entry/build/default/outputs/emulator/entry-emulator-unsigned.hap
```

`entry/build-profile.json5` defines the `emulator` target (and the `emulatorTest` build mode for `ohosTest`);
`scripts/emulator-check.sh` installs the emulator HAP through the tool on a device without arm64-v8a. On x86_64,
`CYLAnimatedItemEngines.canPlay` is false for Rive and PAG, so those items show their still images; Rive and PAG
playback is verified only on arm64 devices or arm64 emulators with the `default` target. Never commit a stripped HAP.
Setup details: the `cyl-harmonyos-setup` skill; rule: root `instructions.md`, "HarmonyOS: IDE preparation and
emulator prerequisites", item 5.

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

## Tag: Code and architecture (`code`)

### License in every published package

The ohpm package carries the project's license: a copy of the root `LICENSE` at the package root
(`cylplaceholder/LICENSE`, which ohpm publishes) and in its resource folder
(`cylplaceholder/src/main/resources/rawfile/cylplaceholder/LICENSE`), next to the third-party licenses of the bundled
animations and images; `oh-package.json5` declares `"license": "MIT"`. See "License in every published package" in the
root `instructions.md` and the `cyl-package-licenses` skill; `python3 scripts/check_package_licenses.py` checks it.

### CYLAnimatedItem: the copied `cylanimateditem` module

`cylanimateditem/` is CYLTabBarController's HarmonyOS CYLAnimatedItem module (`CYLAnimatedItemView`,
`CYLAnimatedItemEngines`), copied unchanged at the commit the root `Cartfile` pins by
`scripts/sync-harmonyos-cylanimateditem.sh` (the commit is in `cylanimateditem/UPSTREAM_COMMIT`; `--check` compares).
Never edit its files: adapt `cylplaceholder` instead and re-run the script after the Cartfile moves. It keeps its own
MIT `LICENSE` (ChenYilong). `cylplaceholder` depends on it (`file:../cylanimateditem`) and on no animation library:
every placeholder icon is a `CYLAnimatedItemView`, the core ships only the GIF engine (system APIs), and the example
`entry` depends on `@ohos/lottie`, `@tencent/libpag` and `@ohos/rive` and registers their engines at launch
(`entry/src/main/ets/engines/ExampleAnimationEngines.ets`). Status: `docs/HarmonyOS.md`, "CYLAnimatedItem".

### Icon and title vs. the stack view

- **Icon and title: CYLAnimatedItemView only.** A view or page that shows only an icon and a title draws it with
  CYLTabBarController's `CYLAnimatedItemView` (`cyl-animated-item` in the mini program), not a `CYLPlaceholderStackView`.
  The stack is only for what the item cannot cover (several components, hints, buttons, per-component actions, or a
  title the item cannot draw on that platform); a missing item feature is requested upstream and the page moves to the
  item once the pin has it. Playback stays on the core's model (HarmonyOS `CYLPlaceholderAnimatedItem`). Every platform
  applies the same layout framework as `CYLPlaceholderStackView` does on the others (same components and order, one
  vertical center line, centered titles, iOS metrics). See `instructions.md`, "Icon and title: CYLAnimatedItemView;
  CYLPlaceholderStackView only for what it cannot cover".
- HarmonyOS today: `AnimationDetailPage` draws `CYLAnimatedItemView` with item props only (`animationUrl`,
  `animationSpeed`, `animationLoops`, a `CYLAnimatedItemController` for restarts, CYLTabBarController B22) and
  `animationBuilder: CYLPlaceholderAnimatedItemBuilder`, which plays any file through the registered animators.
  `CYLPlaceholderAnimatedItem` (attach / detach) stays for pages that drive playback through a placeholder model. Since CYLTabBarController 0ce518a8 (B21) the item applies `spacing`
  (8 vp on the detail page, checked on the emulator) and has `titleLines` (1 by default, 0 = no limit).
