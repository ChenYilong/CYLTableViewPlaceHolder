# Commit Readiness Rules

## Summary

Added English Conventional Commit and long-description requirements to the
repository commit instructions, alongside the existing pre-commit TODO audit.

## Completed

- Required detailed, evidence-based TODOs for every sub-100 parity item.
- Added `*.base` to `.gitignore` for local Obsidian folder-note metadata.
- Documented that API risks, known defects, implementation constraints, and
  verification steps must be explicit.
- Required a linked `docs/` note when a detailed commit description exceeds
  50 characters.
- Kept the outstanding parity items and their current scores in
  [the comparison tracker](flatdesign-item-comparison.md).

## TODO

- TODO: Complete and verify the last sub-100 parity item (Carthage and iOS 12,
  95) listed in [the comparison tracker](flatdesign-item-comparison.md); it needs
  `scripts/device-tests.sh` on a physical iOS 12 device. The other 18 rows are
  at 100 with test evidence.
- TODO: The placeholder and upstream-refresh issues below 100 are tracked in
  the `TODO` section of [issue-progress.md](issue-progress.md).
