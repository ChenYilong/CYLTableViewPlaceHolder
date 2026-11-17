# Folder instructions

This folder contains the HarmonyOS (ArkTS) port: the ohpm package `cylplaceholder` and the example `entry`. It inherits
the repository root `instructions.md` (see "HarmonyOS") and `AGENTS.md`.

## License in every published package

The ohpm package carries the project's license: a copy of the root `LICENSE` at the package root
(`cylplaceholder/LICENSE`, which ohpm publishes) and in its resource folder
(`cylplaceholder/src/main/resources/rawfile/cylplaceholder/LICENSE`), next to the third-party licenses of the bundled
animations and images; `oh-package.json5` declares `"license": "MIT"`. See "License in every published package" in the
root `instructions.md` and the `cyl-package-licenses` skill; `python3 scripts/check_package_licenses.py` checks it.
