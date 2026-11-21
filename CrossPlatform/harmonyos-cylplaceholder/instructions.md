# Folder instructions

This folder contains the HarmonyOS (ArkTS) port: the ohpm package `cylplaceholder` and the example `entry`. It inherits
the repository root `instructions.md` (see "HarmonyOS") and `AGENTS.md`.

## License in every published package

The ohpm package carries the project's license: a copy of the root `LICENSE` at the package root
(`cylplaceholder/LICENSE`, which ohpm publishes) and in its resource folder
(`cylplaceholder/src/main/resources/rawfile/cylplaceholder/LICENSE`), next to the third-party licenses of the bundled
animations and images; `oh-package.json5` declares `"license": "MIT"`. See "License in every published package" in the
root `instructions.md` and the `cyl-package-licenses` skill; `python3 scripts/check_package_licenses.py` checks it.

## CYLAnimatedItem: the copied `cylanimateditem` module

`cylanimateditem/` is CYLTabBarController's HarmonyOS CYLAnimatedItem module (`CYLAnimatedItemView`,
`CYLAnimatedItemEngines`), copied unchanged at the commit the root `Cartfile` pins by
`scripts/sync-harmonyos-cylanimateditem.sh` (the commit is in `cylanimateditem/UPSTREAM_COMMIT`; `--check` compares).
Never edit its files: adapt `cylplaceholder` instead and re-run the script after the Cartfile moves. It keeps its own
MIT `LICENSE` (ChenYilong). `cylplaceholder` depends on it (`file:../cylanimateditem`) and on no animation library:
every placeholder icon is a `CYLAnimatedItemView`, the core ships only the GIF engine (system APIs), and the example
`entry` depends on `@ohos/lottie`, `@tencent/libpag` and `@ohos/rive` and registers their engines at launch
(`entry/src/main/ets/engines/ExampleAnimationEngines.ets`). Status: `docs/HarmonyOS.md`, "CYLAnimatedItem".

## Icon and title vs. the stack view

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

## x86_64 emulator: arm64-only Rive and PAG libraries

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
