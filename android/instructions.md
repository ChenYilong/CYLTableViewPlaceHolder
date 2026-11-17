# Folder instructions

This folder contains the Android (Kotlin) port: the library modules published to Maven (`placeholder`,
`merged/library` for CYLRefresh, `merged/library/rive`) and the example app. It inherits the repository root
`instructions.md` and `AGENTS.md`.

## License in every published package

Every library module published to Maven carries the project's license inside its AAR: a copy of the root `LICENSE` in
`src/main/resources/META-INF/<artifact>/LICENSE` (`cylplaceholder`, `cylrefresh`, `cylrefresh-rive`), with the
third-party licenses it must ship next to it (`LICENSE.placeholder-third-party`, `LICENSE.material-design-icons`,
`LICENSE.SmartRefreshLayout.txt`). Keep one folder per artifact so two AARs never share a `META-INF` path. A new library
module adds its own folder and an entry in `scripts/check_package_licenses.py`. See "License in every published
package" in the root `instructions.md` and the `cyl-package-licenses` skill.

## CYLTabBarController by commit

`:placeholder` depends on CYLTabBarController's `cyltabbarcontroller-animateditem` (module `:cylanimateditem`), which is
not on Maven Central yet, so `settings.gradle.kts` builds it from source at a commit (a composite build): from
`-PcylTabBarDir`, else `../Carthage/Checkouts/CYLTabBarController`, else `../../CYLTabBarController`; with none of them it
runs `scripts/cyltabbarcontroller-checkout.sh`, which checks out the commit the repository's `Cartfile` pins. CI passes
`-PcylTabBarDir` with the newest commit across all branches. Switch to the Maven coordinate once it is published.
