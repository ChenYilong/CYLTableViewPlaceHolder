# Folder instructions

<!-- bound-classes: none -->

<!-- docs-navigation:start -->

| 中文 | English |
| --- | --- |
| [Task start, scoring, other sessions and emulators](#task-start-scoring-other-sessions-and-emulators) | [Task start, scoring, other sessions and emulators](#task-start-scoring-other-sessions-and-emulators) |
| [Icon and title vs. the stack view](#icon-and-title-vs-the-stack-view) | [Icon and title vs. the stack view](#icon-and-title-vs-the-stack-view) |
| [Screenshots: enforced](#screenshots-enforced) | [Screenshots: enforced](#screenshots-enforced) |

<!-- docs-navigation:end -->

<!-- docs-binding:start -->

| 类 / Class | 头文件 / Header |
| --- | --- |
| 无 / none | — |

<!-- docs-binding:end -->

Written in English only: instructions stay English only (`instructions.md`, "Bilingual documentation").

This folder contains project documentation and issue tracking. It inherits the
vault's root `instructions.md`.

## Task start, scoring, other sessions and emulators

- **Check the other sessions first** (step one of every task): list them and read their tasks; if one edits the same
  branch, check whether the task duplicates theirs and settle it with that session before changing anything.
- **Start with `TODO` and the branch:** the session's first reply begins with a `TODO` line naming the task and the
  current branch.
- **Score against acceptance criteria:** the `TODO` entry states what full marks (100) and a pass (60) are. Score
  after each step; never stop below a pass, keep rescoring until it passes. Write down why full marks were not
  reached, print the missing points as `TODO`s at the end of the session, and update the entry written at task start.
- **A hung emulator is restarted:** when a shared emulator stays hung or does not open, tell the other sessions
  first, then restart it from the command line without asking (restart is the first strategy); say "done" after.
- See `instructions.md`, "Record every task in docs before starting it" and "Shared emulators: restart a hung
  emulator".

## Icon and title vs. the stack view

- **Icon and title: CYLAnimatedItemView only.** A view or page that shows only an icon and a title draws it with
  CYLTabBarController's `CYLAnimatedItemView` (`cyl-animated-item` in the mini program), not a `CYLPlaceholderStackView`.
  The stack is only for what the item cannot cover (several components, hints, buttons, per-component actions, or a
  title the item cannot draw on that platform); a missing item feature is requested upstream and the page moves to the
  item once the pin has it. Playback stays on the core's model (HarmonyOS `CYLPlaceholderAnimatedItem`). Every platform
  applies the same layout framework as `CYLPlaceholderStackView` does on the others (same components and order, one
  vertical center line, centered titles, iOS metrics). See `instructions.md`, "Icon and title: CYLAnimatedItemView;
  CYLPlaceholderStackView only for what it cannot cover".

## Screenshots: enforced

- **Screenshots are enforced:** every stitched image is made with `python3 scripts/screenshot_sheet.py` (portrait, one
  column first, bold English header / captions / footer outside the panels, recorded in the PNG; another tool adds a
  `<sheet>.sheet.json` sidecar), originals are named `<platform>-...-<commit>-<yyyymmdd>`, and
  `python3 scripts/check_screenshots.py` must pass before every commit that adds an image (a local check; CI does not run it). Never add to
  `docs/assets/screenshot-legacy.txt`. After every pull, read the rule changes it brought
  (`git diff ORIG_HEAD HEAD -- instructions.md AGENTS.md .agents/skills`) before committing; never pull and commit in
  one command. See `instructions.md`, "Enforcement: every screenshot passes the checker" and "Re-read the rules a pull
  changes".
