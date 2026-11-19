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

> Status (2026-11-19, Windows session): every open item below is iOS work that needs macOS, Xcode, an iOS simulator or an iOS device, so by the session-roles rule it belongs to the Mac session; the Windows session handed the list over on 2026-11-19. The Android, HarmonyOS and mini program parts of the project are tracked in `docs/Android-API-Map.md` (100), `docs/HarmonyOS.md` and `docs/WeChat-MiniProgram.md`.

- TODO: Complete and verify the last sub-100 parity item (Carthage and iOS 12,
  95) listed in [the comparison tracker](flatdesign-item-comparison.md); it needs
  `scripts/device-tests.sh` on a physical iOS 12 device. The other 18 rows are
  at 100 with test evidence.
- TODO: The placeholder and upstream-refresh issues below 100 are tracked in
  the `TODO` section of [issue-progress.md](issue-progress.md).
- Audit (2026-11-19, Mac session): the Carthage and iOS 12 row stays at 95,
  blocked on a physical iOS 12 device (no iOS 12 runtime can run on this
  Mac). Every row of the issue-progress `TODO` section was rescored the same
  day: three rows reached 100 (#1628 with a core fix, CYLTabBarController by
  commit, bundled animations), the others carry a dated blocker or a "not done
  in this pass" note; see the audit line at the top of that section.
