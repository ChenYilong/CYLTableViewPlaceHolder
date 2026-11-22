# Folder instructions

This folder contains the project's example and reproduction applications.
Each example inherits the repository instructions and any instructions in its
own folder. Keep upstream attribution and use the repository root as the local
CocoaPods dependency path.

## Tag: Testing scenario (`testing`)

### Examples and the issues they reproduce

Each example's `instructions.md` links its issues and gives step-by-step
reproduction and the automated test command.

| Example | Issues |
| --- | --- |
| `Example` (main app, root workspace) | [#2](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/2), [#3](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/3), [#6](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/6), [#11](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/11), [#15](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/15) |
| `Example-SwiftUI` | [MJRefresh #1628](https://github.com/CoderMJLee/MJRefresh/issues/1628), [MJRefresh #1589](https://github.com/CoderMJLee/MJRefresh/issues/1589) |
| `Example-objc-01` | [MJRefresh #1575](https://github.com/CoderMJLee/MJRefresh/issues/1575) |
| `Example-objc-02` | [MJRefresh #1523](https://github.com/CoderMJLee/MJRefresh/issues/1523), [MJRefresh #1506](https://github.com/CoderMJLee/MJRefresh/issues/1506), [MJRefresh #1483](https://github.com/CoderMJLee/MJRefresh/issues/1483), [MJRefresh #1430](https://github.com/CoderMJLee/MJRefresh/issues/1430) |

Status scores come from `docs/issue-progress.md`; update both when an issue changes.

Bugs: fix them in the core (the code published to CocoaPods, Maven / Gradle, npm, ohpm, pub.dev), not in an example;
an example-only fix needs the owner's approval and a written reason in the related document (`instructions.md`,
"Fix bugs in the core first").
Animation bugs: record them, screenshot them, and fix them in CYLTabBarController's animation component; a demo that
must change calls an interface CYLTabBarController adds for it (`instructions.md`, "Animation bugs: record,
screenshot, fix in CYLTabBarController").

## Tag: macOS-only scenario (`macos`)

### Language

Examples are Swift; the Objective-C library API is adapted in the core (see "Swift examples
and a Swift-friendly core" in the root `instructions.md`). Current state:

| Example | Source language | Status |
| --- | --- | --- |
| `Example-SwiftUI` | Swift | Done |
| `Example-objc-01` | Swift (the name is historical) | Done |
| `Example-objc-02` | Swift (the name is historical) | Done (CI compile pending) |
| `Example-Scenarios` | Swift (9 files), core API only | Done (CI compile pending) |
| `Example` (main app, root workspace) | Swift (6 files), embeds `CYLTableViewPlaceHolderFramework` | Done (CI compile pending) |
| `Example-placeholder` | — | Retired (a copy of the third-party KLTableViewAndCollectionViewPlaceholder, Objective-C; upstream: https://github.com/klaus01/KLTableViewAndCollectionViewPlaceholder, MIT, credited in `CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/LICENSE.placeholder-third-party`) |

## Tag: Code and architecture (`code`)

### Dependencies

Examples use no refresh library besides CYLRefresh (no `pod 'MJRefresh'`); see "One refresh library: CYLRefresh"
in the root `instructions.md`.

### Animation playback controls

A page that shows animations has "Play all" (restarts from progress 0), a speed slider and a loop switch, applied
live; see "Animation playback controls in examples" in the root `instructions.md` and
`docs/Example-Animation-Playback.md` (the per-page TODO list).

### Examples have the lowest weight

When a core change (the Swift migration of the core, or a refactor) breaks an example, the example is fixed first:
update its call sites to the core's new API in the same change. An example's usage never keeps an old spelling, an
alias or a shim in the core, and never lowers the core's Swift quality; the Swift coding standard decides. See
`instructions.md`, "Examples have the lowest weight", and `docs/Swift-Migration.md`.
