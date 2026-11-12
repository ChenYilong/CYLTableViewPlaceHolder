# Agent rules for CYLTableViewPlaceHolder

This repository contains an Objective-C iOS table-view placeholder library,
the integrated `CYLRefresh` component, and an example application. Read
`instructions.md` and the relevant project skill before changing code.

## Source of truth

- Public headers under `CYLTableViewPlaceHolder/` define the current API.
- `README.md` documents integration and usage; `docs/issue-progress.md` records
  issue history and known limits. If they disagree, verify the code and update
  the affected documentation.
- Use the project skills in `.agents/skills/`: `cyl-api-map` for API locations,
  `cyl-xcode-compat` for project settings, `cyl-verify` for verification, and
  `cyl-docs` for documentation changes; `ios-accessibility`, `accessibility-audit` and `ios-localization` (copied from
  CYLTabBarController, with their upstream licenses) for accessibility and localization work.

## Naming and compatibility

- Follow the English naming rules in `instructions.md`: new project-owned
  classes use `CYL`; UIKit category files use `+CYL`; category methods and
  properties use `cyl_`, except required system overrides.
- Do not rename existing public symbols, serialized keys, or resources without
  assessing compatibility and obtaining approval for breaking changes.
- Preserve third-party copyright, license text, and original attribution. Do
  not replace an author's name with the project author's name.
- The library supports iOS 12.0; preserve that minimum in the podspec and
  guard newer APIs. Runnable projects' Podfiles follow the iOS 15.0 rules in
  `instructions.md`; their CocoaPods dependencies consequently require iOS 15.
- Preserve the Xcode project format: `objectVersion = 46`,
  `compatibilityVersion = "Xcode 3.2"`, explicit file references, and a shared
  scheme. Do not copy device identifiers or signing credentials from another
  machine.

- Public API documentation comments (`instructions.md`, "Code conventions"): every public declaration has one,
  placed directly above it. Several lines are one block comment, never stacked `///` lines: `/*! … */` in
  Objective-C headers (shown for Objective-C and the generated Swift interface), `/** … */` in Swift (Swift does
  not read `/*!`); other platforms follow their official style (KDoc / Javadoc / TSDoc `/** */`, Dart `///`).
  Single-line documentation comments of the public API use the same three-line block (`/*!`, ` * text`, ` */`; `/**`
  in Swift), never `/*! text */` on one line and never a trailing `/**< */`, `/*!< */`, `///<` or `//` after a
  declaration or enum value. Each public file uses one comment format for short and long comments. Every platform and
  language uses its documentation tool's block form the same way: `/** */` for Kotlin, Java, TypeScript, JavaScript,
  Rust and C# (with XML tags), a triple-quoted docstring on its own lines for Python, `/* */` for Go; a language
  without a block form (Dart) uses its only documentation form throughout the file. **The official rules decide**:
  where an item differs from a language's official documentation rules, the official rule wins (Go `//` doc comments
  per go.dev/doc/comment, Rust `///` per the Rust Style Guide, C# `///` with XML tags per Microsoft Learn, Python
  docstrings per PEP 257; Objective-C, Swift, Kotlin, Java, TypeScript, JavaScript and Dart agree with the rule). See
  the table in `instructions.md`, "Documentation comments on public API".
  `scripts/check_doc_comments.py` checks it in CI.

- Reuse `CYLPlaceholderView` in the core (`instructions.md`, "Reuse CYLPlaceholderView in the core"): core
  features show icons and text through `CYLPlaceholderView`, the packaged icon-and-title view, instead of fully
  custom views. "The packaged icon and title" means `CYLPlaceholderView`, not `CYLPlaceholderStackView`; every element
  inside a stack view is a `CYLPlaceholderView`. A custom view needs explicit approval.
- Always search for image-setting code (`setImages`, `setImage`, `.image =`, `animationImages`, `UIImageView`) and
  prefer `CYLPlaceholderView`'s image API (`CYLPlaceholderItemImage`, `CYLPlaceholderComponent`,
  `-cyl_setIconImages:duration:forState:`) over a system `UIImage` on a `UIImageView`. Where system image setting is
  unavoidable, a comment next to it says why `CYLPlaceholderView` is not used.

## Project and verification

- The main example (`Examples/Example`, Swift) embeds the project's own framework target
  (`CYLTableViewPlaceHolderFramework`, module `CYLTableViewPlaceHolder`) and does not require the
  former external refresh Pod or `pod install`. Keep the source files, the resource bundle,
  privacy manifest, and third-party license in the framework target, the app and the podspec.
