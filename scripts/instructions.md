# Folder instructions

## Tag: CI/CD scenario (`ci`)

This folder contains project build and verification configuration. It inherits
the repository and vault root instructions. `update-docs-navigation.py` regenerates (or, with
`--check`, verifies) the navigation and binding tables of the bilingual README and docs; see "Bilingual
documentation" in the root `instructions.md`. `resolve-cyltabbarcontroller-commit.sh` finds the newest
CYLTabBarController commit on any branch (and with `--write` puts it into Podfiles); see "Depending on
CYLTabBarController" in the root `instructions.md`.

`check_package_licenses.py` checks that every package published to an external registry (CocoaPods, Carthage, Maven,
ohpm, npm) carries the root `LICENSE` in its resource folder, that the third-party licenses it must ship are there, and
that the manifests declare MIT; see "License in every published package" in the root `instructions.md`.
`cyltabbarcontroller-checkout.sh` / `cyltabbarcontroller-xcframework.sh` check out and build the CYLTabBarController
dependency the Cartfile pins.
