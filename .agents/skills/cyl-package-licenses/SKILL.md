---
name: cyl-package-licenses
description: Make every package published to an external registry (CocoaPods, Carthage, Gradle / Maven, npm, ohpm, pub.dev) carry its license file inside the package, on every platform.
---

# License in every published package

Rule: `instructions.md`, "License in every published package" (owner's rule, 2026-11-17). All code published to an
external registry carries its license declaration inside the package itself, on every platform.

## Where the license goes

Copy the root `LICENSE` (MIT) into the package's built-in resource folder. If the package has no resource folder,
create one. Current locations:

| Registry | Package | License copy |
|:---|:---|:---|
| CocoaPods, Carthage / XCFramework | iOS Core | `CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.bundle/LICENSE` |
| Gradle / Maven | `android/placeholder` | `src/main/resources/META-INF/cylplaceholder/LICENSE` |
| Gradle / Maven | `android/merged/library` (CYLRefresh) | `src/main/resources/META-INF/cylrefresh/LICENSE` |
| Gradle / Maven | `android/merged/library/rive` | `src/main/resources/META-INF/cylrefresh-rive/LICENSE` |
| ohpm | `CrossPlatform/harmonyos-cylplaceholder/cylplaceholder` | `LICENSE` and `src/main/resources/rawfile/cylplaceholder/LICENSE` |
| npm | `CrossPlatform/wechat-miniprogram-cylplaceholder` | `LICENSE` and `src/LICENSE` (the published folder) |

Notes:

- iOS: the resource bundle always contains the license file; the podspec ships the bundle (`core.resources`) and the
  framework target copies it as a folder reference.
- Android: `src/main/resources` is packed into the AAR. Use one `META-INF/<artifact>/` folder per artifact: two AARs
  with the same `META-INF` path make the app's build fail ("More than one file was found").
- HarmonyOS: ohpm expects `LICENSE` at the package root; the `rawfile` copy ships with the HAR's resources.
- Mini program: `miniprogram_npm` copies only the `miniprogram` folder (`src`), so the license lives there too.

## Third-party licenses

- Ship every third-party license and notice with the files it covers, unchanged (`LICENSE.<project>`,
  `NOTICE.<project>`, e.g. `Animations/NOTICE.animations`, `LICENSE.SmartRefreshLayout.txt`).
- Never drop or edit another author's license, copyright line or attribution.
- A license kept at a module root that the package does not ship (Android) is copied into the package folder as well.

## Copied (vendored) upstream packages

An upstream package taken by commit and copied into this repository (the HarmonyOS `cylanimateditem` module, the mini
program's `cyl-animated-item` and `cyl-animation-placeholder`) keeps its upstream `LICENSE` unchanged next to an
`UPSTREAM_COMMIT` file naming the repository and commit. Never edit the copied files; re-run the sync script
(`scripts/sync-harmonyos-cylanimateditem.sh`, `npm run sync-animated-item`) when the `Cartfile` commit changes.
`scripts/check_package_licenses.py` checks the copies in its `VENDORED` table.

## Manifests

Declare the license in each manifest: `s.license` in `CYLTableViewPlaceHolder.podspec`, `"license"` in
`package.json` and `oh-package.json5`, and the POM `licenses` block when a Maven publication is configured.

## Verify

```sh
python3 scripts/check_package_licenses.py
```

It fails when a copy is missing or differs from the root `LICENSE`, when a required third-party copy differs from its
original, or when a manifest does not declare MIT. CI runs it in the "Localization files" job. When you add a package
or a registry, add its copy to the tables in the script and in this skill.