- Examples contain no Objective-C. When Swift needs a better spelling of a core API, add a Swift
  naming macro (`NS_SWIFT_NAME`, `NS_REFINED_FOR_SWIFT`, `NS_SWIFT_UNAVAILABLE`) next to the
  Objective-C declaration; never change the Objective-C interface itself.
- CYLTabBarController is always a CocoaPods dependency. This project depends on its **latest commit by
  timestamp across all branches** (often not `master`), as `:git` plus `:commit`, never a version, tag or
  branch; resolve it with `scripts/resolve-cyltabbarcontroller-commit.sh` before every build. A project
  named CYLTabBarController uses `:path` relative to the folder holding its podspec instead. See
  "Depending on CYLTabBarController" in `instructions.md`.
- In the example layer, CYLTabBarController is integrated by default with a PlusButton that has a plus child
  view controller (`plusChildViewController`, its own page) and is initialized from a local configuration file in
  the example's own `.bundle` (`CYLTabBarController(configurationFile:)`; `CYLTabBarControllerPlusButton` with
  `CYLTabBarItemPageIdentifier`), unless a task says otherwise. See "Integrating CYLTabBarController in the
  examples" in `instructions.md`.
- **A raised plus button (added 2026-11-12)**: when an example demonstrates the plus button, always prefer the
  raised look: the top of the plus button reaches above the top edge of the tab bar (an image taller than the bar,
  and/or `+multiplierOfTabBarHeight:` below 0.5 or a negative
  `+constantOfPlusButtonCenterYOffsetForTabBarHeight:`), in every style (classic, Liquid Glass, FlatDesign). A
  demo that needs a flat plus button (inside the bar) says so in its title or comment.
- Every example Podfile (`Examples/*/Podfile`) also contains `pod 'MJRefresh', '<latest version>'`, the
  highest stable version on the CocoaPods trunk, set with `scripts/resolve-mjrefresh-version.sh` before every
  build (CI does it in `scripts/ci-build-example.sh`) and check the examples compile. If the newest MJRefresh
  breaks a build, fix the code in `CYLRefresh/` until it builds; never pin an older MJRefresh. See "Depending
  on MJRefresh in the examples" in `instructions.md`.
- iOS examples are written in Swift (the library stays Objective-C). When a Swift call
  reads like Objective-C, adapt the core: nullability, `NS_SWIFT_NAME` on new
  declarations, `cyl_` members keep their prefix, and underscored protocol methods get an
  underscore-free sibling instead of a rename. Follow CYLTabBarController's
  `docs/Swift-Guide.md` and record verified spellings in `docs/Swift-Guide.md`. See
  "Swift examples and a Swift-friendly core" in `instructions.md`.
- `README.md` and every document in `docs/` are bilingual (`中文 | English` two-column tables,
  `## 中文 / English` headings, `[CN]` / `[EN]` code comments); read only the English part. Attachments go
  in an `assets/` folder next to the document and are linked relatively. Run
  `python3 scripts/update-docs-navigation.py` after any change to them and never edit the generated
  navigation by hand. See "Bilingual documentation" in `instructions.md`.
- Localization is several files and always needs a file structure: on iOS,
  `<language>.lproj` folders inside a `.bundle`, never loose `.strings` files
  or hard-coded user-facing text. Several bundles are allowed, one per owner.
  The core bundle, `CYLTableViewPlaceHolder.bundle` (placeholder table
  `Localizable.strings`, refresh table `CYLRefresh.strings`), always stays and
  changes only additively. Each example keeps its text in its own bundle in the
  example folder, read through macros defined in a localization header. The core
  also has its own lookup macro. A project must define at least two different
  lookup macros, one per layer (core and example), each reading its own bundle;
  names carry the owner's prefix and never reuse another library's, such as
  CYLTabBarController's `CYLLocalizedString`. Every language must have every key
  of `en`. Other platforms follow the same
  structure. See "Localization" in `instructions.md`.
- Accessibility is required everywhere (VoiceOver, Voice Control, Switch Control, Dynamic Type, Reduce Motion): every
  control and text is an element with a localized label, trait and value; decorations are hidden; tappable placeholders
  are buttons (not enabled when interaction is off); Reduce Motion is honored; tests find elements by label first. A
  change without it is not done. See "Accessibility" in `instructions.md` and the `ios-accessibility` and
  `accessibility-audit` skills.
- Resources follow the localization split: the core reads only its bundle through `CYLPlaceholderResourceBundle()` /
  `CYLPlaceholderResourceURL(path)`, each example only its own bundle through its own lookup.
