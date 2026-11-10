# Folder instructions

This repository contains an Objective-C table-view placeholder library, an
integrated refresh component, and an iOS example. It inherits the vault's root
instructions. Read `AGENTS.md` before changing the project.

## English naming rules

- Write repository instructions, skill instructions, and new identifier names in English.
- Prefix new project-owned Objective-C class names and corresponding class
  filenames with `CYL`, following `CYLRefreshComponent`.
- Name UIKit category files `<SystemClass>+CYL<Feature>.h` and `.m`, and prefix
  new category selectors and properties with `cyl_`. Objective-C property
  setters use `setCyl_`. Do not rename required system overrides such as `load`.
- Use `CYL` for project-defined type and constant prefixes. Do not copy
  unrelated vendor prefixes into new project APIs.
- These rules apply to new or intentionally migrated code. Do not silently
  rename an existing public API or break callers; document and explicitly
  approve breaking changes.
- Retain required third-party copyright notices, licenses, and source
  attribution even when they contain original names or URLs. Never claim
  third-party code as original work.

## Xcode and CocoaPods project checks

When working on a runnable Xcode project, check its Podfile. At the top, use
the `.xcodeproj` filename in the same folder:

```ruby
platform :ios, '15.0'
ENV['SWIFT_VERSION'] = '5'
project '<projectname>.xcodeproj'
```

At the bottom, ensure the following `post_install` logic is present. If a
`post_install` hook already exists, incorporate the logic into that hook
instead of adding a second hook:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "15.0"
    end
  end
