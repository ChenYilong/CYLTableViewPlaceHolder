# CI/CD

Modeled on CYLTabBarController's
[`.github/workflows`](https://github.com/ChenYilong/CYLTabBarController/tree/master/.github/workflows),
mainly `ios.yml` (CI) and `release.yml` (CD). Every job calls a script in
`scripts/`, so a run can be reproduced on a Mac with the same command.

## Workflow: contribute through a branch and a pull request

1. Create a branch from `master` (`feat/…`, `fix/…`, `docs/…`, `ci/…`).
2. Before committing, run `touch .git/hooks/NO_AUTO_SYNC` so the vault's auto
   sync does not commit or push to `master` meanwhile.
3. Commit with a Commitizen-style English subject, push the branch, and open a
   pull request against `master`.
4. Merge only after the `iOS` workflow is green.

## CI: `.github/workflows/ios.yml`

Runs on every pull request, on pushes to `master`, and manually. A pull request
that changes only documentation (`docs/`, `*.md`, `assets/`, `*.base`) skips the
macOS steps; the jobs still report success, so required checks pass.

| Job | Script | What it checks |
| --- | --- | --- |
| Changes | — | Whether code changed (Ubuntu) |
| shellcheck | `shellcheck scripts/*.sh` | The CI and release scripts (Ubuntu) |
| pod lib lint | `scripts/pod-lint.sh lib` | Every subspec: Core, CYLPlaceholderItemAnimation, LottieSwift, PAG, PAGEnterprise, Rive, GIF |
| Framework build and analyze | `scripts/framework-build.sh` | The Carthage framework target; fails on a build or analyzer warning in the placeholder's sources; CYLRefresh warnings are reported only |
| Unit tests | `scripts/unit-tests.sh` | `Tests/run-tests.rb` on a simulator |
| Accessibility | `scripts/accessibility-tests.sh` | `Tests/run-accessibility-tests.rb`: the accessibility tree VoiceOver reads, plus Apple's accessibility audit (iOS 17+) |
| Animation (3 jobs) | `scripts/animation-tests.sh <static\|dynamic> <PAG\|PAGEnterprise>` | LottieSwift, GIF, PAG/PAGEnterprise and Rive through CocoaPods; fixtures are sparse-checked-out from CYLTabBarController `feat/cross-platform-components` |
| Carthage | `scripts/pod-lint.sh xcframework` | The XCFramework a release attaches, with its resource bundle |
| Demo (4 jobs) | `scripts/ci-build-example.sh <folder>` | `.`, `Examples/Example-objc-01`, `Examples/Example-objc-02`, `Examples/Example-SwiftUI` |

Runner: `macos-26` by default. To change it without editing the workflow, set
the repository variable `MACOS_RUNNER` (Settings → Secrets and variables →
Actions → Variables), for example `xcode-27`. The scripts choose an available
iPhone simulator with `scripts/ci-destination.sh`; validation builds use
`scripts/pod-lint.xcconfig` (iOS 15) because Xcode 27 SDKs no longer build iOS
12 targets; the podspec's iOS 12 minimum is unchanged.

## CD: `.github/workflows/release.yml`

1. Bump `s.version` in `CYLTableViewPlaceHolder.podspec` in a pull request and
   merge it.
2. Push a tag equal to the version, for example `git tag 1.2.0 && git push
   origin 1.2.0`.
3. The workflow checks the tag matches the podspec, runs `pod trunk push`,
   creates the GitHub release with generated notes, and uploads
   `CYLTableViewPlaceHolder.xcframework.zip`.

The repository secret `COCOAPODS_TRUNK_TOKEN` must be set (the token from
`~/.netrc` after `pod trunk register`). Unlike CYLTabBarController, there is no
Carthage binary JSON or SPM manifest to update yet.

## Known limits

- The accessibility audit tolerates one known issue: it reports the badge
  labels as "partially" supporting Dynamic Type although
  `testBadgeAndTitleFollowAccessibilityTextSizes` measures them growing and
  fitting. See the accessibility TODO in
  [flatdesign-item-comparison.md](flatdesign-item-comparison.md).
- The upstream `libpag` pod warns about a missing license file; `pod lib lint`
  runs with `--allow-warnings`.
