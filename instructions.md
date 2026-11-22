# Folder instructions

This repository contains an Objective-C table-view placeholder library, an
integrated refresh component, and an iOS example. It inherits the vault's root
instructions. Read `AGENTS.md` before changing the project.

Rules are grouped by tag. Each line is a summary; follow its link to `docs/instructions/<tag>.md` for the full rule when
the tag or keyword matches the task. Tags: `workflow`, `testing`, `ci`, `windows`, `macos`, `harmonyos`, `code`, `l10n-a11y`, `docs`, `git`. Agent rules: `AGENTS.md` (same tags).

## Tag: Task workflow (`workflow`)

Recording tasks, scoring, other sessions, porting another project. Full text: [docs/instructions/workflow.md](docs/instructions/workflow.md).

- [Record every task in docs before starting it](docs/instructions/workflow.md#record-every-task-in-docs-before-starting-it): Before starting any task, write it down in `docs/`, so an interrupted task never loses its context: the next session (or another agent) finds what was asked, why, and how far it got.
  - Subsections: [Before the TODO: check the other sessions first](docs/instructions/workflow.md#before-the-todo-check-the-other-sessions-first), [Re-read the rules a pull changes](docs/instructions/workflow.md#re-read-the-rules-a-pull-changes), [TODO and the branch at the top of the session](docs/instructions/workflow.md#todo-and-the-branch-at-the-top-of-the-session), [Acceptance criteria and scoring](docs/instructions/workflow.md#acceptance-criteria-and-scoring).
- [Translating or porting another project: its open pull requests and issues](docs/instructions/workflow.md#translating-or-porting-another-project-its-open-pull-requests-and-issues): When a document in this repository links to another project's GitHub repository as the source of a translation, a port or a similar task (for example CYLRefresh styles or flutter_easy_refresh in…
- [Session roles: Mac sessions for iOS, Win sessions for the other platforms (added 2026-11-19)](docs/instructions/workflow.md#session-roles-mac-sessions-for-ios-win-sessions-for-the-other-platforms-added-2026-11-19): Several agent sessions work on this repository at the same time.

## Tag: Testing scenario (`testing`)

Verification, shared emulators, screenshots. Full text: [docs/instructions/testing.md](docs/instructions/testing.md).

- [Shared emulators: restart a hung emulator](docs/instructions/testing.md#shared-emulators-restart-a-hung-emulator): Several sessions share the Android emulator (`emulator-5556`) and the HarmonyOS emulator (`127.0.0.1:5555`).
- [Screenshots of local builds and CI/CD](docs/instructions/testing.md#screenshots-of-local-builds-and-cicd): These rules cover every screenshot: local simulator or device runs and CI/CD artifacts.
  - Subsections: [Header and footer on stitched screenshots](docs/instructions/testing.md#header-and-footer-on-stitched-screenshots), [Enforcement: every screenshot passes the checker](docs/instructions/testing.md#enforcement-every-screenshot-passes-the-checker).

## Tag: CI/CD scenario (`ci`)

GitHub workflows and CI screenshots. Full text: [docs/instructions/ci.md](docs/instructions/ci.md).

- [CI/CD](docs/instructions/ci.md#cicd): The default runner environment for iOS on GitHub CI/CD is **macOS 26** (`runs-on: ${{ vars.MACOS_RUNNER || 'macos-26' }}`, the stable image with its default Xcode 26.x); Linux-only jobs (docs,…
- [CI example screenshots](docs/instructions/ci.md#ci-example-screenshots): Every CI run that builds code must provide a screenshot of each example app running.

## Tag: Windows scenario (`windows`)

What Windows sessions (Android, HarmonyOS, mini program) read first. Full text: [docs/instructions/windows.md](docs/instructions/windows.md).

- Windows sessions develop and test Android, HarmonyOS, the mini program, React Native and Flutter; iOS goes to macOS sessions. Read first: [HarmonyOS (owner's rule, 2026-11-16)](docs/instructions/harmonyos.md#harmonyos-owners-rule-2026-11-16), [HarmonyOS: IDE preparation and emulator prerequisites (added 2026-11-16)](docs/instructions/harmonyos.md#harmonyos-ide-preparation-and-emulator-prerequisites-added-2026-11-16), [Shared emulators: restart a hung emulator](docs/instructions/testing.md#shared-emulators-restart-a-hung-emulator), [Session roles: Mac sessions for iOS, Win sessions for the other platforms (added 2026-11-19)](docs/instructions/workflow.md#session-roles-mac-sessions-for-ios-win-sessions-for-the-other-platforms-added-2026-11-19).
- Shells: Git Bash runs `$`/Bash; device paths for `adb` need `MSYS_NO_PATHCONV=1`, and Windows `hdc` reads a forward-slash `C:/...` path as relative: pass native (backslash) paths.
- HarmonyOS builds use `CrossPlatform/harmonyos-cylplaceholder/scripts/build.sh` (ASCII paths only); the x86_64 emulator needs the `emulator` target HAP ([HarmonyOS: IDE preparation and emulator prerequisites (added 2026-11-16)](docs/instructions/harmonyos.md#harmonyos-ide-preparation-and-emulator-prerequisites-added-2026-11-16), item 5).

## Tag: macOS-only scenario (`macos`)

IOS, Xcode, CocoaPods, Swift, zsh vs bash. Full text: [docs/instructions/macos.md](docs/instructions/macos.md).

- macOS sessions own iOS: Xcode, the simulator, CocoaPods (`pod install`, `Podfile.lock`) and arm64-only tests handed over from Windows sessions. Also read: [Depending on CYLTabBarController](docs/instructions/code.md#depending-on-cyltabbarcontroller), [CI/CD](docs/instructions/ci.md#cicd).
- [Xcode and CocoaPods project checks](docs/instructions/macos.md#xcode-and-cocoapods-project-checks): When working on a runnable Xcode project, check its Podfile.
- [Swift examples and a Swift-friendly core](docs/instructions/macos.md#swift-examples-and-a-swift-friendly-core): iOS examples are written in Swift; the library stays Objective-C.
  - Subsections: [Examples](docs/instructions/macos.md#examples), [Making the Objective-C core Swift-friendly](docs/instructions/macos.md#making-the-objective-c-core-swift-friendly), [Examples have the lowest weight (owner's rule, 2026-11-13)](docs/instructions/macos.md#examples-have-the-lowest-weight-owners-rule-2026-11-13).
- [Running scripts: bash first](docs/instructions/macos.md#running-scripts-bash-first): **Run scripts with bash, not zsh (added 2026-11-16).** The interactive shell here is zsh, which does not split an unquoted variable into words: `for f in $list`, `cmd $args` or `sips $box` get one…

## Tag: HarmonyOS scenario (`harmonyos`)

The HarmonyOS port, DevEco Studio, the emulator, arm64-only Rive and PAG. Full text: [docs/instructions/harmonyos.md](docs/instructions/harmonyos.md).

- [HarmonyOS (owner's rule, 2026-11-16)](docs/instructions/harmonyos.md#harmonyos-owners-rule-2026-11-16): **Version:** HarmonyOS 6.0.1 (API 21, Release); HarmonyOS SDK 6.0.1.112, `compileSdkVersion` / `targetSdkVersion` and the minimum `compatibleSdkVersion` 5.1.0(18) (lowest the dependencies and APIs…
  - Subsections: [HarmonyOS accessibility and localization (owner's rule, 2026-11-16)](docs/instructions/harmonyos.md#harmonyos-accessibility-and-localization-owners-rule-2026-11-16).
- [HarmonyOS: IDE preparation and emulator prerequisites (added 2026-11-16)](docs/instructions/harmonyos.md#harmonyos-ide-preparation-and-emulator-prerequisites-added-2026-11-16): Before any HarmonyOS work (building, installing or running a HAP, taking emulator screenshots), check these:
  - Subsections: [Rive and PAG: tests that only run on arm64 (owner's rule, 2026-11-22)](docs/instructions/harmonyos.md#rive-and-pag-tests-that-only-run-on-arm64-owners-rule-2026-11-22).

## Tag: Code and architecture (`code`)

Naming, conventions, dependencies, one refresh / HUD / animation component, packages. Full text: [docs/instructions/code.md](docs/instructions/code.md).

- [English naming rules](docs/instructions/code.md#english-naming-rules): Write repository instructions, skill instructions, and new identifier names in English.
- [Code conventions](docs/instructions/code.md#code-conventions): **The core** is the code published to a package registry: CocoaPods (the podspec's sources and resources), Maven / Gradle (the Android library modules), npm (the mini program and React Native…
  - Subsections: [Fix bugs in the core first (owner's rule, 2026-11-17)](docs/instructions/code.md#fix-bugs-in-the-core-first-owners-rule-2026-11-17), [Cross-platform API parity tables and the scoring loop (owner's rule, 2026-11-17)](docs/instructions/code.md#cross-platform-api-parity-tables-and-the-scoring-loop-owners-rule-2026-11-17), [Animation bugs: record, screenshot, fix in CYLTabBarController (owner's rule, 2026-11-17)](docs/instructions/code.md#animation-bugs-record-screenshot-fix-in-cyltabbarcontroller-owners-rule-2026-11-17), [Documentation comments on public API](docs/instructions/code.md#documentation-comments-on-public-api), [Reuse CYLPlaceholderView in the core](docs/instructions/code.md#reuse-cylplaceholderview-in-the-core).
- [Depending on CYLTabBarController](docs/instructions/code.md#depending-on-cyltabbarcontroller): This project always integrates CYLTabBarController through CocoaPods: never Swift Package Manager, Carthage, copied or vendored sources.
  - Subsections: [Not named CYLTabBarController (this project, and every other): by commit](docs/instructions/code.md#not-named-cyltabbarcontroller-this-project-and-every-other-by-commit), [Named CYLTabBarController: local path](docs/instructions/code.md#named-cyltabbarcontroller-local-path), [Integrating CYLTabBarController in the examples](docs/instructions/code.md#integrating-cyltabbarcontroller-in-the-examples).
- [Icon and title: CYLAnimatedItemView; CYLPlaceholderStackView only for what it cannot cover](docs/instructions/code.md#icon-and-title-cylanimateditemview-cylplaceholderstackview-only-for-what-it-cannot-cover): Owner's rule (2026-11-18), for the core and the examples on every platform (iOS, Android, HarmonyOS, the WeChat Mini Program, React Native, Flutter):
- [One refresh library: CYLRefresh](docs/instructions/code.md#one-refresh-library-cylrefresh): `CYLRefresh` is the only refresh library and the only refresh kernel on every platform:
- [One HUD: CYLPlaceholderHUD](docs/instructions/code.md#one-hud-cylplaceholderhud): The HUD follows the same rule as CYLRefresh: `CYLPlaceholderHUD` is the only HUD kernel on every platform, and its code lives in one folder: `CYLTableViewPlaceHolder/CYLPlaceholderHUD/` (iOS),…
- [License in every published package (owner's rule, 2026-11-17)](docs/instructions/code.md#license-in-every-published-package-owners-rule-2026-11-17): Every piece of code published to an external registry carries its license declaration inside the package itself: CocoaPods, Carthage / XCFramework, Gradle / Maven, npm, ohpm, pub.dev and any…
- [Bundled animations](docs/instructions/code.md#bundled-animations): `CYLTableViewPlaceHolder.bundle/Animations/` ships ready-made placeholder animations with Core: Lottie `.json`, PAG `.pag`, Rive `.riv` and GIF `.gif`, named `CYLPlaceholder<Scenario>.<ext>` and…
- [Animation playback controls in examples](docs/instructions/code.md#animation-playback-controls-in-examples): Every example page that shows animations (placeholder animations, refresh icons, tab bar item animations, any Lottie / Rive / PAG / GIF / frame animation) has, next to its one-shot "Play all", a…

## Tag: Localization and accessibility (`l10n-a11y`)

Localization files and accessibility on every platform. Full text: [docs/instructions/l10n-a11y.md](docs/instructions/l10n-a11y.md).

- [Localization](docs/instructions/l10n-a11y.md#localization): Localization is always several files: one per language, often several tables per language.
  - Subsections: [iOS: `.lproj` folders inside a `.bundle`](docs/instructions/l10n-a11y.md#ios-lproj-folders-inside-a-bundle), [The core bundle is permanent](docs/instructions/l10n-a11y.md#the-core-bundle-is-permanent), [Lookup macros: one per layer, at least two per project](docs/instructions/l10n-a11y.md#lookup-macros-one-per-layer-at-least-two-per-project), [Example-level bundles, always with macros](docs/instructions/l10n-a11y.md#example-level-bundles-always-with-macros), [Resource lookups: the same split for files](docs/instructions/l10n-a11y.md#resource-lookups-the-same-split-for-files), [Right-to-left and locale formatting](docs/instructions/l10n-a11y.md#right-to-left-and-locale-formatting), [Other platforms](docs/instructions/l10n-a11y.md#other-platforms).
- [Accessibility (VoiceOver, Voice Control, Switch Control, Dynamic Type)](docs/instructions/l10n-a11y.md#accessibility-voiceover-voice-control-switch-control-dynamic-type): Adapted from CYLTabBarController's rule "Accessibility is required everywhere".

## Tag: Documentation scenario (`docs`)

Bilingual docs, instruction files and their tags. Full text: [docs/instructions/docs.md](docs/instructions/docs.md).

- **Instruction files are organized by tags (owner's rule, 2026-11-22).** Every instruction file (`instructions.md`, `AGENTS.md`, `CLAUDE.md`, each folder `instructions.md`, `.github/copilot-instructions.md`) groups its content under visible `## Tag: <name>` headings (never hidden or collapsed) and stays within 200 lines. When a tag's content would push a file past 200 lines, the overflow moves to `docs/instructions/<tag>.md` (English only, one file per tag, outside the bilingual docs rule and the docs navigation) and the file keeps a one-line summary with a relative link, so the details are read when the tag or keyword comes up. Details: [docs/instructions/docs.md](docs/instructions/docs.md#instruction-files-tags-and-the-200-line-limit).
- [Bilingual documentation (Chinese and English)](docs/instructions/docs.md#bilingual-documentation-chinese-and-english): `README.md` and every document in `docs/` are bilingual: Chinese and English side by side.
  - Subsections: [Reading](docs/instructions/docs.md#reading), [Format](docs/instructions/docs.md#format), [Generated blocks](docs/instructions/docs.md#generated-blocks), [Attachments](docs/instructions/docs.md#attachments), [New features and user-visible changes](docs/instructions/docs.md#new-features-and-user-visible-changes), [Comments in code](docs/instructions/docs.md#comments-in-code), [Before every commit](docs/instructions/docs.md#before-every-commit).

## Tag: Git and commits (`git`)

Commit readiness, Commitizen, branches and pull requests. Full text: [docs/instructions/git.md](docs/instructions/git.md).

- [Commit readiness and TODO tracking](docs/instructions/git.md#commit-readiness-and-todo-tracking): Before every commit, update `.gitignore`:
  - Subsections: [`.gitignore` before every commit](docs/instructions/git.md#gitignore-before-every-commit), [Commitizen defaults](docs/instructions/git.md#commitizen-defaults), [Author line in every commit message](docs/instructions/git.md#author-line-in-every-commit-message), [Commit-message hook before Commitizen commits](docs/instructions/git.md#commit-message-hook-before-commitizen-commits).
- [Commitizen commits](docs/instructions/git.md#commitizen-commits): Before every Commitizen-style (`git cz`) commit, run this first in the repository root:
  - Subsections: [git cz style, English only (owner's rule, 2026-11-16)](docs/instructions/git.md#git-cz-style-english-only-owners-rule-2026-11-16).
- [Committing on branches](docs/instructions/git.md#committing-on-branches): On any branch other than `master` or `main`, commit and push as soon as the work is written, without asking for confirmation.
  - Subsections: [A pull request for every new branch](docs/instructions/git.md#a-pull-request-for-every-new-branch).
