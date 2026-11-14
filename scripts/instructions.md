# Folder instructions

This folder contains project build and verification configuration. It inherits
the repository and vault root instructions. `update-docs-navigation.py` regenerates (or, with
`--check`, verifies) the navigation and binding tables of the bilingual README and docs; see "Bilingual
documentation" in the root `instructions.md`. `resolve-mjrefresh-version.sh` finds the latest MJRefresh version for the example Podfiles. `resolve-cyltabbarcontroller-commit.sh` finds the newest
CYLTabBarController commit on any branch (and with `--write` puts it into Podfiles); see "Depending on
CYLTabBarController" in the root `instructions.md`.
