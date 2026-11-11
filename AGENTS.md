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
  `scripts/check_doc_comments.py` checks it in CI.

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
  `Animations/NOTICE.animations`, shipping the license text next to it.
  Keep the total small: every app that uses Core carries these files.
- Run `ruby Tests/run-tests.rb` for relevant simulator tests. Use `DESTINATION`
  to select an installed simulator. Build the example and validate the
  podspec when their integration changes; see `cyl-verify`.
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
  commit, push the branch, and open a pull request against `master`. Do not
  commit directly to `master` unless the user asks. Do not merge a pull request
  without the user's approval, and not before the `iOS` workflow is green.
- Follow the current task's instructions for commits, branches, and pull
  requests when they differ from the default above.
