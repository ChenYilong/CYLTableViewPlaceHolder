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
- The example's languages follow the core bundle's list where practical, and a
  test or script checks that every language has every key.

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
column. A build that produces no screenshot fails the job. Runs that change only
documentation skip the macOS builds and need no screenshot.

- When reporting CI results for a change that triggers a build, give the run
  link and the screenshot artifact names for every example. Describe a
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