- Ready-made placeholder animations live in
  `CYLTableViewPlaceHolder.bundle/Animations/`, named `CYLPlaceholder<Scenario>.<ext>`.
  Add only animations whose content means a placeholder state (loading, empty,
  failed, missing permission, an offered action, done), never mascots, scenes or
  widget demos, which go to the example that uses them, in its own `.bundle`. The core bundle holds
  only placeholder resources. Add only files with a redistributable license, unmodified, and record each
  one's source repository, commit, path, license and SHA-256 in
  `Animations/NOTICE.animations`, shipping the license text next to it. One exception (approved 2026-11-12):
  a background fill baked into a file (an artboard fill, a "BG" shape) may be made transparent by setting
  its alpha to 0 and nothing else, when the license allows modification; NOTICE then records the change
  and both the original and the new SHA-256 (e.g. `CYLRefreshIcon.riv`).
  Keep the total small: every app that uses Core carries these files.
- Run `ruby Tests/run-tests.rb` for relevant simulator tests. Use `DESTINATION`
  to select an installed simulator. Build the example and validate the
  podspec when their integration changes; see `cyl-verify`.
- CI/CD (`instructions.md`, "CI/CD"): iOS jobs on GitHub run on macOS 26 by default
  (`vars.MACOS_RUNNER || 'macos-26'`). Always read CYLTabBarController's
  [`.github/workflows/ios.yml`](https://github.com/ChenYilong/CYLTabBarController/blob/master/.github/workflows/ios.yml)
  first to confirm the runner environment. Local runs (the developer's own Mac,
  not GitHub CI/CD, running the simulator and Xcode directly) ignore this and
  assume macOS 27 with Xcode 27.
- **Screenshots (added 2026-11-12)**: every screenshot, from CI/CD and from local builds, is saved in the
  repository with the related document in `docs/` (create the document when none fits; images in `docs/assets/`)
  and committed to git. Use clear original screenshots: never scaled down or recompressed; a crop that keeps the
  original resolution is allowed. When the result looks as expected, also update `README.md` with the latest
  screenshots, in the related section (create it when there is none). Every screenshot, in the document and in the
  README, is labeled with: the platform (iOS, Android, Flutter, React Native, HarmonyOS, WeChat Mini Program); the
  environment: operating system version, simulator or emulator (device model and OS version), and the SDK version
  of that platform (iOS SDK / Xcode, Android SDK / API level, Flutter SDK, React Native, HarmonyOS SDK, WeChat
  Mini Program base library); this repository's version or commit (with its link); and the time it was taken.
- **Screenshot moments and layout (added 2026-11-12)**: take and commit screenshots at key moments: when a TODO or
  Linux note can be removed, when a pull request can be merged, or when the result is judged as expected with no
  bug and no open issue. The README shows cropped key details, a full screen only when it is needed; several
  details go into one stitched image. Stitching order of preference: a vertical stack (one column, top to bottom),
  easiest to read on a phone; then two columns with several rows; last, a single horizontal row, at most three
  images in a row.
- Xcode 27's simulator SDK requires a deployment target of at least 15.0 during
  builds. Override the build target for that toolchain instead of changing the
  library's iOS 12.0 minimum.
- Every CI run that builds code must provide a screenshot of each example
  running (artifacts `example-screenshot-*` from the `Demo` jobs, shown inline
  by the `Example screenshots` job and its pull request comment). Link them
  when reporting CI results. If none can be produced, first fix the CI to
  produce it; if that still fails, state the concrete reason. See "CI example
  screenshots" in `instructions.md`.
- Update relevant documentation and skills with user-visible changes. Explain
  what could not be verified; do not claim a visual behavior from compilation.

## Commit readiness

- **Before every Commitizen-style (`git cz`) commit**, run this first in the repository root, so the vault's auto sync does not commit or push in the middle of it:

  ```sh
  mkdir -p .git/hooks && touch .git/hooks/NO_AUTO_SYNC
  ```

  If `.git/hooks` does not exist, `mkdir -p` creates it first so `touch`
  always succeeds.

- Before every commit, update `.gitignore`: add any ignore pattern from
  CYLTabBarController's `.gitignore` that is missing (changing only its project
  name to `CYLTableViewPlaceHolder`), and make sure every generated or
  machine-local file of the change is ignored. Already tracked files stay
  tracked. See "`.gitignore` before every commit" in `instructions.md`.
- Before a Commitizen-style commit, follow the commit-message hook instructions
  in `instructions.md`; inspect an existing hook before replacing it.
- Before every commit, audit the changed code and the project's comparison,
  issue-progress, and implementation-status documents.
- In the most relevant existing document under `docs/`, keep a `TODO` entry for
  every tracked item below 100% complete and verified. Include its current
  score, concrete remaining work, implementation and verification notes, and
  any known defects or optimization opportunities.
