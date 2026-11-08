# Folder instructions

This repository contains an Objective-C table-view placeholder library, an
integrated refresh component, and an iOS example. It inherits the vault's root
instructions. Read `AGENTS.md` before changing the project.

## English naming rules

- Write repository instructions, skill instructions, and new identifier names in English.
- Prefix new project-owned Objective-C class names and corresponding class
  filenames with `CYL`, following `CYLRefreshComponent`.
- Name UIKit category files `<SystemClass>+CYL<Feature>.h` and `.m`, and prefix
  new category selectors and properties with `cyl_`. Objective-C property
  setters use `setCyl_`. Do not rename required system overrides such as `load`.
- Use `CYL` for project-defined type and constant prefixes. Do not copy
  unrelated vendor prefixes into new project APIs.
- These rules apply to new or intentionally migrated code. Do not silently
  rename an existing public API or break callers; document and explicitly
  approve breaking changes.
- Retain required third-party copyright notices, licenses, and source
  attribution even when they contain original names or URLs. Never claim
  third-party code as original work.
