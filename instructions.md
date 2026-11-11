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

## Code conventions

### Documentation comments on public API

Callers read the public API through generated documentation: Xcode Quick Help, the generated Swift interface of an
Objective-C header, IDE hovers and documentation tools. Only documentation comments reach them, and a description that
spans several lines must reach them as one comment.

- **Every public declaration has a documentation comment**: classes, protocols, methods, properties, enums and their
  cases, constants, functions, and macros that are part of the API. A plain `//` comment is not documentation and is
  not shown to callers; use it only for implementation notes inside code.
- **Several lines are one block comment, never stacked single-line comments.** In iOS projects (Objective-C public
  headers) write:

  ```objc
  /*!
   * [EN] What the declaration does, its parameters and return value, and what callers must know.
   * [CN] 中文说明（双语注释规则见 "Comments in code"）。
   */
  - (void)example;
  ```

  Clang attaches `/*! … */` to the declaration that follows, so Xcode shows it for the Objective-C API and for the
  Swift interface generated from the header.
- **Single-line comments use the block format too.** A one-line documentation comment of the public API is written
  like a multi-line one, as a three-line block above the declaration:

  ```objc
  /*!
   * One sentence.
   */
  - (void)example;
  ```

  Do not write `/*! One sentence. */` on one line, and do not put a trailing comment after a declaration or an enum
  value (`/**< */`, `/*!< */`, `///<` or `//`); move it into a block above it.
- **One format per public file.** A file that holds public API uses a single documentation-comment format for every
  comment, short or long, so callers and readers see the same form everywhere.
- **Swift sources of the library**: Swift's documentation parser reads `///` and `/** … */`, not `/*!`. Every
  documentation comment is the same three-line block with `/**` (`/**`, ` * text`, ` */`); no `///`.
- **Placement**: directly above the declaration, with no blank line or other code in between; the first sentence
  summarizes. Keep the `[EN]` / `[CN]` pair of a bilingual comment inside the same block. Never put `*/` in the text.
- **Every platform and language** follows the same rule with the block form of its documentation tool, the opening
  and closing markers on their own lines, one line of text or several:
  - Kotlin (KDoc), Java (Javadoc), TypeScript and JavaScript (TSDoc / JSDoc): `/** … */`.
  - Python: a docstring in triple quotes, the opening and closing `"""` on their own lines.
  - Go: `/* … */`.
  - C#: `/** … */` with XML documentation tags (`<summary>`, `<param>`, `<returns>`).
  - Rust: `/** … */`.
  - C / C++: Doxygen `/** … */` or `/*! … */`, one of them per file.
  - A language without a block form for documentation uses its single documentation form throughout the file.
- **The official rules decide.** Every comment format follows the official documentation rules of its language;
  where an item above differs from them, the official rule wins, and the file still uses one format throughout.
  Checked against the official sources (2026-11-11):

  | Language | Official source | What it says | Format used |
  | --- | --- | --- | --- |
  | Objective-C | Clang documentation comments, Apple HeaderDoc | `/*! */`, `/** */` and `///` are all documentation comments | the three-line `/*!` block (no conflict) |
  | Swift | DocC, "Writing symbol documentation in your source files" | `///` or a block starting with `/**` and ending with `*/` | the three-line `/**` block (no conflict) |
  | Kotlin, Java | KDoc, Javadoc | comments start with `/**` and end with `*/` | the three-line `/**` block (no conflict) |
  | TypeScript, JavaScript | TSDoc, JSDoc | `/** */` | the three-line `/**` block (no conflict) |
  | Dart | Effective Dart, "DON'T use block comments for documentation" | `///`, never `/** */` | `///` throughout the file |
  | Go | go.dev/doc/comment | doc comments are the `//` comments right before a declaration; `/* */` appears only for long package or command comments; short end-of-line comments may document struct fields and grouped constants | `//` doc comments as the page shows |
  | Rust | Rust Style Guide, "Doc comments" | "Prefer line comments (`///`) to block comments (`/** ... */`)"; outer `///`, inner `//!` only for modules and crates | `///` throughout the file |
  | C# | Microsoft Learn, "XML documentation comments" | the `///` delimiter is what the documentation and the project templates use; `/** */` is also accepted | `///` with XML tags throughout the file |
  | Python | PEP 257 | a one-line docstring keeps the closing quotes on the same line as the opening ones; in a multi-line docstring the summary may sit on the opening line and the closing quotes go on a line of their own | PEP 257 docstrings |

  When a platform's official rule changes, update this table and follow it.
