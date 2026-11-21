# 持续集成与持续交付 / CI/CD

<!-- bound-classes: none -->

<!-- docs-navigation:start -->

| 中文 | English |
| --- | --- |
| [运行环境](#运行环境--runner-environment) | [Runner environment](#运行环境--runner-environment) |
| [工作流程：通过分支和拉取请求贡献](#工作流程通过分支和拉取请求贡献--workflow-contribute-through-a-branch-and-a-pull-request) | [Workflow: contribute through a branch and a pull request](#工作流程通过分支和拉取请求贡献--workflow-contribute-through-a-branch-and-a-pull-request) |
| [CI：`.github/workflows/ios.yml`](#cigithubworkflowsiosyml--ci-githubworkflowsiosyml) | [CI: `.github/workflows/ios.yml`](#cigithubworkflowsiosyml--ci-githubworkflowsiosyml) |
| [CD：`.github/workflows/release.yml`](#cdgithubworkflowsreleaseyml--cd-githubworkflowsreleaseyml) | [CD: `.github/workflows/release.yml`](#cdgithubworkflowsreleaseyml--cd-githubworkflowsreleaseyml) |
| [已知限制](#已知限制--known-limits) | [Known limits](#已知限制--known-limits) |
| [安卓](#安卓--android) | [Android](#安卓--android) |
| [iOS 15 运行时](#ios-15-运行时--ios-15-runtime) | [iOS 15 runtime](#ios-15-运行时--ios-15-runtime) |

<!-- docs-navigation:end -->

<!-- docs-binding:start -->

| 类 / Class | 头文件 / Header |
| --- | --- |
| 无 / none | — |

<!-- docs-binding:end -->

| 中文 | English |
| --- | --- |
| 参照 CYLTabBarController 的 [`.github/workflows`](https://github.com/ChenYilong/CYLTabBarController/tree/master/.github/workflows)，主要是 `ios.yml`（CI）和 `release.yml`（CD）。每个任务都调用 `scripts/` 中的脚本，因此在 Mac 上用同一条命令即可复现一次运行。 | Modeled on CYLTabBarController's [`.github/workflows`](https://github.com/ChenYilong/CYLTabBarController/tree/master/.github/workflows), mainly `ios.yml` (CI) and `release.yml` (CD). Every job calls a script in `scripts/`, so a run can be reproduced on a Mac with the same command. |

## 运行环境 / Runner environment

| 中文 | English |
| --- | --- |
| GitHub CI/CD 中 iOS 任务默认运行在 **macOS 26**（`runs-on: ${{ vars.MACOS_RUNNER \|\| 'macos-26' }}`，稳定镜像，默认 Xcode 26.x）；不需要 macOS 的任务（文档、本地化、shellcheck）使用 `ubuntu-latest`。修改或排查工作流之前，总是先查看 CYLTabBarController 的 [`.github/workflows/ios.yml`](https://github.com/ChenYilong/CYLTabBarController/blob/master/.github/workflows/ios.yml) 以确认运行环境，与本仓库不同时以它为准（最近一次查看：master `4209e37`，2026-11-10，使用 `macos-26`，可用仓库变量 `MACOS_RUNNER` 覆盖）。有意使用旧工具链的任务（如在 `macos-15` 上用 Xcode 16 编译 iOS 12 的 Core）保留自己的 runner，并在 `runs-on` 旁注明原因。 | iOS jobs on GitHub CI/CD run on **macOS 26** by default (`runs-on: ${{ vars.MACOS_RUNNER \|\| 'macos-26' }}`, the stable image with its default Xcode 26.x); Jobs that do not need macOS (docs, localization, shellcheck) use `ubuntu-latest`. Before changing or diagnosing a workflow, always read CYLTabBarController's [`.github/workflows/ios.yml`](https://github.com/ChenYilong/CYLTabBarController/blob/master/.github/workflows/ios.yml) first to confirm the runner environment, and follow it where it differs (last checked: master `4209e37`, 2026-11-10, `macos-26`, overridable with the repository variable `MACOS_RUNNER`). Jobs that use an older toolchain on purpose (such as the iOS 12 Core build with Xcode 16 on `macos-15`) keep their own runner, with the reason in a comment next to `runs-on`. |
| 本地运行不受此限制：本地运行指不经过 GitHub CI/CD，直接在本机 Mac 上测试，可以直接启动模拟器与 Xcode。默认本机为 **macOS 27 + Xcode 27**，因此编译时需要 Xcode 27 的部署版本覆盖（编译至少 iOS 15.0，库的最低版本 iOS 12.0 不变）。使用与 CI 相同的脚本（`scripts/`、带 `DESTINATION` 的 `ruby Tests/run-tests.rb`），用 `xcrun simctl list devices available` 选择已安装的模拟器。 | Local runs ignore this restriction: a local run skips GitHub CI/CD and tests directly on your own Mac, where the simulator and Xcode can be started. Assume that Mac runs **macOS 27 with Xcode 27**, so builds need the Xcode 27 deployment-target override (at least iOS 15.0 for the build; the library's iOS 12.0 minimum stays). Use the same scripts as CI (`scripts/`, `ruby Tests/run-tests.rb` with `DESTINATION`) and pick an installed simulator with `xcrun simctl list devices available`. |

## 工作流程：通过分支和拉取请求贡献 / Workflow: contribute through a branch and a pull request

| 中文 | English |
| --- | --- |
| 1. 从 `master` 创建分支（`feat/…`、`fix/…`、`docs/…`、`ci/…`）。 | 1. Create a branch from `master` (`feat/…`, `fix/…`, `docs/…`, `ci/…`). |
| 2. 提交之前运行 `touch .git/NO_AUTO_SYNC && mkdir -p .git/hooks && touch .git/hooks/NO_AUTO_SYNC`（vault 的 `git_sync.py` 检查 `.git/NO_AUTO_SYNC`；只设置 hooks 路径从未让它暂停），这样 vault 的自动同步在此期间不会向 `master` 提交或推送。`mkdir -p` 会在 hooks 目录缺失时创建它，所以 `touch` 总能成功。 | 2. Before committing, run `touch .git/NO_AUTO_SYNC && mkdir -p .git/hooks && touch .git/hooks/NO_AUTO_SYNC` (the vault's `git_sync.py` checks `.git/NO_AUTO_SYNC`; the hooks path alone never paused it), so the vault's auto sync does not commit or push to `master` meanwhile. `mkdir -p` creates the hooks directory when it is missing, so `touch` always succeeds. |
| 3. 用 Commitizen 风格的英文标题提交，推送分支，并立即（无需询问）向创建它的分支（这里是 `master`；见 `instructions.md` 中的 “A pull request for every new branch”）发起拉取请求。 | 3. Commit with a Commitizen-style English subject, push the branch, and open a pull request right away, without asking, against the branch it was created from (here `master`; see "A pull request for every new branch" in `instructions.md`). |
| 4. 只有在 `iOS` 工作流通过（绿色）之后才合并。 | 4. Merge only after the `iOS` workflow is green. |

## CI：`.github/workflows/ios.yml` / CI: `.github/workflows/ios.yml`

| 中文 | English |
| --- | --- |
| 在每个拉取请求、每次推送到 `master` 以及手动触发时运行。只修改文档（`docs/`、`*.md`、`assets/`、`*.base`）的拉取请求会跳过 macOS 步骤；这些任务仍然报告成功，因此必需检查可以通过。 | Runs on every pull request, on pushes to `master`, and manually. A pull request that changes only documentation (`docs/`, `*.md`, `assets/`, `*.base`) skips the macOS steps; the jobs still report success, so required checks pass. |

| 任务 | 脚本 | 检查内容 |
| --- | --- | --- |
| Changes | — | 代码是否有改动（Ubuntu） |
| shellcheck | `shellcheck scripts/*.sh` | CI 与发布脚本（Ubuntu） |
| Docs navigation | `python3 scripts/update-docs-navigation.py --check` | 双语 README 与文档中生成的导航表和绑定表是否为最新（Ubuntu）；去掉 `--check` 运行脚本即可修复 |
| Localization files | `python3 scripts/check_localizations.py` | 每个 `.bundle`：各语言的键和格式说明符一致，本地化头文件中的宏与键一致，没有零散的 `.strings` 文件（Ubuntu） |
| pod lib lint | `scripts/pod-lint.sh lib` | 每个子 spec：Core、CYLPlaceholderItemAnimation、LottieSwift、PAG、PAGEnterprise、Rive、GIF |
| Framework build and analyze | `scripts/framework-build.sh` | Carthage framework 目标；占位图源码出现编译或静态分析警告即失败；CYLRefresh 的警告只报告 |
| Unit tests | `scripts/unit-tests.sh` | 在模拟器上运行 `Tests/run-tests.rb` |
| Accessibility | `scripts/accessibility-tests.sh` | `Tests/run-accessibility-tests.rb`：VoiceOver 读取的无障碍树，以及 Apple 的无障碍审核（iOS 17+） |
| Animation（3 个任务） | `scripts/animation-tests.sh <static\|dynamic> <PAG\|PAGEnterprise>` | 通过 CocoaPods 测试 LottieSwift、GIF、PAG/PAGEnterprise 和 Rive；测试素材从 CYLTabBarController 的 `feat/cross-platform-components` 稀疏检出 |
| Carthage | `scripts/pod-lint.sh xcframework` | 发布时附带的 XCFramework 及其资源 bundle |
| Demo（5 个任务） | `scripts/ci-build-example.sh <folder>` | 把最新的 MJRefresh 版本写入示例的 Podfile（示例在 `CYLRefresh` 旁依赖它），然后编译 `.`、`Examples/Example-objc-01`、`Examples/Example-objc-02`、`Examples/Example-SwiftUI`、`Examples/Example-Scenarios`（聚合示例），再在模拟器上启动每个示例并上传截图（构件 `example-screenshot-<folder>`）；没有截到图即失败 |

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

| 中文 | English |
| --- | --- |
| Runner：默认 `macos-26`。若想不修改工作流就更换它，可设置仓库变量 `MACOS_RUNNER`（Settings → Secrets and variables → Actions → Variables），例如 `xcode-27`。脚本用 `scripts/ci-destination.sh` 选择可用的 iPhone 模拟器；验证编译使用 `scripts/pod-lint.xcconfig`（iOS 15），因为 Xcode 27 的 SDK 已不能编译 iOS 12 目标；podspec 的最低版本 iOS 12 不变。 | Runner: `macos-26` by default. To change it without editing the workflow, set the repository variable `MACOS_RUNNER` (Settings → Secrets and variables → Actions → Variables), for example `xcode-27`. The scripts choose an available iPhone simulator with `scripts/ci-destination.sh`; validation builds use `scripts/pod-lint.xcconfig` (iOS 15) because Xcode 27 SDKs no longer build iOS 12 targets; the podspec's iOS 12 minimum is unchanged. |

### 示例截图 / Example screenshots

| 中文 | English |
| --- | --- |
| `Examples/Example-objc-02` 任务在启动截图之后还会运行 `CYLCollectionAnimationUITests`（#1523）和 `CYLPagingUITests`（#1430）。其中尾部加载测试通过 `CYL_SCREENSHOT_DIR` 保存每一步的截图（`ExampleObjC02-<case>-<step>.png`），因此它们出现在同一个构件和拉取请求评论中；日志是 `build/ExampleObjC02-uitests.log`。 | The `Examples/Example-objc-02` job also runs `CYLCollectionAnimationUITests` (#1523) and `CYLPagingUITests` (#1430) after the launch screenshot. Its footer-load tests save step screenshots (`ExampleObjC02-<case>-<step>.png`) through `CYL_SCREENSHOT_DIR`, so they appear in the same artifact and pull request comment; the log is `build/ExampleObjC02-uitests.log`. |
| 每个 `Demo` 任务在启动应用后保存 `build/screenshots/<scheme>.png`，并以 `example-screenshot-Example`、`example-screenshot-Examples-Example-objc-01`、`example-screenshot-Examples-Example-objc-02`、`example-screenshot-Examples-Example-SwiftUI` 或 `example-screenshot-Examples-Example-Scenarios` 上传。可在运行页面下载（Summary → Artifacts）；任务摘要列出构件名称和 Screenshot 列。GitHub 无法内联显示构件中的图片，所以 `Example screenshots` 任务（`scripts/ci-publish-screenshots.sh`）会下载全部截图，提交到 `ci-screenshots` 分支的 `pr-<number>/` 下（推送时用分支名），替换该文件夹之前的截图，并在其任务摘要和一条原地更新的拉取请求评论（标记为 `<!-- cyl-example-screenshots -->`）中内联显示。该任务具有 `contents: write` 和 `pull-requests: write` 权限；来自 fork 的拉取请求只获得只读令牌，因此其运行只链接构件。该分支在历史中保留所有更早的截图；变大时可以清理。截图显示的是启动后约 8 秒的第一屏，而不是交互。报告截图的规则在 `instructions.md`（“CI example screenshots”）。 | Each `Demo` job saves `build/screenshots/<scheme>.png` after launching the app and uploads it as `example-screenshot-Example`, `example-screenshot-Examples-Example-objc-01`, `example-screenshot-Examples-Example-objc-02`, `example-screenshot-Examples-Example-SwiftUI` or `example-screenshot-Examples-Example-Scenarios`. Download them from the run page (Summary → Artifacts); the job summary lists the artifact name and a Screenshot column. GitHub cannot show an image from an artifact inline, so the `Example screenshots` job (`scripts/ci-publish-screenshots.sh`) downloads all of them, commits them to the `ci-screenshots` branch under `pr-<number>/` (or the branch name for pushes), replacing that folder's previous screenshots, and shows them inline in its job summary and in one pull request comment that it updates in place (marked `<!-- cyl-example-screenshots -->`). The job has `contents: write` and `pull-requests: write`; a pull request from a fork gets a read-only token, so its run only links the artifacts. The branch keeps every earlier screenshot in its history; prune it if it grows. A screenshot shows the first screen about 8 seconds after launch, not interactions. The rule for reporting them is in `instructions.md` ("CI example screenshots"). |

## CD：`.github/workflows/release.yml` / CD: `.github/workflows/release.yml`

| 中文 | English |
| --- | --- |
| 1. 在一个拉取请求中提升 `CYLTableViewPlaceHolder.podspec` 的 `s.version` 并合并。 | 1. Bump `s.version` in `CYLTableViewPlaceHolder.podspec` in a pull request and merge it. |
| 2. 推送与版本号相同的标签，例如 `git tag 1.2.0 && git push origin 1.2.0`。 | 2. Push a tag equal to the version, for example `git tag 1.2.0 && git push origin 1.2.0`. |
| 3. 工作流检查标签与 podspec 一致，运行 `pod trunk push`，创建带自动生成说明的 GitHub release，并上传 `CYLTableViewPlaceHolder.xcframework.zip`。 | 3. The workflow checks the tag matches the podspec, runs `pod trunk push`, creates the GitHub release with generated notes, and uploads `CYLTableViewPlaceHolder.xcframework.zip`. |
| 必须设置仓库密钥 `COCOAPODS_TRUNK_TOKEN`（`pod trunk register` 之后 `~/.netrc` 中的令牌）。与 CYLTabBarController 不同，这里还没有需要更新的 Carthage 二进制 JSON 或 SPM 清单。 | The repository secret `COCOAPODS_TRUNK_TOKEN` must be set (the token from `~/.netrc` after `pod trunk register`). Unlike CYLTabBarController, there is no Carthage binary JSON or SPM manifest to update yet. |

## 已知限制 / Known limits

| 中文 | English |
| --- | --- |
| iOS 12 不再是 CI 目标（2026-11-20）：固定的 CYLAnimatedItem pod 使用 `UITabBarItemAppearance`（iOS 13+），Xcode 16 在 12.0 部署目标下无法编译，`iOS 12 deployment build` 与 `iOS 12 runtime` 任务因此失败；二者已改为 `iOS 15 deployment build` 与 `iOS 15 runtime`（15.0 是 Xcode 26/27 SDK 允许的最低部署目标）。podspec 仍写 `12.0`，与依赖不符：已向所有者提出改为 15.0 的建议，由所有者决定。真机运行：`scripts/device-tests.sh <device UDID> <team ID>`（默认 15.0）。 | iOS 12 is no longer a CI target (2026-11-20): the pinned CYLAnimatedItem pod uses `UITabBarItemAppearance` (iOS 13+), so Xcode 16 cannot build at the 12.0 deployment target and the `iOS 12 deployment build` and `iOS 12 runtime` jobs failed; they became `iOS 15 deployment build` and `iOS 15 runtime` (15.0 is the lowest deployment target the Xcode 26/27 SDKs allow). The podspec still says `12.0`, which contradicts the dependency: recommending 15.0 to the owner, who decides. Physical device: `scripts/device-tests.sh <device UDID> <team ID>` (default 15.0). |
| 无障碍审核在没有任何例外的情况下运行。默认角标字体是粗体 caption 1，因为审核会把 caption 2 报告为只能部分缩放。 | The accessibility audit runs with no exceptions. The default badge font is bold caption 1, because the audit reports caption 2 as only partially scaling. |
| 上游 `libpag` pod 会警告缺少许可证文件；`pod lib lint` 带 `--allow-warnings` 运行。 | The upstream `libpag` pod warns about a missing license file; `pod lib lint` runs with `--allow-warnings`. |
| 负载高的 macOS runner 可能卡住数十秒。测试等待条件而不是固定延时（刷新测试共用 120 秒上限，2026-11-20 起，此前一个测试在被饿死的 runner 上用了 65 秒；无障碍测试在点击后等待无障碍树更新），但 XCUITest 仍可能在任何测试代码运行之前以 “Timed out while launching application via Xcode” 失败（在 `Accessibility` 任务中见过）。那是 runner 的问题，不是库的问题：重跑一次该任务；第二次失败才是真问题。 | Loaded macOS runners can stall for tens of seconds. The tests wait on conditions rather than fixed delays (the refresh tests share a 120 s bound since 2026-11-20, after one test took 65 s on a starved runner; the accessibility tests wait for the tree to update after a tap), but an XCUITest can still fail with "Timed out while launching application via Xcode" before any test code runs (seen in the `Accessibility` job). That is the runner, not the library: re-run the job once; a second failure is real. |

## 安卓 / Android

| 中文 | English |
| --- | --- |
| `.github/workflows/android.yml`（2026-11-17 新增）在 `ubuntu-latest` 上运行 Android 单元测试（`:placeholder`、`:placeholder-lottie`、`:placeholder-rive`、`:merged`）并编译 `:merged-example`；该镜像的 Android SDK 已接受许可。它在 `android/**` 改动时运行。iOS 工作流的文档任务还会检查生成的 API 表：`docs/iOS-API-Map.md`（表 A）、`docs/Android-API-Map.md` 和 `docs/iOS-Android-Parity.md`（表 B，英文）。 | `.github/workflows/android.yml` (added 2026-11-17) runs the Android unit tests (`:placeholder`, `:placeholder-lottie`, `:placeholder-rive`, `:merged`) and builds `:merged-example` on `ubuntu-latest`, whose Android SDK has its licenses accepted. It runs when `android/**` changes. The iOS workflow's docs job also checks the generated API tables: `docs/iOS-API-Map.md` (table A), `docs/Android-API-Map.md` and `docs/iOS-Android-Parity.md` (table B, English). |

## iOS 15 运行时 / iOS 15 runtime

| 中文 | English |
| --- | --- |
| `.github/workflows/ios15-runtime.yml`（2026-11-20 取代 `ios12-runtime.yml`）在标准 macOS 26 runner 上用最新 Xcode 以 15.0 部署目标编译单元测试，并在 iOS 15.x 模拟器上运行：`scripts/install-ios15-simulator.sh` 使用已安装的 iOS 15 运行时，否则用 `xcodebuild -downloadPlatform iOS -buildVersion 15.5` 下载。无法安装时退而求其次：仍按 15.0 编译，在最新的 iPhone 模拟器上运行，并发出警告说明 iOS 15 本身没有运行。`ios.yml` 中的 `iOS 15 deployment build` 任务（`scripts/ios15-build.sh`）以 15.0 编译并把未加保护的可用性问题视为错误。 | `.github/workflows/ios15-runtime.yml` (replaces `ios12-runtime.yml`, 2026-11-20) builds the unit tests at the 15.0 deployment target with the newest Xcode on the standard macOS 26 runner and runs them on an iOS 15.x simulator: `scripts/install-ios15-simulator.sh` uses an installed iOS 15 runtime, else downloads one with `xcodebuild -downloadPlatform iOS -buildVersion 15.5`. When it cannot install one, the job falls back: still built for 15.0, run on the newest iPhone simulator, with a warning that iOS 15 itself was not run. The `iOS 15 deployment build` job in `ios.yml` (`scripts/ios15-build.sh`) builds at 15.0 with unguarded-availability errors. |
