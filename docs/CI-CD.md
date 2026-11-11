# CI/CD

Modeled on CYLTabBarController's
[`.github/workflows`](https://github.com/ChenYilong/CYLTabBarController/tree/master/.github/workflows),
mainly `ios.yml` (CI) and `release.yml` (CD). Every job calls a script in
`scripts/`, so a run can be reproduced on a Mac with the same command.

## 运行环境 / Runner environment

| 中文 | English |
| --- | --- |
| GitHub CI/CD 中 iOS 任务默认运行在 **macOS 26**（`runs-on: ${{ vars.MACOS_RUNNER \|\| 'macos-26' }}`，稳定镜像，默认 Xcode 26.x）；只需 Linux 的任务（文档、本地化、shellcheck）使用 `ubuntu-latest`。修改或排查工作流之前，总是先查看 CYLTabBarController 的 [`.github/workflows/ios.yml`](https://github.com/ChenYilong/CYLTabBarController/blob/master/.github/workflows/ios.yml) 以确认运行环境，与本仓库不同时以它为准（最近一次查看：master `4209e37`，2026-11-10，使用 `macos-26`，可用仓库变量 `MACOS_RUNNER` 覆盖）。有意使用旧工具链的任务（如在 `macos-15` 上用 Xcode 16 编译 iOS 12 的 Core）保留自己的 runner，并在 `runs-on` 旁注明原因。 | iOS jobs on GitHub CI/CD run on **macOS 26** by default (`runs-on: ${{ vars.MACOS_RUNNER \|\| 'macos-26' }}`, the stable image with its default Xcode 26.x); Linux-only jobs (docs, localization, shellcheck) use `ubuntu-latest`. Before changing or diagnosing a workflow, always read CYLTabBarController's [`.github/workflows/ios.yml`](https://github.com/ChenYilong/CYLTabBarController/blob/master/.github/workflows/ios.yml) first to confirm the runner environment, and follow it where it differs (last checked: master `4209e37`, 2026-11-10, `macos-26`, overridable with the repository variable `MACOS_RUNNER`). Jobs that use an older toolchain on purpose (such as the iOS 12 Core build with Xcode 16 on `macos-15`) keep their own runner, with the reason in a comment next to `runs-on`. |
| 本地运行不受此限制：本地运行指不经过 GitHub CI/CD，直接在本机 Mac 上测试，可以直接启动模拟器与 Xcode。默认本机为 **macOS 27 + Xcode 27**，因此编译时需要 Xcode 27 的部署版本覆盖（编译至少 iOS 15.0，库的最低版本 iOS 12.0 不变）。使用与 CI 相同的脚本（`scripts/`、带 `DESTINATION` 的 `ruby Tests/run-tests.rb`），用 `xcrun simctl list devices available` 选择已安装的模拟器。 | Local runs ignore this restriction: a local run skips GitHub CI/CD and tests directly on your own Mac, where the simulator and Xcode can be started. Assume that Mac runs **macOS 27 with Xcode 27**, so builds need the Xcode 27 deployment-target override (at least iOS 15.0 for the build; the library's iOS 12.0 minimum stays). Use the same scripts as CI (`scripts/`, `ruby Tests/run-tests.rb` with `DESTINATION`) and pick an installed simulator with `xcrun simctl list devices available`. |

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
| Docs navigation | `python3 scripts/update-docs-navigation.py --check` | The generated navigation and binding tables of the bilingual README and docs are current (Ubuntu); run the script without `--check` to fix |
| Localization files | `python3 scripts/check_localizations.py` | Every `.bundle`: same keys and format specifiers in every language, localization-header macros match the keys, no loose `.strings` files (Ubuntu) |
| pod lib lint | `scripts/pod-lint.sh lib` | Every subspec: Core, CYLPlaceholderItemAnimation, LottieSwift, PAG, PAGEnterprise, Rive, GIF |
| Framework build and analyze | `scripts/framework-build.sh` | The Carthage framework target; fails on a build or analyzer warning in the placeholder's sources; CYLRefresh warnings are reported only |
| Unit tests | `scripts/unit-tests.sh` | `Tests/run-tests.rb` on a simulator |
| Accessibility | `scripts/accessibility-tests.sh` | `Tests/run-accessibility-tests.rb`: the accessibility tree VoiceOver reads, plus Apple's accessibility audit (iOS 17+) |
| Animation (3 jobs) | `scripts/animation-tests.sh <static\|dynamic> <PAG\|PAGEnterprise>` | LottieSwift, GIF, PAG/PAGEnterprise and Rive through CocoaPods; fixtures are sparse-checked-out from CYLTabBarController `feat/cross-platform-components` |
| Carthage | `scripts/pod-lint.sh xcframework` | The XCFramework a release attaches, with its resource bundle |
| Demo (5 jobs) | `scripts/ci-build-example.sh <folder>` | Resolves the latest MJRefresh version into the demo's Podfile (examples depend on it next to `CYLRefresh`), then builds `.`, `Examples/Example-objc-01`, `Examples/Example-objc-02`, `Examples/Example-SwiftUI`, `Examples/Example-Scenarios` (the aggregated demo), then launches each on a simulator and uploads a screenshot (artifact `example-screenshot-<folder>`); fails if no screenshot is captured |

Runner: `macos-26` by default. To change it without editing the workflow, set
the repository variable `MACOS_RUNNER` (Settings → Secrets and variables →
Actions → Variables), for example `xcode-27`. The scripts choose an available
iPhone simulator with `scripts/ci-destination.sh`; validation builds use
`scripts/pod-lint.xcconfig` (iOS 15) because Xcode 27 SDKs no longer build iOS
12 targets; the podspec's iOS 12 minimum is unchanged.

### Example screenshots

The `Examples/Example-objc-02` job also runs `CYLCollectionAnimationUITests` (#1523) and `CYLPagingUITests` (#1430) after the launch screenshot.
Its footer-load tests save step screenshots (`ExampleObjC02-<case>-<step>.png`) through `CYL_SCREENSHOT_DIR`,
so they appear in the same artifact and pull request comment; the log is `build/ExampleObjC02-uitests.log`.

Each `Demo` job saves `build/screenshots/<scheme>.png` after launching the app
and uploads it as `example-screenshot-Example`,
`example-screenshot-Examples-Example-objc-01`,
`example-screenshot-Examples-Example-objc-02`,
`example-screenshot-Examples-Example-SwiftUI` or
`example-screenshot-Examples-Example-Scenarios`. Download them from the run page
(Summary → Artifacts); the job summary lists the artifact name and a Screenshot
column. GitHub cannot show an image from an artifact inline, so the
`Example screenshots` job (`scripts/ci-publish-screenshots.sh`) downloads all of
them, commits them to the `ci-screenshots` branch under `pr-<number>/` (or the
branch name for pushes), replacing that folder's previous screenshots, and shows
them inline in its job summary and in one pull request comment that it updates
in place (marked `<!-- cyl-example-screenshots -->`). The job has
`contents: write` and `pull-requests: write`; a pull request from a fork gets a
read-only token, so its run only links the artifacts. The branch keeps every
earlier screenshot in its history; prune it if it grows. A screenshot shows the first screen about
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