- **Checking**: `python3 scripts/check_doc_comments.py` (CI job "Docs navigation") fails on any `///` line, a one-line
  block, an opening marker with text after it, a line inside a block that does not start with `*`, a trailing comment
  after code, a `/** … */` block in a public Objective-C header, or a `/*! … */` block in a library Swift file. Review
  new public declarations for a missing documentation comment by hand.

### Reuse CYLPlaceholderView in the core

- The core reuses its existing views as far as possible instead of building fully custom ones. A new core feature
  (a HUD, a status view, a refresh state, a component) shows its icon and text through `CYLPlaceholderView`, the
  packaged icon-and-title view, configured with item attributes (`CYLPlaceholderComponent`,
  `initWithItemAttributes:imageBundle:error:`), not through new drawing views, shape layers or hand-made labels.
- "The packaged icon and title" means `CYLPlaceholderView`, not `CYLPlaceholderStackView`. The stack view only
  arranges components: every element inside a `CYLPlaceholderStackView` is a `CYLPlaceholderView`, nothing else.
- When `CYLPlaceholderView` cannot show something yet (a percentage, a new state), extend it through its attributes
  or put the information into its title, rather than adding a custom view beside it. A custom view needs the
  user's explicit approval.
- Example: `CYLPlaceholderHUD` shows loading, progress and results in one `CYLPlaceholderView` inside its stack view;
  progress scrubs an animation or adds the percentage to the title, with no drawn ring.

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

## Depending on CYLTabBarController

This project always integrates CYLTabBarController through CocoaPods: never Swift Package Manager,
Carthage, copied or vendored sources. Which form the `pod` line takes depends on the project's name.

### Not named CYLTabBarController (this project, and every other): by commit

Depend on the **latest commit** of CYLTabBarController, written as a commit, never as a version, tag
or branch name (`'~> 1.99.72'`, `:tag`, `:branch`, and a bare `pod 'CYLTabBarController'` are not allowed):

```ruby
pod 'CYLTabBarController', :git => 'https://github.com/ChenYilong/CYLTabBarController.git',
                           :commit => '<40-character commit>'
```

- **"Latest" means the newest timestamp on any branch.** The newest work often lives on a feature or
  `claude/…` branch, not on `master` or `main`; the default branch's tip, `HEAD`, a release tag and
  `git ls-remote` order are all wrong. Compare the committer date of the branch tips as instants (the
  dates carry different time zone offsets, `+13:00` next to `+00:00`).
- **Find it before every build**, local or CI, in every Podfile that names CYLTabBarController (examples,
  scratch projects), and write the full 40-character commit into it. Never leave an older commit in place:

  ```sh
  scripts/resolve-cyltabbarcontroller-commit.sh                      # prints: <sha> <date> <branch>
  scripts/resolve-cyltabbarcontroller-commit.sh --write Examples/*/Podfile
  ```

  The script does what this by hand does: it clones only the commit history,
  `git clone --bare --filter=blob:none <repo> r`, and takes
  `git -C r for-each-ref --sort=-committerdate --count=1 refs/heads`.
- Then run `pod install`; when a `Podfile.lock` already pins an older commit, run
  `pod update CYLTabBarController` instead. The lock's `CHECKOUT OPTIONS` records the commit.
- Put the adopted commit (sha, branch, date) in the commit message body of a change that moves it, and
  print it in the CI log.
- Everything else this project takes from CYLTabBarController (CI fixture checkouts, a sibling
  `../CYLTabBarController` clone) uses the same resolved commit, not `master`.
- If the newest commit does not install or build, do not quietly pin an older one: report the commit and
  the error. Moving off "latest" needs the user's approval.

### Named CYLTabBarController: local path

