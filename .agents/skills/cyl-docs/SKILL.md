---
name: cyl-docs
description: Keep project usage, issue tracking, and skills aligned with the Objective-C APIs.
---

# Documentation

- Keep `README.md` aligned with public APIs, minimum iOS version, integration,
  resources, and example behavior.
- Keep `docs/issue-progress.md` accurate when a change affects a tracked issue;
  preserve historical context and distinguish verified fixes from limitations.
- Update `cyl-api-map` and other affected skills when API locations, commands,
  or supported build configurations change.
- Localized text follows "Localization" in `instructions.md`: `.lproj`
  folders in a `.bundle` per owner, the core bundle kept and changed only
  additively, example text in an example-level bundle read through macros.
  Document new tables, languages and keys in the README.
- Instructions and skills are written in English. Preserve required third-party
  copyright notices, licenses, and source attribution.
- Use relative paths for local references. Place attachments in an `assets/`
  subfolder next to their document.