end
```

These settings apply to the runnable project's CocoaPods integration; they do
not by themselves change the library podspec's supported iOS version.

Check whether the app has a launch screen and an app icon with image assets.
If either is missing, copy the corresponding icon and custom launch screen from
`CYLTabBarController`, include their dependent assets and target membership,
and verify the result builds. Do not overwrite existing project assets.

## Swift examples and a Swift-friendly core

iOS examples are written in Swift; the library stays Objective-C. The core adapts to the Swift call site, not the other way round.

### Examples

- Every iOS example under `Examples/` is Swift: new examples start in Swift, and an
  existing Objective-C example is migrated (tracked in `docs/issue-progress.md`).
  Do not add Objective-C source to an example. Use `@main` or a `UIApplicationDelegate`
  and scene delegate in Swift, never `main.m`.
- The rule covers example apps and their UI tests. It does not cover the library
  source, its Objective-C header API, or the library's XCTest suite under `Tests/`, which
  exercises that API.
- Examples import the library as a module (`import CYLTableViewPlaceHolder`; the
  Podfiles already use `use_frameworks!`) and need no bridging header.
- Directory names such as `Example-objc-01` are tied to schemes, CI matrix entries and
  artifact names. Do not rename a folder because its language changed; note the mismatch in
  the folder's `instructions.md`.
- A Swift example must follow the Swift API Design Guidelines. If calling the
  library reads like Objective-C, fix the API in the core (below) instead of wrapping it in
  every example.

### Making the Objective-C core Swift-friendly

1. **Nullability.** Wrap every public header in `NS_ASSUME_NONNULL_BEGIN/END` and mark the
   exceptions `nullable`, so Swift sees `T` and `T?` rather than `T!`. Use lightweight
   generics on collections and `NS_ENUM`/`NS_OPTIONS`/`NS_STRING_ENUM` for constants.
2. **Names.** Add `NS_SWIFT_NAME` to *new* declarations whose imported name is not idiomatic.
   Follow the pattern in CYLTabBarController's Swift guide
   ([`docs/Swift-Guide.md`, section "Objective-C → Swift 命名对照"](https://github.com/ChenYilong/CYLTabBarController/blob/master/docs/Swift-Guide.md)):
   `With…`/`For…`/`At…`/`Of…` become argument labels, enum values drop the type prefix,
   notification names drop the `Notification` suffix, and factory methods become initializers
   or `static` members. Example from that guide: `-cyl_showBadgeValue:animationType:` is
   called as `cyl_showBadgeValue(_:animationType:)`.
3. **`cyl_` members stay `cyl_` in Swift.** Category methods and properties keep the prefix
   (`scrollView.cyl_header`, `scrollView.cyl_footer`, `beginRefreshing()`), and so do
   Swift extensions of system types written in this repository (`Color(cyl_hexString:)`).
   Look up how CYLTabBarController adapted the equivalent method before inventing a
   spelling, and record the result in `docs/Swift-Guide.md`.
4. **Underscores in protocol methods.** Swift method names should not contain underscores.
   For a method that has already shipped, never rename it and never add `NS_SWIFT_NAME` to
   it, which would change an existing Swift API. Add a second method whose name is the same
   without the underscore (keep the `cyl` prefix, for example `-cyl_playX` and
   `-cylPlayX`), give only the new one `NS_SWIFT_NAME`, make the old one `@optional`, and have
   the library call the new one when it is implemented and the old one otherwise. For a
   method introduced in the same unreleased change, name it correctly once.
5. **Compatibility.** Existing public symbols, serialized keys and resources are not renamed
   or removed to please Swift without approval; add the Swift-friendly spelling beside them
   (see "English naming rules").
6. **Prove it from Swift.** A Swift call site that compiles is the test. Use it in an example
   (the `Demo` jobs build every example) or a Swift test, and add the verified spelling to
   `docs/Swift-Guide.md`. Do not document a Swift spelling that no Swift code in the
   repository has compiled.

## Localization

Localization is always several files: one per language, often several tables
per language. Never leave them loose in a target or folder; package them in a
defined file structure.

### iOS: `.lproj` folders inside a `.bundle`

- Put each language's files in a `<language>.lproj` folder and all of those
  folders in one `.bundle`. One bundle may hold several strings tables; give
  each component its own table (`<Table>.strings`) so keys cannot collide.
- Several bundles are allowed, one per owner (library, example). Never add
  loose `.strings`, `.stringsdict` or `.xcstrings` files to a target, and never
  put one owner's strings in another owner's bundle.
- Keep `.strings` files UTF-8, one `"key" = "value";` per line. Every language
  of a table has every key of `en`; add a test that checks it.
- Do not hard-code user-facing text in code; read it from the bundle with a
  fallback.

### The core bundle is permanent

`CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.bundle`
is the library's bundle. Always keep it and update it cautiously: apps copy it
in manual integrations, look it up by name, and override its tables through
`CYLRefreshConfig` (`i18nBundle`, `i18nFilename`).

- Changes are additive: new keys, languages or tables. Do not rename or remove
  the bundle, a table or a key without assessing compatibility, getting
  approval, and writing migration notes in `README.md`.
- Current tables: `<language>.lproj/Localizable.strings` (placeholder,
  `CYLPlaceholder…` keys) and `<language>.lproj/CYLRefresh.strings` (refresh,
  `CYLRefresh…` keys; key constants in `CYLRefreshConst.h`). `CYLRefresh.bundle`
  was merged into this bundle.
- Both tables support `en`, `zh-Hans`, `zh-Hant`, `ja`, `ko`, `ru`, `uk`.
  Adding a language means adding both tables and listing it in
  `CYLPlaceholderLocalizedString` (`CYLPlaceholderView.m`) and
  `cyl_defaultI18nBundleWithLanguage:` (`NSBundle+CYLRefresh.m`).
  `testPlaceholderLocalizationsHaveAllMessageKeys` and
  `testRefreshResourcesLiveInTheSingleLibraryBundle` check every key in every
  language.
- Library resources reach the podspec `resources`, the Xcode project's Copy
  Bundle Resources phases and the test runners only through this bundle.
- Only the library's own text belongs here; example text never does.

### Example-level bundles, always with macros

Each example keeps its own text in its own bundle inside the example folder,
for example `Examples/Example-Scenarios/Sources/CYLScenarioExample.bundle/
<language>.lproj/CYLScenarioExample.strings`, added to that example's target
only.

- Always create a localization header next to it that defines macros, so the
  mapping between code, keys and translations is in one place and easy to
  search, review and translate:

  ```objc
  // CYLScenarioLocalization.h
  #define CYLScenarioLocalizedString(key) \
      [CYLScenarioLocalizationBundle() localizedStringForKey:(key) value:(key) table:@"CYLScenarioExample"]
  #define CYLScenarioL10nEmptyTitle      @"CYLScenarioEmptyTitle"
  #define CYLScenarioL10nRetry           @"CYLScenarioRetry"
  ```

  Code uses only these macros, never raw key strings or literal text. One key
  macro per string; the lookup macro names its table.
- The example's languages follow the core bundle's list where practical.
  `scripts/check_localizations.py` (CI job "Localization files") checks every
  bundle in the repository: same keys and format specifiers in every language,
  macros that match the keys, and no loose `.strings` files. Run it before
  committing a localization change.
- API, file and subspec names shown as technical hints are identifiers, not
  text, and stay as literals.

### Other platforms

Apply the same structure: per-language files grouped in one resource
container per owner, the library's container kept and changed additively, each
example with its own container, and a single generated or hand-written key map.

- Android: `res/values-<locale>/strings.xml` in the library module and in each
  sample app module; `R.string.*` is the key map.
- Flutter: `lib/l10n/*.arb` per package with the generated localizations class.
- Web and React Native: a `locales/<locale>.json` folder per package with one
  exported constant object of keys.

## Bundled animations

`CYLTableViewPlaceHolder.bundle/Animations/` ships ready-made placeholder
animations with Core: Lottie `.json`, PAG `.pag`, Rive `.riv` and GIF `.gif`,
named `CYLPlaceholder<Scenario>.<ext>` and found with
`+[CYLPlaceholderView pathForBundledAnimation:]`.

- Download only from sources whose license allows redistribution (for example
  the engines' own Apache-2.0 or MIT repositories); community marketplaces with
  unclear terms are not acceptable sources. Keep the files unmodified.
- For every file, add an entry to `Animations/NOTICE.animations` (source
  repository, commit, original path, license, SHA-256) and ship the license
  text as `Animations/LICENSE.<source>`. Verify Git LFS files against their
  pointer's SHA-256 after downloading.
- Every app that uses Core carries these files; keep each small (well under
  100 KB) and the total around 300 KB. Prefer vector Lottie without images.
- `testBundledAnimationsAreListedValidAndAttributed` checks the count, each
  format's header and the NOTICE entry; update its expected count when adding
  a file. The aggregated demo (`Examples/Example-Scenarios`) lists every file.

## CI example screenshots

Every CI run that builds code must provide a screenshot of each example app
running. The `Demo` jobs in `.github/workflows/ios.yml` run
`scripts/ci-build-example.sh <folder>`, which builds the example, installs and
launches it on an iPhone simulator, and saves `build/screenshots/<scheme>.png`.
The workflow uploads it as the artifact `example-screenshot-<folder>` (`.`
becomes `Example`, `/` becomes `-`), and the job summary shows a Screenshot
column. The `Example screenshots` job then shows all of them inline in its
summary and in one pull request comment, from the `ci-screenshots` branch
(`docs/CI-CD.md`). A build that produces no screenshot fails the job. Runs that change only
documentation skip the macOS builds and need no screenshot.

- When reporting CI results for a change that triggers a build, give the run
  link, the screenshot artifact names for every example, and the pull
  request's screenshot comment when there is one. Describe a
  screenshot only if you have actually viewed it; a launch screenshot shows the
  first screen and does not verify interactions or animations.
- If a screenshot cannot be produced, first change the CI script or workflow
  so that it is produced. Only if that still fails, state the concrete reason
  (for example, the runner has no iOS simulator runtime, or the app crashes on
  launch, with the relevant log lines) and record it under Known limits in
  `docs/CI-CD.md`.
- On a Mac, `scripts/ci-build-example.sh <folder>` produces the same
  screenshot locally; `SCREENSHOT_DELAY` (seconds, default 8) waits longer for
  the first frame.

## Commit readiness and TODO tracking

### `.gitignore` before every commit

Before every commit, update `.gitignore`:

1. Compare it with CYLTabBarController's `.gitignore`
   (https://github.com/ChenYilong/CYLTabBarController/blob/master/.gitignore).
   Add every ignored file and folder pattern it has that this file lacks, in
   the section "Synced from CYLTabBarController's .gitignore". Change only
   what does not match this project: replace `CYLTabBarController` with
   `CYLTableViewPlaceHolder` in paths. Leave out paths that exist only in
   CYLTabBarController (its example folders) and say so in the section's
   comment.
2. Run `git status --short` and `git ls-files -o --exclude-standard`. Every
   generated or machine-local file the change produced (build products,
   `Pods/`, user data, caches, `._*`) must be ignored; add a pattern for any that
   is not.
3. `.gitignore` does not untrack committed files. The `Podfile.lock` files and
   workspaces already in the repository stay tracked although `*.lock` and
   `*.xcworkspace` are ignored; do not remove them from the index without the
   user's approval. Use `git add -f` only for a file that must be committed
   despite a rule, and say why in the commit body.

Before every commit, review the current changes and all project comparison,
parity, issue-progress, and implementation-status documents. For every item
that is not fully complete and verified at 100%, ensure a corresponding entry
exists under a `TODO` heading in the most relevant document under `docs/`.
Use an existing relevant document when possible; do not create duplicate
tracking documents.

Each `TODO` entry must identify the incomplete behavior and current score,
describe the remaining work and implementation constraints, and state how it
will be verified. Explicitly document known defects, compatibility risks, and
optimization opportunities. Review public and serialized API design in
particular: identify missing behaviors, inconsistent keys, ambiguous values,
unsupported backends, lifecycle or accessibility gaps, and migration concerns.
Do not treat reserved keys, stubs, successful compilation, or unverified visual
behavior as complete.

After addressing an item, update its status and score from code and test
evidence. Keep every remaining sub-100 item listed with the literal keyword
`TODO`; do not remove a limitation merely because it was attempted. Before
staging, confirm that the documentation covers every sub-100 row in the
relevant score tables and that the descriptions match the current code.

Use an English Conventional Commit subject compatible with Commitizen. The
subject summarizes completed work; use the body for details and pending tasks.
If the detailed description exceeds 50 characters, create or update a suitable
document under `docs/` and link it in the commit body. Reuse the relevant
existing tracker and avoid duplicate documents.

### Commitizen defaults

- Use `{type}{scope}: {emoji}{subject}` with emojis enabled. Omit an unnecessary
  scope; no scopes are preconfigured. The configured message length is 3–64
  characters. In readable subjects, separate the emoji and subject with a
  space as shown in the project examples below.
- The interactive type choices, in order, are `test`, `feat`, `fix`, `chore`,
  `docs`, `refactor`, `style`, `ci`, and `perf`. `release` has a type definition
  but is not an interactive choice; use it only for an intentional release.
- Default meanings and emojis: `chore` (build or auxiliary-tool changes, 🤖),
  `ci` (CI changes, 🎡), `docs` (documentation only, ✏️), `feat` (new feature,
  🎸), `fix` (bug fix, 🐛), `perf` (performance improvement, ⚡️), `refactor`
  (neither a feature nor a fix, 💡), `style` (markup or formatting only, 💄),
  `test` (adding missing tests, 💍), and `release` (release commit, 🏹).
- The question sequence is `type`, `scope`, `subject`, `body`, `breaking`,
  `issues`, and `lerna`. Prompts request the type, optional scope, short
  imperative subject, longer description, breaking changes, issues closed
  (for example `#123`), and affected packages.
- Respect established repository history when it uses project-specific
  mappings. CYLTabBarController examples include `feat: ✨`, `fix: 🐛`,
  `docs: 📝`, `chore: 🔧`, and `refactor: ♻️`. Commit text must remain English.

### Commit-message hook before Commitizen commits

Before a Commitizen-style commit, run the following from the repository root:

```sh
mkdir -p .git/hooks
cat > .git/hooks/commit-msg << 'HOOKEOF'
#!/bin/sh
tmpfile="$1"
if grep -qi "Co-Authored-By:" "$tmpfile" 2>/dev/null; then
  tmp_clean=$(mktemp)
  grep -vi "Co-Authored-By:" "$tmpfile" > "$tmp_clean"
  cat "$tmp_clean" > "$tmpfile"
  rm -f "$tmp_clean"
fi
HOOKEOF
chmod +x .git/hooks/commit-msg
```

`mkdir -p` creates `.git/hooks` when it is missing, so writing the hook
always succeeds. This overwrites the existing `commit-msg` hook and removes every line containing
`Co-Authored-By:`, case-insensitively, including other authors' attribution.
Inspect any existing hook before replacing it. The command assumes `.git` is
a directory and Git uses its default hooks path; linked worktrees and custom
`core.hooksPath` require the appropriate hooks path instead.

## Commitizen commits

Before every Commitizen-style (`git cz`) commit, run this first in the repository root:

```sh
mkdir -p .git/hooks && touch .git/hooks/NO_AUTO_SYNC
```

If the directory does not exist (for example in a fresh clone or a container
without sample hooks), `mkdir -p` creates it first so `touch` always succeeds.

## Committing on branches

On any branch other than `master` or `main`, commit and push as soon as the
work is written, without asking for confirmation. Follow the commit readiness
and Commitizen rules above. On `master` or `main`, commit or push only when the
user asks; otherwise create a branch and open a pull request (`docs/CI-CD.md`).
