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