- Review API design explicitly: record compatibility and migration risks,
  ambiguous or inconsistent keys, unsupported behavior, and lifecycle or
  accessibility gaps. Reserved keys, stubs, compilation, and unverified visual
  behavior do not qualify as completion.
- Update scores only when supported by implementation and test evidence. Before
  staging, verify that each sub-100 item in the relevant score tables has a
  matching `TODO` entry and that the documented limitations match the code.
- Every commit message must contain the owner's line `By @ChenYilong <luohanchenyilong@163.com>`, on
  its own line at the end of the body (before trailers such as `Co-Authored-By:`), exactly once. See
  "Author line in every commit message" in `instructions.md`; the commit-msg hook there appends it.
- Use an English Conventional Commit subject compatible with Commitizen. The
  subject summarizes completed work; put details and pending work in the body.
  If the detailed description exceeds 50 characters, create or update a
  suitable document under `docs/` and link it in the commit body. Reuse the
  existing tracker and avoid duplicate documents.
- Follow the Commitizen defaults: `{type}{scope}: {emoji}{subject}`, emojis
  enabled, no predefined scopes, and a 3–64 character message. The interactive
 examples separate the emoji from the subject with a space. The
  type list is `test`, `feat`, `fix`, `chore`, `docs`, `refactor`, `style`,
  `ci`, `perf`; `release` is defined but not listed. Default emojis are
  `chore` 🤖, `ci` 🎡, `docs` ✏️, `feat` 🎸, `fix` 🐛, `perf` ⚡️,
  `refactor` 💡, `style` 💄, `test` 💍, and `release` 🏹. Follow established
  project emoji mappings where they differ (e.g. CYLTabBarController uses
  `feat: ✨`, `docs: 📝`, `chore: 🔧`, and `refactor: ♻️`). The question
  sequence is `type`, `scope`, `subject`, `body`, `breaking`, `issues`, and
  `lerna`;
  prompts cover optional scope, imperative subject, longer description,
  breaking changes, issue references, and affected packages.

## Git

- Never commit AppleDouble files named `._*`. Follow the vault's cleanup rule
  before Git commands and check staged paths before committing.
- Do not overwrite another person's changes or rewrite pushed history.
- On any branch other than `master` or `main`, commit and push as soon as the
  work is written, without asking the user first. Still follow the commit
  readiness rules above. On `master` or `main`, do not commit or push unless
  the user asks.
- Commit through a branch and a pull request by default, so CI runs
  (`docs/CI-CD.md`): branch from `master`, `mkdir -p .git/hooks && touch .git/hooks/NO_AUTO_SYNC`,
  commit, push the branch, and open a pull request (target: see the next rule). Do not
  commit directly to `master` unless the user asks. Do not merge a pull request
  without the user's approval, and not before the `iOS` workflow is green.
- **Upstream projects used for translation (added 2026-11-12)**: when a document of this project links to another
  project's GitHub repository that is the source of a translation or port (for example the projects ported to
  Kotlin in the Android folder), do not translate only its default branch. (1) Pull requests: visit the upstream's
  open pull requests and bring them in. If the translation has not started, merge the open pull requests into the
  source first; if it is already done, translate each open pull request's change and merge it into our port. (2)
  Issues: list the upstream's open issues in a table in the related document in `docs/` (create one when none
  fits): column 1 the issue link, column 2 its description, column 3 the fix status (`TODO` by default). Find each
  issue's counterpart in our code and try to fix it. (3) Score: 100 means every listed issue is resolved; give a
  score after each fix and continue until 100. (4) Order: for a translation not started yet, merge the open pull
  requests, fix issues until the score reaches 60, translate, then fix the remaining issues up to 100; for a
  finished translation, translate and merge the open pull requests, then fix the issues on the translated code up
  to 100. The same rule applies to every platform.
- **Record every task in `docs/` before starting it (added 2026-11-12)**: before any task, find the most relevant
  existing document in `docs/` (create one only when none fits) and add a `TODO` entry with the task's full context,
  the user's requirements, and the user's prompt quoted verbatim. Then start the work. When the task is finished,
  change that entry to `DONE` with the result and its evidence (commits, tests, screenshots). Purpose: if the work
  is interrupted, the next session can find the context again.
- **Every new branch gets a pull request, automatically (added 2026-11-12)**: after creating a branch and pushing
  its first commit, open a pull request right away, without asking. Target branch: the branch it was created from
  (preferred); otherwise `main` or `master`.
- Follow the current task's instructions for commits, branches, and pull
  requests when they differ from the default above.
