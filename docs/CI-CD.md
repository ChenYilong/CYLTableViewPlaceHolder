# CI/CD

Modeled on CYLTabBarController's
[`.github/workflows`](https://github.com/ChenYilong/CYLTabBarController/tree/master/.github/workflows),
mainly `ios.yml` (CI) and `release.yml` (CD). Every job calls a script in
`scripts/`, so a run can be reproduced on a Mac with the same command.

## Workflow: contribute through a branch and a pull request

1. Create a branch from `master` (`feat/…`, `fix/…`, `docs/…`, `ci/…`).
2. Before committing, run `mkdir -p .git/hooks && touch .git/hooks/NO_AUTO_SYNC`
   so the vault's auto sync does not commit or push to `master` meanwhile.
   `mkdir -p` creates the hooks directory when it is missing, so `touch`
   always succeeds.
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
| Demo (4 jobs) | `scripts/ci-build-example.sh <folder>` | Builds `.`, `Examples/Example-objc-01`, `Examples/Example-objc-02`, `Examples/Example-SwiftUI`, then launches each on a simulator and uploads a screenshot (artifact `example-screenshot-<folder>`); fails if no screenshot is captured |

Runner: `macos-26` by default. To change it without editing the workflow, set
the repository variable `MACOS_RUNNER` (Settings → Secrets and variables →
Actions → Variables), for example `xcode-27`. The scripts choose an available
iPhone simulator with `scripts/ci-destination.sh`; validation builds use
`scripts/pod-lint.xcconfig` (iOS 15) because Xcode 27 SDKs no longer build iOS
12 targets; the podspec's iOS 12 minimum is unchanged.

### Example screenshots

Each `Demo` job saves `build/screenshots/<scheme>.png` after launching the app
and uploads it as `example-screenshot-Example`,
`example-screenshot-Examples-Example-objc-01`,
`example-screenshot-Examples-Example-objc-02` or
`example-screenshot-Examples-Example-SwiftUI`. Download them from the run page
(Summary → Artifacts); the job summary lists the artifact name and a Screenshot
column. GitHub job summaries cannot embed images from artifacts, so the
screenshots are not shown inline. A screenshot shows the first screen about
8 seconds after launch, not interactions. The rule for reporting them is in
`instructions.md` ("CI example screenshots").

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

- iOS 12 runs nowhere in CI: Apple's iOS 12.4 simulator runtime refuses hosts after
  macOS 12.99 (tried on `macos-15-intel`), so the `iOS 12 deployment build` job only
  builds at iOS 12.0 with unguarded-availability errors. Runtime evidence comes from a
  physical device: `scripts/device-tests.sh <device UDID> <team ID>` (Xcode 16 or earlier).
- The accessibility audit runs with no exceptions. The default badge font is
  bold caption 1, because the audit reports caption 2 as only partially
  scaling.
- The upstream `libpag` pod warns about a missing license file; `pod lib lint`
  runs with `--allow-warnings`.
- Loaded macOS runners can stall for tens of seconds. The tests wait on
  conditions rather than fixed delays (refresh tests share a 30 s bound; the
  accessibility tests wait for the tree to update after a tap), but an
  XCUITest can still fail with "Timed out while launching application via
  Xcode" before any test code runs (seen in the `Accessibility` job). That is
  the runner, not the library: re-run the job once; a second failure is real.