When the project is CYLTabBarController itself, depend on the local copy instead, with a path relative
to the Podfile, to the folder that contains `CYLTabBarController.podspec`:

```ruby
pod 'CYLTabBarController', :path => '../..'
```

Find that folder by searching upward from the Podfile for the podspec; never write an absolute path.

### Integrating CYLTabBarController in the examples

Unless a task says otherwise, every example that shows a CYLTabBarController
integrates it the same way:

- **With a PlusButton that has a plus child view controller**: the plus button
  owns a page of its own (`plusChildViewController`), so tapping it selects that
  page like a tab instead of only running an action.
  `-[CYLTabBarController hasPlusChildViewController]` is YES once it is set up.
- **Initialized from a local configuration file**: the tabs, their titles and
  images, and the plus button are described in a file inside the example's own
  `.bundle` (for example
  `CYLScenarioExample.bundle/TabBar/tabbar.json`), read through the example's
  resource lookup, and passed to CYLTabBarController's configuration
  initializer: Swift `try CYLTabBarController(configurationFile: path)`,
  Objective-C `+tabBarControllerWithConfigurationFile:error:`. The file uses
  CYLTabBarController's configuration keys (`docs/Configuration-File.md` in
  that repository): `CYLTabBarControllerPlusButton` describes the plus button
  (`CYLTabBarItemTitle`, `CYLTabBarItemImage`, and `CYLTabBarItemPageIdentifier`
  for the plus button's own page), and each tab names its page with
  `CYLTabBarItemPageIdentifier`, resolved through CYLTabBarController's page
  registry.
- Code only adds what a file cannot hold: registering the pages for the page
  identifiers, a `CYLTabBarControllerPlusButtonAction` block, or a
  `CYLPlusButton` subclass when the layout needs one (it then still implements
  `+plusChildViewController`).
- The titles in the file are localization keys of the example's bundle, read
  through the example's lookup macro; the plus button gets a localized
  accessibility label (see "Localization" and "Accessibility").
- Before writing the file or the code, read the API in the CYLTabBarController
  commit the example resolves (`scripts/resolve-cyltabbarcontroller-commit.sh`):
  `CYLTabBarController.h` (configuration keys, `CYLTabBarController(configurationFile:)`)
  and `CYLPlusButton.h` (`+plusChildViewController`,
  `+cyl_registerPlusButtonWithAttributes:action:context:`).
- An example that differs (no plus button, a plus button without a page, tabs
  built in code) does so only when the task asks for it, and says why in a
  comment where the tab bar controller is created.

## Depending on MJRefresh in the examples

`CYLRefresh` is adapted from MJRefresh. So that an example always builds and runs with the original library
next to it (name clashes, duplicate symbols, the "MJRefresh controls stay above the placeholder" behavior),
**every example's Podfile also contains MJRefresh at its latest version**, in the app target:

```ruby
pod 'MJRefresh', '<latest version>'
```

- **"Latest version" means the highest stable version on the CocoaPods trunk** (digits and dots only, no
  pre-release), not a `~>` range and not the newest GitHub tag. Find it before every build and write the exact
  version into every example Podfile:

  ```sh
  scripts/resolve-mjrefresh-version.sh                           # prints the version
  scripts/resolve-mjrefresh-version.sh --write Examples/*/Podfile
  ```

  The script reads the CocoaPods CDN index, the one `pod` resolves from, so it needs only `curl`.
  `scripts/ci-build-example.sh` runs it before `pod install`, so CI always builds with the newest version.
- Run `pod install`; when a `Podfile.lock` pins an older version, `pod update MJRefresh`.
- **Check that the example still compiles and launches**: the `Demo` CI job builds it and saves a screenshot
  ("CI example screenshots"). Report the version that was built.
- **If it does not compile, link or launch, change the code in `CYLTableViewPlaceHolder/CYLRefresh/`** (the
  adapted copy of MJRefresh) and build again, repeating until every example builds and launches. Never pin
  an older MJRefresh to get green. Keep each fix compatible (the public API rules still apply), record the
  cause and the change in `docs/issue-progress.md`, and add a test when the failure can be reproduced. A
  cause outside `CYLRefresh/` is fixed where it is and named in the report; a defect inside MJRefresh itself
  is worked around on our side and reported.
- The main app at the repository root (`Examples/Example`, built through the root `Podfile`) embeds the
  project's own framework target and promises no `pod install`; it is not covered by this rule.

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

### Lookup macros: one per layer, at least two per project

Every layer that ships localized text reads it through exactly one lookup macro
that resolves that layer's bundle. A *layer* is an owner of a bundle: the core
library and each example. Code never reads a bundle any other way.

- **Core macro (required).** The core defines one macro in a header of the library
  folder. It reads only the core bundle, `CYLTableViewPlaceHolder.bundle`, names the
  strings table, and takes a fallback, so a missing bundle, language or key still shows
  text. All core code (placeholder and refresh) reads its strings through it; helpers
  such as `+[NSBundle cyl_localizedStringForKey:]` may stay only as thin wrappers over
  the same function.
- **Example macro (required for every example with text).** Each example defines its
  own macro in its localization header (see below). It reads only that example's bundle.
- **Same shape everywhere.** The macro expands to an exported function, so Swift code
  (examples are Swift) can call the function; function-like macros are not imported into
  Swift. Declare the function with `NS_FORMAT_ARGUMENT` when the value is used as a
  format string, as CYLTabBarController does for `CYLLocalizedString`. The function picks
  the language explicitly with `+[NSBundle preferredLocalizationsFromArray:forPreferences:]`
  over the layer's fixed language list, then falls back to English, then to the fallback or
  the key.
- **Names.** Each macro carries its owner's prefix and must never reuse another library's
  name. `CYLLocalizedString` belongs to CYLTabBarController, and `Example-Scenarios`
  links both libraries, so neither this core nor an example may define that name. Use
  names such as `CYLPlaceholderLocalizedString` (core) and `CYL<Example>LocalizedString`
  (example).
- **Other platforms.** The same rule with the platform's nearest construct, one per layer,
  always reading a folder or package of per-language files: an `R.string` accessor per
  module on Android, the generated localizations class per package on Flutter, one exported
  lookup function per package on Web and React Native.

**Acceptance criterion.** A project passes only if it defines at least two different
lookup macros, each reading a different layer's bundle: the core macro and at least one
example macro. One macro that serves both layers, or two macros that read the same
bundle, do not count. In addition:

1. each layer has a test that the macro returns a translated string for a non-English
   language and falls back to English for an unknown one;
2. every key a macro reads exists in every language of its table (checked by
   `scripts/check_localizations.py`, which must also report a layer that has no lookup
   macro); and
3. no layer's strings live in another layer's bundle.

CYLTabBarController is the reference: one `CYLLocalizedString` entry point, tables in
`CYLTabBarController.bundle/<language>.lproj` with identical keys in every table, and
app-level tables owned by the app (`docs/Configuration-Localization.md` there). It
publishes no separate acceptance checklist, so the criterion above is this repository's
own.

### Example-level bundles, always with macros

Each example keeps its own text in its own bundle inside the example folder,
for example `Examples/Example-Scenarios/Sources/CYLScenarioExample.bundle/
<language>.lproj/CYLScenarioExample.strings`, added to that example's target
only.

- Always create a localization header next to it that defines macros, so the
  mapping between code, keys and translations is in one place and easy to
  search, review and translate:

  ```objc
  // CYLScenarioLocalization.h (an Objective-C example; Swift examples use the function below)
  #define CYLScenarioLocalizedString(key) \
      [CYLScenarioLocalizationBundle() localizedStringForKey:(key) value:(key) table:@"CYLScenarioExample"]
  #define CYLScenarioL10nEmptyTitle      @"CYLScenarioEmptyTitle"
  #define CYLScenarioL10nRetry           @"CYLScenarioRetry"
  ```

  Code uses only these macros, never raw key strings or literal text. One key
  macro per string; the lookup macro names its table. This lookup macro is the
  example's half of the two-macro acceptance criterion above.
- A Swift example, which cannot define function-like macros, uses a lookup
  function plus a key enum in `<Prefix>Localization.swift` next to the bundle;
  `Example-Scenarios` is the reference:

  ```swift
  // CYLScenarioLocalization.swift
  func CYLScenarioLocalizedString(_ key: CYLScenarioL10n) -> String   // reads table "CYLScenarioExample"
  enum CYLScenarioL10n: String {
      case language = "CYLScenarioLanguage"
  }
  ```

  The function counts as the example's lookup macro, and
  `scripts/check_localizations.py` checks the enum's cases against the table as
  it checks key macros. When the core language can change at run time
  (`CYLPlaceholderLocalization.language`), the example function follows
  `CYLPlaceholderLocalization.effectiveLanguage`, so one switch changes both layers.
- The example's languages follow the core bundle's list where practical.
  `scripts/check_localizations.py` (CI job "Localization files") checks every
  bundle in the repository: same keys and format specifiers in every language,
  macros that match the keys, and no loose `.strings` files. Run it before
  committing a localization change.
- API, file and subspec names shown as technical hints are identifiers, not
  text, and stay as literals.

### Resource lookups: the same split for files

Images, animations, configuration files and other resources follow the same rule as strings: each layer reads only
its own bundle, through one lookup of its own.

- **Core:** `CYLPlaceholderResourceBundle()` and the macro `CYLPlaceholderResourceURL(path)` (function
  `CYLPlaceholderResourceURLForPath`, callable from Swift), declared in `CYLPlaceholderLocalization.h` next to
  `CYLPlaceholderLocalizedString`. Core code never looks the bundle up another way.
- **Example:** each example defines its own, reading only its bundle; in Swift, a function such as
  `CYLScenarioExampleResourceURL(_:)` in `Examples/Example-Scenarios/Sources/CYLScenarioLocalization.swift`.
- A path may not leave its bundle (no leading `/`, no `..`). What belongs in which bundle is in "Bundled animations".

### Right-to-left and locale formatting

- Lay out with leading/trailing (`NSLayoutConstraint` leading/trailing anchors, `NSTextAlignmentNatural` or centered
  text), never left/right, so a right-to-left language mirrors correctly once it is added.
- Format numbers, dates and counts with the locale (`NSNumberFormatter`, `NSDateFormatter`, `String(format:)` with a
  localized format string and `%ld` / `%@` placeholders); never concatenate translated fragments.
- The `ios-localization` skill (from CYLTabBarController) recommends String Catalogs; in this repository the file
  structure above wins: `.strings` in `<language>.lproj` folders inside a `.bundle`.

### Other platforms

Apply the same structure: per-language files grouped in one resource
container per owner, the library's container kept and changed additively, each
example with its own container, and a single generated or hand-written key map.

- Each platform also needs the lookup construct from "Lookup macros" above for the library and for every example.
- Android: `res/values-<locale>/strings.xml` in the library module and in each
  sample app module; `R.string.*` is the key map.
- Flutter: `lib/l10n/*.arb` per package with the generated localizations class.
- Web and React Native: a `locales/<locale>.json` folder per package with one
  exported constant object of keys.

## Accessibility (VoiceOver, Voice Control, Switch Control, Dynamic Type)

Adapted from CYLTabBarController's rule "Accessibility is required everywhere". The library code shipped to CocoaPods,
Carthage and the framework, and every example, fully support accessibility: VoiceOver, Voice Control, Switch Control,
Full Keyboard Access, Dynamic Type, Reduce Motion and Bold Text. This applies to new code, to code you change and to
existing code you review: fix what is missing when you meet it. Use the `ios-accessibility` skill to implement and the
`accessibility-audit` skill to check.

- **Every control and every piece of text is an accessibility element** with a meaningful, localized label, the right
  trait (button, header, selected, not enabled), a value for state (on/off, the current language) and a hint when
  useful. A placeholder reads as one element: its title (and badge) in one label. A list row reads its title and
  subtitle together.
- **Decorations are hidden**: an icon or illustration without text, label or tap event
  (`isAccessibilityElement = NO`, `accessibilityElementsHidden = YES`). An interactive view always has a label: an
  icon-only button is named after its action.
- **Tappable placeholders are buttons**: a component with a tap event has the button trait; with interaction turned off
  it also has the not-enabled trait and cannot be activated (`CYLPlaceholderView.tapHandler`,
  `tapInteractionEnabled`). `accessibilityActivate` runs the same action as a tap. Separators read their word, not the
  dashes. A placeholder made of several components groups them (`shouldGroupAccessibilityChildren`) and reads top to
  bottom.
- **Language**: when the core language is overridden at run time (`CYLPlaceholderLocalization.language`), components set
  `accessibilityLanguage` so VoiceOver pronounces the chosen language. Language menus read language names, never flags.
- **Dynamic Type**: text uses text styles or `UIFontMetrics`-scaled fonts with `adjustsFontForContentSizeCategory`; long
  text wraps instead of truncating.
- **Motion**: honor Reduce Motion. Placeholder animations stop and the shrink highlight only dims; looping animations
  still respect it.
- **Feedback**: a message that disappears by itself is also posted as a VoiceOver announcement and stays longer while
  VoiceOver runs.
- **Tests**: automated tests and UI tests find elements by accessibility label or identifier first; coordinates are a
  last resort, and a missing label is a bug to fix. Unit tests check labels, traits and hidden decorations.
- A change that adds a control or a text without accessibility is not done.

## Bundled animations

`CYLTableViewPlaceHolder.bundle/Animations/` ships ready-made placeholder
animations with Core: Lottie `.json`, PAG `.pag`, Rive `.riv` and GIF `.gif`,
named `CYLPlaceholder<Scenario>.<ext>` and found with
`+[CYLPlaceholderView pathForBundledAnimation:]`. Icons made for a refresh
control (pull arrows, spinners, loading more, done) are named
`CYLRefresh<State>.<ext>` in the same folder; `+[CYLRefreshComponent
bundledIconAnimationFileNames]` lists them with the placeholder animations that
also suit a refresh control, and the Example-Scenarios "Refresh icons" page
(Feed tab) demonstrates every one of them.

- Add only animations whose content means a placeholder state: loading,
  progress, empty, no results, no network or a failed request, a missing
  permission, an action the placeholder offers (retry, refresh, settings, contact
  support) or a finished task. Judge by what the file shows, not its file name;
  do not add mascots, scenes, characters or widget demos (switches, ratings,
  vehicles), or a file you could not inspect. When nothing fits, use a line icon
  with that meaning instead.
- The core bundle holds only placeholder resources: placeholder animations and
  icons, the refresh arrows, the core strings and their licenses. Anything else
  (demo configurations, mascots, scenes, widget demos, sample files) belongs to
  the example that uses it, in that example's own `.bundle` (for example
  `Examples/Example-Scenarios/Sources/CYLScenarioExample.bundle/Animations/`, with
  its own `NOTICE.animations` and license files, or
  `Examples/Example/CYLPlaceholderExample.bundle/`). Core tests that need sample
  data write it themselves instead of reading an example bundle.
