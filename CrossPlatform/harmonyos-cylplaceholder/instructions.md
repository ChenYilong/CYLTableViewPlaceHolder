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
- HarmonyOS today: `AnimationDetailPage` draws `CYLAnimatedItemView` with `CYLPlaceholderAnimatedItem` /
  `CYLPlaceholderAnimatedItemBuilder` (64ab041); the item's title is one line only and its `spacing` is not applied yet
  (reported upstream), so long wrapping texts stay in stacks.
