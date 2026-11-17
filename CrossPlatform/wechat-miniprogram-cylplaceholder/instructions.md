# Folder instructions

This folder contains the WeChat Mini Program port, published to npm as `cyl-placeholder-miniprogram` (the
`miniprogram` folder is `src/`), with its example and tests. It inherits the repository root `instructions.md` and
`AGENTS.md`.

## License in every published package

The npm package carries the project's license: `LICENSE` at the package root and a copy in the published folder
`src/LICENSE`, because `miniprogram_npm` copies only `src/`; the third-party licenses of the bundled resources stay
next to them (`src/cyl-placeholder/animations/LICENSE.*`) and in the package's `files`. The copied CYLTabBarController
components (`src/cyl-animated-item`, `src/cyl-animation-placeholder`, written by `scripts/sync-cyl-animated-item.js`
and never edited by hand) carry its MIT license as `LICENSE.CYLTabBarController` in each folder. `package.json` declares
`"license": "MIT"`. See "License in every published package" in the root `instructions.md` and the
`cyl-package-licenses` skill; `python3 scripts/check_package_licenses.py` checks it.