- Download only from sources whose license allows redistribution (for example
  the engines' own Apache-2.0 or MIT repositories); community marketplaces with
  unclear terms are not acceptable sources. Keep the files unmodified.
- For every file, add an entry to `Animations/NOTICE.animations` (source
  repository, commit, original path, license, SHA-256) and ship the license
  text as `Animations/LICENSE.<source>`. Verify Git LFS files against their
  pointer's SHA-256 after downloading.
- Every app that uses Core carries these files; keep each small (well under
  100 KB) and the total under about 1 MB (about 480 KB today). Prefer vector Lottie without images.
- `testBundledAnimationsAreListedValidAndAttributed` checks the count, each
  format's header and the NOTICE entry; update its expected count when adding
  a file, and `testEveryBundledRefreshAnimationBuildsAnIcon` the number of
`CYLRefresh*` files. The aggregated demo (`Examples/Example-Scenarios`) lists every file.

## CI/CD

The default runner environment for iOS on GitHub CI/CD is **macOS 26**
(`runs-on: ${{ vars.MACOS_RUNNER || 'macos-26' }}`, the stable image with its
default Xcode 26.x); Linux-only jobs (docs, localization, shellcheck) stay on
`ubuntu-latest`.

- Before changing or diagnosing a workflow, always read CYLTabBarController's
  current
  [`.github/workflows/ios.yml`](https://github.com/ChenYilong/CYLTabBarController/blob/master/.github/workflows/ios.yml)
  first, to confirm the runner image and Xcode it uses, and follow it when it
  differs from this repository's `ios.yml`. Last checked: master `4209e37`
  (2026-11-10) uses `macos-26`, overridable with the repository variable
  `MACOS_RUNNER`.
- Jobs that need an older toolchain on purpose keep their own runner (for
  example the iOS 12 Core build on `macos-15` with Xcode 16); say why in a
  comment next to `runs-on`.
- **Local runs ignore this restriction.** A local run does not go through
  GitHub CI/CD: it uses the developer's own Mac directly, where the simulator
  and Xcode can be started for testing. Assume that Mac runs **macOS 27 with
  Xcode 27**, so builds there need the deployment-target override for Xcode 27
  (at least iOS 15.0 for the build; the library's iOS 12.0 minimum stays). Run
  the same scripts as CI (`scripts/`, `ruby Tests/run-tests.rb` with
  `DESTINATION`), choosing an installed simulator with
  `xcrun simctl list devices available`.
- Details of every job: `docs/CI-CD.md`.

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

## Bilingual documentation (Chinese and English)

`README.md` and every document in `docs/` are bilingual: Chinese and English side by side. This
follows CYLTabBarController (`docs/Bilingual-Documentation.md` and its `AGENTS.md`). Instructions,
skills and commit messages stay English only (see "English naming rules").

### Reading

- Read only the English part and skip the Chinese part:
  - in a table with `中文 | English` columns, the right column;
  - in a heading or cell written `中文 / English`, the part after the `/`;
  - in a code comment, the `[EN]` block; skip the `[CN]` block that runs until the next `[EN]`,
    the next tag or the end of the comment.
- Exception: text that has no English version is read as it is, because it is the only source.
- Writing is not affected: new text is always written in both languages.

### Format

1. **Headings** read `## 中文 / English`; the anchor joins both parts with `--`, for example
   `#如何阅读-readme--how-to-read-this-readme`. The same form is used for `###` headings.
2. **Body text** is a two-column table, `| 中文 | English |`, with the same content in each row, one
   paragraph or bullet per row. A wide API table is given twice: the full Chinese table first, then an
   English table with the same rows. Never put a code fence inside a table.
3. **Code samples** sit outside tables and are shared by both languages. Their comments come in pairs,
   `// [CN] …` followed directly by `// [EN] …` in the same comment style. String literals that are
   example data stay as they are.
4. **Proper nouns** stay as they are in both columns: product and app names in a list of apps, and the
   author's handle. Files that are not tied to code declare `<!-- bound-classes: none -->`.
5. **README** starts with "如何阅读 README / How to read this README", then the generated
   "导航 / CONTENTS" table.

### Generated blocks

- The navigation table (`<!-- docs-navigation:start -->` … `<!-- docs-navigation:end -->`, one row
  per `##` heading, both columns linking the same heading) and the binding table
  (`<!-- docs-binding:start -->` … `<!-- docs-binding:end -->`) are written by
  `python3 scripts/update-docs-navigation.py`. Never edit them by hand.
- Run the script after any change to `README.md` or `docs/`: editing Markdown, or adding, removing,
  renaming or moving a file or folder. `--check` exits 1 when a block is stale; the CI job
  "Docs navigation" runs it.
- Each document in `docs/` declares the classes it documents under its title,
  `<!-- bound-classes: CYLPlaceholderView, CYLRefreshHeader -->`, or `none`. The script writes a table
  of class and header path from it. (CYLTabBarController also writes links to the document into each
  class header; this project does not.)
- A document opts in by carrying the markers; the script lists the documents that do not carry them
  yet. Converting those is tracked in `docs/issue-progress.md`.

### Attachments

Attachments (images, recordings) go in an `assets/` subfolder next to the document that uses them,
linked with a short relative path:

| Document | Attachment folder | Link |
| --- | --- | --- |
| `README.md` | `assets/` at the repository root | `assets/name.png` |
| `docs/*.md` | `docs/assets/` | `assets/name.png` |
| `Examples/<Example>/README.md` | `assets/` in that example folder | `assets/name.png` |

No absolute paths, no `../` paths and no other attachment folders. File names are lowercase with
hyphens and name the feature, for example `cyl-placeholder-scenario-04-load-failed.jpg`. When a
folder or document moves, move its assets with it and fix the links.

### New features and user-visible changes

1. Write a bilingual document in `docs/`, named after the feature.
2. Add at least one line about it to `README.md`, linking to that document.
3. Save debugging screenshots of the bug-free result in `docs/assets/` and embed them in the
   feature's document; put the final screenshots in `README.md`.
4. If the change could not be run, say so in the document. Never present a diagram as a screenshot.
5. Keep `docs/issue-progress.md`, the README and the affected `cyl-*` skills current in the same change.

### Comments in code

A comment written in Chinese is tagged `[CN]` and followed directly by its English translation tagged
`[EN]`, in the same comment style (`//`, `///`, inside the same block comment; for a trailing comment,
on the next line). Mark fixes `FIX: issue #N`. Comments that only contain a person's name, and
commented-out code, need no translation. Old Chinese-only comments are translated when the code is
touched.

### Before every commit

- Run `python3 scripts/update-docs-navigation.py` and `python3 scripts/check_localizations.py`.
- Lint the Markdown you changed with the repository's `.markdownlint.json`
  (`npx markdownlint-cli@0.39.0 README.md docs`); table pipe style is leading and trailing pipes.
- Look for notes left by an environment that could not run the code:

  ```sh
  grep -rn -i -E "TODO|Linux|without Xcode|no (iOS )?simulator|no screenshots?|无法(编译|运行)|没有截图|暂无(测试)?截图" docs README.md
  ```

  Each hit is either an item in a `TODO` section that is still true, or stale and removed. Record every
  incomplete or unverified item under a `TODO` heading in the most relevant `docs/` document.

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

### Author line in every commit message

Every commit message carries the owner's line, exactly:

```text
By @ChenYilong <luohanchenyilong@163.com>
```

- Put it on its own line at the end of the body, after the details and before any trailers (such as
  `Co-Authored-By:` or `Claude-Session:`), separated from the body by a blank line.
- It applies to every commit in this repository, whoever or whatever writes it (people, Commitizen,
  agents), on every branch, including fixups and merge commits you author.
- Do not change its spelling, the handle or the address, and do not add it twice. The commit-msg hook
  below appends it when it is missing.

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
# The owner's author line ("Author line in every commit message"), added once when missing: before the
# trailer block (Co-Authored-By:, Claude-Session:, ...) so Git still reads the trailers, else at the end.
author_line='By @ChenYilong <luohanchenyilong@163.com>'
if ! grep -qxF "$author_line" "$tmpfile" 2>/dev/null; then
  tmp_author=$(mktemp)
  awk -v line="$author_line" '
    { lines[NR] = $0 }
    END {
      n = NR
      while (n > 0 && lines[n] ~ /^[[:space:]]*$/) n--
      start = n
      while (start > 0 && lines[start] ~ /^[A-Za-z][A-Za-z0-9-]*: /) start--
      if (start < n && start > 1 && lines[start] ~ /^[[:space:]]*$/) {
        for (i = 1; i <= start; i++) print lines[i]
        print line; print ""
        for (i = start + 1; i <= n; i++) print lines[i]
      } else {
        for (i = 1; i <= n; i++) print lines[i]
        print ""; print line
      }
    }' "$tmpfile" > "$tmp_author" && cat "$tmp_author" > "$tmpfile"
  rm -f "$tmp_author"
fi
HOOKEOF
chmod +x .git/hooks/commit-msg
```

`mkdir -p` creates `.git/hooks` when it is missing, so writing the hook
always succeeds. This overwrites the existing `commit-msg` hook and removes every line containing
`Co-Authored-By:`, case-insensitively, including other authors' attribution, and appends the author line
`By @ChenYilong <luohanchenyilong@163.com>` when the message does not contain it yet. Without the hook
(for example a commit written with `git commit -F`), add the line yourself.
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
