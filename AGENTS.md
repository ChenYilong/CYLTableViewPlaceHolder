# Agent rules for CYLTableViewPlaceHolder

This repository contains an Objective-C iOS table-view placeholder library,
the integrated `CYLRefresh` component, and an example application. Read
`instructions.md` and the relevant project skill before changing code.

Rules are grouped by tag (same tags as `instructions.md`). Each line is the rule in short; its link leads to the full text in
`docs/instructions/<tag>.md`: read it whenever the tag or a keyword of the line applies to the task.

## Tag: Behavioral guidelines (`behavioral`)

- **Read this file in full before any task (mandatory, owner's rule, 2026-11-22):** [docs/instructions/behavioral.md](docs/instructions/behavioral.md). Its rules (think before
  coding, simplicity first, surgical changes, goal-driven execution) apply to every task; do not skim or summarize it.

## Tag: Task workflow (`workflow`)

- Before starting any task, record it as a `TODO` in the fitting document in `docs/` (`docs/Task-Log.md` when none fits): date, branch, the user's original prompt verbatim, the user's requirements and the detailed context. ([details](docs/instructions/workflow.md#agentsmd-record-every-task-in-docs-first))
- **Check the other sessions first** (step one of every task): list them and read their tasks; if one edits the same branch, check whether the task duplicates theirs and settle it with that session before changing anything. ([details](docs/instructions/workflow.md#agentsmd-record-every-task-in-docs-first))
- **Start with `TODO` and the branch:** the session's first reply begins with a `TODO` line naming the task and the current branch. ([details](docs/instructions/workflow.md#agentsmd-record-every-task-in-docs-first))
- **Score against acceptance criteria:** the `TODO` entry states what full marks (100) and a pass (60) are. ([details](docs/instructions/workflow.md#agentsmd-record-every-task-in-docs-first))
- **A hung emulator is restarted:** when a shared emulator stays hung or does not open, tell the other sessions first, then restart it from the command line without asking (restart is the first strategy); say "done" after. ([details](docs/instructions/workflow.md#agentsmd-record-every-task-in-docs-first))
- When the docs link to another project's GitHub repository as the source of a translation or port, bring in its open pull requests (merge them first, or translate and merge them afterwards) and keep a table of its open pull requests and issues with their status. ([details](docs/instructions/workflow.md#agentsmd-another-project-as-a-source-translations-and-ports))
- Use the project skills in `.agents/skills/`: `cyl-api-map` (API locations), `cyl-xcode-compat` (project settings), `cyl-verify` (verification), `cyl-docs` (documentation), `cyl-package-licenses` (licenses), `ios-accessibility` / `accessibility-audit` / `ios-localization`, and `cyl-session-roles` before every task. ([details](docs/instructions/workflow.md#agentsmd-source-of-truth))
- Before starting a task, check the active session names: `Mac…` sessions (case-insensitive) mainly develop and test iOS, `Win…` sessions the other platforms; give each platform part to the fitting session, or finish alone when none exists. ([details](docs/instructions/workflow.md#agentsmd-session-roles-added-2026-11-19))

## Tag: Testing scenario (`testing`)

- **Screenshots are enforced:** every stitched image is made with `python3 scripts/screenshot_sheet.py`, originals are named `<platform>-...-<commit>-<yyyymmdd>`, and `python3 scripts/check_screenshots.py` must pass before every commit that adds an image. ([details](docs/instructions/testing.md#agentsmd-screenshots-enforced))
- WeChat DevTools Skills (<https://developers.weixin.qq.com/miniprogram/dev/devtools/Skills.html>): run `wechatide` (WeChat DevTools 2.02.2607032 or later) to install the skill for the agent, authorize the client once, and use it to build, run and screenshot the mini program. ([details](docs/instructions/testing.md#agentsmd-skills))
- Screenshots (local and CI/CD): take them at key moments (a `TODO` can go, a pull request can merge, a result meets its expectation), crop to the key detail, and stitch them into a portrait sheet with an English header, captions and a footer. ([details](docs/instructions/testing.md#agentsmd-project-and-verification))

## Tag: CI/CD scenario (`ci`)

- CI/CD (`instructions.md`, "CI/CD"): iOS jobs on GitHub run on macOS 26 by default (`vars.MACOS_RUNNER || 'macos-26'`). ([details](docs/instructions/ci.md#agentsmd-project-and-verification))
- Every CI run that builds code must provide a screenshot of each example running (artifacts `example-screenshot-*` from the `Demo` jobs, shown inline by the `Example screenshots` job and its pull request comment). ([details](docs/instructions/ci.md#agentsmd-project-and-verification))

## Tag: Windows scenario (`windows`)

- Windows sessions (Android, HarmonyOS, mini program) read first: [HarmonyOS](docs/instructions/harmonyos.md), [Testing](docs/instructions/testing.md) (shared emulators, screenshots), [Session roles](docs/instructions/workflow.md#agentsmd-session-roles-added-2026-11-19).
- Git Bash: `adb` device paths need `MSYS_NO_PATHCONV=1`; Windows `hdc` needs native backslash paths; PowerShell scripts with non-ASCII text are saved as UTF-8 with a BOM.
- The x86_64 HarmonyOS emulator installs only the `emulator` target HAP (no arm64-only Rive / PAG libraries): `scripts/build.sh emulator`, then `cylanimateditem/tools/cyl_hap_x86_64.py install` ([details](docs/instructions/harmonyos.md)).

## Tag: macOS-only scenario (`macos`)

- macOS sessions own iOS (Xcode, simulator, CocoaPods, `pod install` / `Podfile.lock`) and the arm64-only tests handed over by Windows sessions ([Rive and PAG rule](docs/instructions/harmonyos.md)).
- The library supports iOS 15.0 and later (raised from 12.0 on 2026-11-20, the owner's decision: "raise iOS .spec the minimum to iOS 15"; CHANGELOG.md); the podspec says `15.0`. ([details](docs/instructions/macos.md#agentsmd-naming-and-compatibility))
- Preserve the Xcode project format: `objectVersion = 46`, `compatibilityVersion = "Xcode 3.2"`, explicit file references, and a shared scheme. ([details](docs/instructions/macos.md#agentsmd-naming-and-compatibility))
- The main example (`Examples/Example`, Swift) embeds the project's own framework target (`CYLTableViewPlaceHolderFramework`, module `CYLTableViewPlaceHolder`) and does not require `pod install`. ([details](docs/instructions/macos.md#agentsmd-project-and-verification))
- Examples contain no Objective-C. When Swift needs a better spelling of a core API, add a Swift naming macro (`NS_SWIFT_NAME`, `NS_REFINED_FOR_SWIFT`, `NS_SWIFT_UNAVAILABLE`) next to the Objective-C declaration; never change the Objective-C API itself for Swift. ([details](docs/instructions/macos.md#agentsmd-project-and-verification))
- iOS examples are written in Swift (the library stays Objective-C). ([details](docs/instructions/macos.md#agentsmd-project-and-verification))
- Run `ruby Tests/run-tests.rb` for relevant simulator tests. Use `DESTINATION` to select an installed simulator. ([details](docs/instructions/macos.md#agentsmd-project-and-verification))
- Xcode 27's simulator SDK requires a deployment target of at least 15.0 during builds. ([details](docs/instructions/macos.md#agentsmd-project-and-verification))
- **Run scripts with bash, not zsh (added 2026-11-16).** The interactive shell is zsh, which does not split an unquoted variable into words, so scripts that rely on word splitting break under it: ([details](docs/instructions/macos.md#agentsmd-running-scripts-bash-first))
  - run a script file with `bash script.sh` (shebang `#!/usr/bin/env bash`), never `zsh` or `sh`; run a one-off multi-line command as `bash -c '...'` or a heredoc piped to `bash`.
  - in zsh, when bash is not possible, use arrays (`files=(a b)`, `"${files[@]}"`) or `${=var}` to split on purpose;
  - quote every expansion (`"$var"`) unless splitting is wanted.

## Tag: HarmonyOS scenario (`harmonyos`)

- HarmonyOS (HarmonyOS 6.0.1, API 21): the API matches iOS, the example is a 1:1 copy of the iOS example, and the implementation is migrated from the Kotlin source under `android/`. ([details](docs/instructions/harmonyos.md#agentsmd-source-of-truth))
- HarmonyOS IDE and emulator setup (prerequisites; the region set to China in DevEco Studio's `country.region.xml`, which must say `<countryregion name="CN"/>`): skill `cyl-harmonyos-setup`. ([details](docs/instructions/harmonyos.md#agentsmd-source-of-truth))
- HarmonyOS accessibility and localization: all HarmonyOS code supports screen readers and localization (add it first where missing); UI tests find controls by accessibility label or localized text before ids. ([details](docs/instructions/harmonyos.md#agentsmd-source-of-truth))
- Before any HarmonyOS work (building, installing or running a HAP, taking emulator screenshots), check these: ([details](docs/instructions/harmonyos.md#agentsmd-harmonyos-ide-preparation-and-emulator-prerequisites-added-2026-11-16))
- **DevEco Studio is installed**: `/Applications/DevEco-Studio.app` (DevEco Studio 6.0). ([details](docs/instructions/harmonyos.md#agentsmd-harmonyos-ide-preparation-and-emulator-prerequisites-added-2026-11-16))
- **The region is China.** The emulator (Device Manager, emulator images) is only offered when DevEco Studio's region is China. ([details](docs/instructions/harmonyos.md#agentsmd-harmonyos-ide-preparation-and-emulator-prerequisites-added-2026-11-16))
- **An emulator image is installed and the emulator starts**: the Mate 70 Pro image under `~/.Huawei/Emulator/deployed`, started with `Emulator -hvd "Mate 70 Pro"` (full command in the details), with hardware virtualization available. ([details](docs/instructions/harmonyos.md#agentsmd-harmonyos-ide-preparation-and-emulator-prerequisites-added-2026-11-16))
- **Signing is not needed on the emulator**: it installs the unsigned `entry-default-unsigned.hap` (`hdc install -r`). ([details](docs/instructions/harmonyos.md#agentsmd-harmonyos-ide-preparation-and-emulator-prerequisites-added-2026-11-16))
- **x86_64 emulator: install a HAP without the arm64-only Rive and PAG libraries.** The Windows (and Intel) emulator is x86_64, but `@ohos/rive` and `@tencent/libpag` ship arm64-v8a libraries only, so build the `emulator` target (`scripts/build.sh emulator`): ([details](docs/instructions/harmonyos.md#agentsmd-harmonyos-ide-preparation-and-emulator-prerequisites-added-2026-11-16))
  - **Build the emulator target:** `entry/build-profile.json5` has an `emulator` target that leaves out every arm64-v8a library (and an `emulatorTest` build mode for `ohosTest`).
  - **Install:** `python3 CrossPlatform/harmonyos-cylplaceholder/cylanimateditem/tools/cyl_hap_x86_64.py install <app.hap>` reads the device ABIs, leaves out the libraries it cannot load and runs `hdc install -r`.
  - **At run time:** `CYLAnimatedItemEngines` reads `deviceInfo.abiList`; without arm64-v8a, `canPlay` is false for Rive and PAG and the item shows its still image (`isSupportedOnDevice`, `unsupportedReason`), unless a debug build has the x86_64 debug engine kit.
  - **What x86_64 verifies:** Lottie, SVGA and GIF playback, still images, placeholders, `showsImageWhenAnimationEnds` with Lottie or SVGA, layout, dark mode, accessibility and localization; Rive and PAG playback need arm64 or the debug kit below.
- `@ohos/rive` and `@tencent/libpag` ship native libraries for arm64-v8a only, so Rive and PAG playback cannot be tested on the x86_64 HarmonyOS emulator today. ([details](docs/instructions/harmonyos.md#agentsmd-harmonyos-ide-preparation-and-emulator-prerequisites-added-2026-11-16))
- **Option 1: x86_64 libraries in CYLTabBarController's CYLAnimatedItemView.** CYLTabBarController's HarmonyOS CYLAnimatedItem brings in x86_64 builds of the Rive and PAG libraries from their GitHub sources (licenses kept) and plays them on the x86_64 emulator. ([details](docs/instructions/harmonyos.md#agentsmd-harmonyos-ide-preparation-and-emulator-prerequisites-added-2026-11-16))
  - **Guard condition:** the architecture of the running system: the x86_64 libraries are used only when the device ABI list (`deviceInfo.abiList`) is x86_64 (no arm64-v8a).
  - **Order of work:** first the x86_64 build must compile and must not crash or break any other feature; only then make Rive and PAG playback work correctly.
  - **Debug guard:** until option 1 has passed its tests, it is also guarded by a debug build option (debug builds only), because today it only matters when running on the emulator.
  - **Debug guard removed (2026-11-23):** option 1 passed (Rive and PAG 4.5.102 play on the x86_64 emulator, no crash) and the owner approved removing the guard; CYLTabBarController `269eff24` loads the kit in debug and release builds, still only when `cyl_hap_x86_64.py install` added it and the device is x86_64.
- **Option 2: hand the test to a macOS session.** If option 1 fails, forward the arm64-only tests to an active `Mac…` session (Apple silicon is arm64) with the build, HAP, steps and expected result; with no macOS session, record them as a `TODO`. ([details](docs/instructions/harmonyos.md#agentsmd-harmonyos-ide-preparation-and-emulator-prerequisites-added-2026-11-16))
- Until one option has passed, report Rive and PAG playback as not verified on x86_64 (still images only), and say in every report and screenshot footer which part ran on x86_64 and which needs arm64. ([details](docs/instructions/harmonyos.md#agentsmd-harmonyos-ide-preparation-and-emulator-prerequisites-added-2026-11-16))

## Tag: Code and architecture (`code`)

- Public headers under `CYLTableViewPlaceHolder/` define the current API. ([details](docs/instructions/code.md#agentsmd-source-of-truth))
- `README.md` documents integration and usage; `docs/issue-progress.md` records issue history and known limits. ([details](docs/instructions/code.md#agentsmd-source-of-truth))
- **Icon and title: CYLAnimatedItemView only.** A view or page that shows only an icon and a title draws it with CYLTabBarController's `CYLAnimatedItemView` (`cyl-animated-item` in the mini program), not a `CYLPlaceholderStackView`. ([details](docs/instructions/code.md#agentsmd-icon-and-title-vs-the-stack-view))
- Follow the English naming rules in `instructions.md`: new project-owned classes use `CYL`; UIKit category files use `+CYL`; category methods and properties use `cyl_`, except required system overrides. ([details](docs/instructions/code.md#agentsmd-naming-and-compatibility))
- Do not rename existing public symbols, serialized keys, or resources without assessing compatibility and obtaining approval for breaking changes. ([details](docs/instructions/code.md#agentsmd-naming-and-compatibility))
- Preserve third-party copyright, license text, and original attribution. ([details](docs/instructions/code.md#agentsmd-naming-and-compatibility))
- Public API documentation comments (`instructions.md`, "Code conventions"): every public declaration has one, placed directly above it. ([details](docs/instructions/code.md#agentsmd-naming-and-compatibility))
- Reuse `CYLPlaceholderView` in the core (`instructions.md`, "Reuse CYLPlaceholderView in the core"): core features show icons and text through `CYLPlaceholderView`, the packaged icon-and-title view, instead of fully custom views. ([details](docs/instructions/code.md#agentsmd-naming-and-compatibility))
- Always search for image-setting code (`setImages`, `setImage`, `.image =`, `animationImages`, `UIImageView`) and prefer `CYLPlaceholderView`'s image API (`CYLPlaceholderItemImage`, `CYLPlaceholderComponent`) over setting images directly. ([details](docs/instructions/code.md#agentsmd-naming-and-compatibility))
- CYLTabBarController is always a CocoaPods dependency pinned to its **latest commit by timestamp across all branches** (`:git` plus `:commit`, never a version, tag or branch); resolve it with `scripts/resolve-cyltabbarcontroller-commit.sh`. ([details](docs/instructions/code.md#agentsmd-project-and-verification))
- In the example layer, CYLTabBarController is integrated by default with a PlusButton that opens its own plus child view controller (`plusChildViewController`), initialized from a local configuration file. ([details](docs/instructions/code.md#agentsmd-project-and-verification))
- The example's plus button bulges by default: its top edge is above the tab bar's (`CYLPlusButtonCenterYMultiplier` / `CYLPlusButtonCenterYOffset`, tappable through `touchableAreaOutsets`); a flat plus button only when the task asks for it. ([details](docs/instructions/code.md#agentsmd-project-and-verification))
- CYLRefresh is the only refresh library and refresh kernel on every platform: no example or core module depends on MJRefresh, SVPullToRefresh, CYLRefreshLayout, android-Ultra-Pull-To-Refresh or easy_refresh; a missing feature is added to CYLRefresh. ([details](docs/instructions/code.md#agentsmd-project-and-verification))
- `CYLPlaceholderHUD` is the only HUD kernel on every platform, its code in one folder (`CYLPlaceholderHUD/` on iOS, `hud/` on Android and HarmonyOS, `cyl-placeholder-hud/` in the mini program); no other HUD library. ([details](docs/instructions/code.md#agentsmd-project-and-verification))
- Fix bugs in the core first (`instructions.md`, "Fix bugs in the core first"): the core is the code published to a package registry (CocoaPods, Maven / Gradle, npm, ohpm, pub.dev). ([details](docs/instructions/code.md#agentsmd-project-and-verification))
- Animation bugs (`instructions.md`, "Animation bugs: record, screenshot, fix in CYLTabBarController"): record the bug first, screenshot it second, and fix it in CYLTabBarController's animation component, not in an example. ([details](docs/instructions/code.md#agentsmd-project-and-verification))
- Examples have the lowest weight (`instructions.md`, "Examples have the lowest weight"; `docs/Swift-Migration.md`): when a core change breaks an example, fix the example in the same change; an example is never a reason for a shim or a weaker core API. ([details](docs/instructions/code.md#agentsmd-project-and-verification))
- License in every published package (`instructions.md`, "License in every published package"): every package published to an external registry (CocoaPods, Carthage, Maven, npm, ohpm, pub.dev, ...) carries the project's license inside it; `scripts/check_package_licenses.py` checks it. ([details](docs/instructions/code.md#agentsmd-project-and-verification))
- Ready-made placeholder animations live in `CYLTableViewPlaceHolder.bundle/Animations/`, named `CYLPlaceholder<Scenario>.<ext>`. ([details](docs/instructions/code.md#agentsmd-project-and-verification))
- Animation examples (`instructions.md`, "Animation playback controls in examples"): every example page that shows animations has a "Play all" that restarts them from progress 0, a speed slider and a loop switch, applied live. ([details](docs/instructions/code.md#agentsmd-project-and-verification))

## Tag: Localization and accessibility (`l10n-a11y`)

- Localization is several files and always needs a file structure: on iOS, `<language>.lproj` folders inside a `.bundle`, never loose `.strings` files or hard-coded user-facing text. ([details](docs/instructions/l10n-a11y.md#agentsmd-project-and-verification))
- Accessibility is required everywhere (VoiceOver, Voice Control, Switch Control, Full Keyboard Access, Dynamic Type, Reduce Motion, Bold Text): every control and text is an element with a localized label, trait and value; fix gaps when you meet them. ([details](docs/instructions/l10n-a11y.md#agentsmd-project-and-verification))
- Resources follow the localization split: the core reads only its bundle through `CYLPlaceholderResourceBundle()` / `CYLPlaceholderResourceURL(path)`, each example only its own bundle through its own lookup. ([details](docs/instructions/l10n-a11y.md#agentsmd-project-and-verification))

## Tag: Documentation scenario (`docs`)

- **Instruction files are organized by tags (owner's rule, 2026-11-22).** Every instruction file (`instructions.md`, `AGENTS.md`, `CLAUDE.md`, each folder `instructions.md`, `.github/copilot-instructions.md`) groups its content under visible `## Tag: <name>` headings (never hidden or collapsed) and stays within 200 lines. When a tag's content would push a file past 200 lines, the overflow moves to `docs/instructions/<tag>.md` (English only, one file per tag, outside the bilingual docs rule and the docs navigation) and the file keeps a one-line summary with a relative link, so the details are read when the tag or keyword comes up. Details: [docs/instructions/docs.md](docs/instructions/docs.md#instruction-files-tags-and-the-200-line-limit).
- `README.md` and every document in `docs/` are bilingual (`中文 | English` two-column tables, `## 中文 / English` headings, `[CN]` / `[EN]` code comments); read only the English part. ([details](docs/instructions/docs.md#agentsmd-project-and-verification))
- Update relevant documentation and skills with user-visible changes. ([details](docs/instructions/docs.md#agentsmd-project-and-verification))

## Tag: Git and commits (`git`)

- **Before any git operation, read [docs/instructions/git.md](docs/instructions/git.md) in full (owner's rule, 2026-11-22).** Commit, push, pull, branch, merge, rebase, tag, pull request: read the whole git tag file first, every time, then run the git command.
- **Before every Commitizen-style (`git cz`) commit**, run `touch .git/NO_AUTO_SYNC && mkdir -p .git/hooks && touch .git/hooks/NO_AUTO_SYNC` in the repository root, so the vault's auto sync pauses. ([details](docs/instructions/git.md#agentsmd-commit-readiness))
- Before every commit, update `.gitignore`: add the patterns from CYLTabBarController's `.gitignore` that are missing (project name changed to `CYLTableViewPlaceHolder`) and ignore every generated or machine-local file of the change. ([details](docs/instructions/git.md#agentsmd-commit-readiness))
- Before a Commitizen-style commit, follow the commit-message hook instructions in `instructions.md`; inspect an existing hook before replacing it. ([details](docs/instructions/git.md#agentsmd-commit-readiness))
- Before every commit, audit the changed code and the project's comparison, issue-progress, and implementation-status documents. ([details](docs/instructions/git.md#agentsmd-commit-readiness))
- In the most relevant existing document under `docs/`, keep a `TODO` entry for every tracked item below 100% complete and verified. ([details](docs/instructions/git.md#agentsmd-commit-readiness))
- Review API design explicitly: record compatibility and migration risks, ambiguous or inconsistent keys, unsupported behavior, and lifecycle or accessibility gaps. ([details](docs/instructions/git.md#agentsmd-commit-readiness))
- Update scores only when supported by implementation and test evidence. ([details](docs/instructions/git.md#agentsmd-commit-readiness))
- Every commit message contains the owner's line `By @ChenYilong <luohanchenyilong@163.com>` exactly once, on its own line at the end of the body (before trailers such as `Co-Authored-By:`). ([details](docs/instructions/git.md#agentsmd-commit-readiness))
- Use an English Conventional Commit subject compatible with Commitizen. ([details](docs/instructions/git.md#agentsmd-commit-readiness))
- **git cz style, English only:** every commit uses the `git cz` (Commitizen) format with its default types and emojis, and the whole message (subject, body, scope, merge and cherry-pick messages) is English with no Chinese characters. ([details](docs/instructions/git.md#agentsmd-commit-readiness))
- Follow the Commitizen defaults: `{type}{scope}: {emoji}{subject}`, emojis enabled, no predefined scopes, and a 3–64 character message. ([details](docs/instructions/git.md#agentsmd-commit-readiness))
- Never commit AppleDouble files named `._*`. Follow the vault's cleanup rule before Git commands and check staged paths before committing. ([details](docs/instructions/git.md#agentsmd-git))
- Do not overwrite another person's changes or rewrite pushed history. ([details](docs/instructions/git.md#agentsmd-git))
- On any branch other than `master` or `main`, commit and push as soon as the work is written, without asking the user first. ([details](docs/instructions/git.md#agentsmd-git))
- Every time you create a branch, open a pull request for it right away, without asking (`instructions.md`, "A pull request for every new branch"). ([details](docs/instructions/git.md#agentsmd-git))
- Commit through a branch and a pull request by default, so CI runs (`docs/CI-CD.md`): branch, `touch .git/NO_AUTO_SYNC`, commit, push and open a pull request against the source branch; never merge without the owner's approval and a green `iOS` workflow. ([details](docs/instructions/git.md#agentsmd-git))
- Follow the current task's instructions for commits, branches, and pull requests when they differ from the default above. ([details](docs/instructions/git.md#agentsmd-git))
- **Every branch with commits has an open pull request (added 2026-11-16).** After creating a branch, any commit on it must be in a pull request. ([details](docs/instructions/git.md#agentsmd-git))
  - **Before every commit**, check that the current branch has an open pull request (`gh pr list --state open --head <branch>`).
  - **Target branch**: the branch of the pull request that was active (open) before this one was created; only when there is none, `master` (or `main`).
  - **More than two open pull requests: ask first.** When more than two pull requests are open, ask the owner before creating another branch and pull request; otherwise keep committing on the current branch.
  - Push only to branches that have an open pull request; do not recreate a branch that was deleted after its pull request was closed or merged.
  - **Commit and push at the end of every turn (added 2026-11-16).** When a turn ends on a branch other than `master` or `main`, commit and push the work right away, without asking.
