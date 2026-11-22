# Folder instructions

This folder contains the WeChat Mini Program port, published to npm as `cyl-placeholder-miniprogram` (the
`miniprogram` folder is `src/`), with its example and tests. It inherits the repository root `instructions.md` and
`AGENTS.md`.

## Tag: Code and architecture (`code`)

### License in every published package

The npm package carries the project's license: `LICENSE` at the package root and a copy in the published folder
`src/LICENSE`, because `miniprogram_npm` copies only `src/`; the third-party licenses of the bundled resources stay
next to them (`src/cyl-placeholder/animations/LICENSE.*`) and in the package's `files`. The copied CYLTabBarController
components (`src/cyl-animated-item`, `src/cyl-animation-placeholder`, written by `scripts/sync-cyl-animated-item.js`
and never edited by hand) carry its MIT license as `LICENSE.CYLTabBarController` in each folder. `package.json` declares
`"license": "MIT"`. See "License in every published package" in the root `instructions.md` and the
`cyl-package-licenses` skill; `python3 scripts/check_package_licenses.py` checks it.

### Icon and title vs. the stack view

- **Icon and title: CYLAnimatedItemView only.** A view or page that shows only an icon and a title draws it with
  CYLTabBarController's `CYLAnimatedItemView` (`cyl-animated-item` in the mini program), not a `CYLPlaceholderStackView`.
  The stack is only for what the item cannot cover (several components, hints, buttons, per-component actions, or a
  title the item cannot draw on that platform); a missing item feature is requested upstream and the page moves to the
  item once the pin has it. Playback stays on the core's model (HarmonyOS `CYLPlaceholderAnimatedItem`). Every platform
  applies the same layout framework as `CYLPlaceholderStackView` does on the others (same components and order, one
  vertical center line, centered titles, iOS metrics). See `instructions.md`, "Icon and title: CYLAnimatedItemView;
  CYLPlaceholderStackView only for what it cannot cover".
- Mini program today: `cyl-placeholder` draws every icon title inside `cyl-animated-item` (52569d68); the example's
  animation detail page still draws its own player and title until `cyl-animated-item` has a title font weight and a
  dark-mode title color.
