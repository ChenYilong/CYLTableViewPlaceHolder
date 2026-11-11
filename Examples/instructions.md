# Folder instructions

This folder contains the project's example and reproduction applications.
Each example inherits the repository instructions and any instructions in its
own folder. Keep upstream attribution and use the repository root as the local
CocoaPods dependency path.

## Dependencies

Every example's Podfile also contains `pod 'MJRefresh', '<latest version>'` (the highest stable version on the
CocoaPods trunk), so each example is built with the original library next to `CYLRefresh`. Set it with
`scripts/resolve-mjrefresh-version.sh --write Examples/*/Podfile` before building (`scripts/ci-build-example.sh`
does it in CI). See "Depending on MJRefresh in the examples" in the root `instructions.md`.

## Language

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

## Examples and the issues they reproduce

Each example's `instructions.md` links its issues and gives step-by-step
reproduction and the automated test command.

| Example | Issues |
| --- | --- |
| `Example` (main app, root workspace) | [#2](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/2), [#3](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/3), [#6](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/6), [#11](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/11), [#15](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/15) |
| `Example-SwiftUI` | [MJRefresh #1628](https://github.com/CoderMJLee/MJRefresh/issues/1628), [MJRefresh #1589](https://github.com/CoderMJLee/MJRefresh/issues/1589) |
| `Example-objc-01` | [MJRefresh #1575](https://github.com/CoderMJLee/MJRefresh/issues/1575) |
| `Example-objc-02` | [MJRefresh #1523](https://github.com/CoderMJLee/MJRefresh/issues/1523), [MJRefresh #1506](https://github.com/CoderMJLee/MJRefresh/issues/1506), [MJRefresh #1483](https://github.com/CoderMJLee/MJRefresh/issues/1483), [MJRefresh #1430](https://github.com/CoderMJLee/MJRefresh/issues/1430) |

Status scores come from `docs/issue-progress.md`; update both when an issue changes.

