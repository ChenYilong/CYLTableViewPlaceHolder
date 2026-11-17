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

## Icon and title vs. the stack view

- **Icon and title: CYLAnimatedItemView only.** A view or page that shows only an icon and a title draws it with
  CYLTabBarController's `CYLAnimatedItemView` (`cyl-animated-item` in the mini program), not a `CYLPlaceholderStackView`.
  The stack is only for what the item cannot cover (several components, hints, buttons, per-component actions, or a
  title the item cannot draw on that platform); a missing item feature is requested upstream and the page moves to the
  item once the pin has it. Playback stays on the core's model (HarmonyOS `CYLPlaceholderAnimatedItem`). Every platform
  applies the same layout framework as `CYLPlaceholderStackView` does on the others (same components and order, one
  vertical center line, centered titles, iOS metrics). See `instructions.md`, "Icon and title: CYLAnimatedItemView;
  CYLPlaceholderStackView only for what it cannot cover".
- Android today: the example's animation detail page uses `CYLPlaceholderView` (a `CYLAnimatedItemView` subclass that
  also loops GIFs); scenario and support pages are stacks.
