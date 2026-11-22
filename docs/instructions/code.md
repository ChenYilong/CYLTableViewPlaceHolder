# Code and architecture (`code`)

Full text of the `code` rules (naming, conventions, dependencies, one refresh / HUD / animation component, packages), moved verbatim from `instructions.md` and `AGENTS.md` on 2026-11-22 (owner's
rule: instruction files by tag, at most 200 lines each). Summaries: [instructions.md](../../instructions.md) and
[AGENTS.md](../../AGENTS.md), heading "Tag: Code and architecture". English only.

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

### Fix bugs in the core first (owner's rule, 2026-11-17)

- **The core** is the code published to a package registry: CocoaPods (the podspec's sources and resources), Maven /
  Gradle (the Android library modules), npm (the mini program and React Native packages), ohpm (the HarmonyOS HAR
  `cylplaceholder`), pub.dev and the like. Examples, demo apps, tests and scripts are not core.
- **When you meet an issue or bug, fix it in the core first**, so every app using the library avoids it and the
  same problem cannot come back in another page or another app. Fixing it in the example layer is the worst option:
  it hides the bug in the demo while every real app still has it.
- **If it cannot be fixed in the core, ask the owner before fixing it in the example, and say why**: what in the
  core prevents the fix (for example a platform API that does not exist, a public-API change that would break
  compatibility, a third-party library that must change upstream, or the bug really being in the example's own
  code). Then record the reason in the related document (the issue table, the task entry or the feature document):
  why the core cannot solve it and why the example layer does.
- An example's own mistakes (its layout, its texts, how it calls the API) are fixed in the example, with no question;
  but check first whether the core made the mistake easy (an unclear default, a missing guard, a misleading name)
  and fix that too.
- This is not the same as "Examples have the lowest weight": that rule is about a core change that breaks an
  example's build (fix the example); this one is about bugs (fix the core).

### Cross-platform API parity tables and the scoring loop (owner's rule, 2026-11-17)

Find the related document first and insert into it; create one only when none exists. In this repository the
tables are generated: Android → iOS is `docs/iOS-API-Map.md` (`scripts/ios-api-map.py`, data
`android/merged/ios-map.json`), iOS → Android is `docs/iOS-Android-Parity.md` (`scripts/ios-android-parity.py`,
data `android/merged/api-map.json`); HarmonyOS uses `scripts/harmony-port-tables.js`.

- **The table.** Column 1: every API and feature of one platform's core (Android first). Column 2: what it does.
  Column 3: the other platform's counterpart, `TODO` by default. Rows that are a platform detail with no
  counterpart needed are `n/a` with the reason, and are not counted; a feature (an option, an event, a style, a
  gesture) is never n/a.
- **The score.** Rows without TODO / counted rows: no TODO in column 3 is 100, all TODO is 0. The score sits at the
  top of the table and is regenerated with it.
- **The loop, until 100.** (1) Search the existing code for each TODO and record the counterpart you find (cite only
  symbols that exist). (2) Score. (3) Implement the missing APIs and features one by one, replacing each TODO with
  its implementation. (4) Score again, and repeat.
- **Core first** (see "Fix bugs in the core first"). A missing feature is added to the core of the platform that
  lacks it, with the same logic and the same API shape as the other platform. Then that platform's example
  reproduces the other platform's example that shows the feature. Example: when Android has draggable tags with a
  left icon, a title and a fixed delete icon on the right, and iOS has only the icon and title, extend the iOS core
  component (the packaged icon + title) with the delete icon, its tap event and dragging, keeping the API the same
  as Android's. Then the iOS tag list example shows deleting a tag: the data source is updated and the list lays
  out again.
- **Then the reverse table.** At 100 for Android → iOS, do the same for iOS → Android (column 1 the iOS API, column 3
  the Android counterpart, TODO by default) with the same scoring and loop.

### Animation bugs: record, screenshot, fix in CYLTabBarController (owner's rule, 2026-11-17)

The animation component (icon + title + animation: `CYLAnimatedItemView`, its engines and animators on every
platform) belongs to CYLTabBarController (branch `feat/cross-platform-components`, `docs/Animated-Item.md`); this
repository only takes it by commit (`CYLPlaceholderView` builds on it).

1. **Record first.** When you meet a bug, write it down before anything else: a row in the related issue table
   (for example `docs/HarmonyOS.md`, `docs/Animated-Item-Migration.md`) with the status `TODO`.
2. **Screenshot second.** Capture the bug (simulator, emulator or device) into `docs/assets/` and link it from the
   row; say so in the row when no screenshot is possible.
3. **Fix it in CYLTabBarController's animation component**, not in an example and not by working around it in this
   repository. Hand the bug to the session or branch that owns CYLTabBarController (with the row and the
   screenshot), then take the fixed commit here.
4. **Examples change only through CYLTabBarController's API.** If a demo really must change, CYLTabBarController first
   adds or changes the public interface the demo needs, and the example then calls that interface; never patch the
   component's behavior inside an example.

This narrows "Fix bugs in the core first" for animation bugs: the core that fixes them is CYLTabBarController's
animation component.

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
  after code, a `/** … */` block in a public Objective-C header, or a `/*! … */` block in a library Swift file. It also
  fails on a public declaration without a documentation comment directly above it (classes, categories, protocols,
  methods, properties, enums and each enum value, typedefs, exported constants and functions and macros of the public
  headers; `public` / `open` Swift declarations and the cases of public enums, overrides excepted); `--list` prints
  only those declarations.

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
- **One animation component.** Every animation the library shows (GIF, Lottie, PAG, Rive files and image sequences)
  plays through `CYLPlaceholderView` (Android `CYLPlaceholderView`, HarmonyOS `CYLPlaceholderViewModel`): the
  placeholder, every stack view item, the HUD, the status bar and the refresh icons. No other component creates an
  animation player, an animated image or a frame animator itself. `CYLPlaceholderView` is a subclass of
  CYLTabBarController's `CYLAnimatedItemView` (iOS and Android; guide:
  https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md), so a
  new animation type is added once, as an animator in CYLTabBarController's engine (`CYLTabBarItemAnimatorRegistry`),
  and every component supports it with no second change. Core depends on no animation engine (static images); an
  example shows animations by adding an animation subspec (`LottieSwift`, `PAG`, `Rive`, `SVGA`, `GIF`). Exceptions are format-specific drawn styles that drive one engine's own features (the Rive
  refresh header's state-machine inputs) and the system spinners (`UIActivityIndicatorView`) of the classic controls.
- Example: `CYLPlaceholderHUD` shows loading, progress and results in one `CYLPlaceholderView` inside its stack view;
  progress scrubs an animation or adds the percentage to the title, with no drawn ring.
- Images go through `CYLPlaceholderView` too. Always search the project for image-setting code (`setImages`,
  `setImage`, `.image =`, `animationImages`, `UIImageView`) before and after a change, and prefer the image API that
  `CYLPlaceholderView` already wraps (`CYLPlaceholderItemImage` and the other item attributes, `CYLPlaceholderComponent`,
  the refresh controls' `-cyl_setIconImages:duration:forState:`) over setting a `UIImage` on a `UIImageView` yourself.
- When system image setting cannot be avoided (a `UIImage` on a `UIImageView`, `UIButton` or layer), write a comment
  next to it that says why `CYLPlaceholderView` is not used there, for example: the view is MJRefresh's original arrow,
  kept unchanged by the owner's decision; the image view is public API kept for source compatibility; the code is
  inside `CYLPlaceholderView` itself. Code without such a comment is treated as a defect to fix.

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
- **Prefer a bulged plus button.** When an example shows a PlusButton, it bulges: the plus button's top edge goes
  above the tab bar's top edge, so it stands out of the bar. Raise it with the configuration keys
  `CYLPlusButtonCenterYMultiplier` / `CYLPlusButtonCenterYOffset` (or `+multiplierOfTabBarHeight:` /
  `+constantOfPlusButtonCenterYOffsetForTabBarHeight:` in a `CYLPlusButton` subclass); a negative offset or a
  multiplier below 0.5 moves it up. Keep the raised part tappable with `touchableAreaOutsets`, and on Liquid Glass
  follow the notes in `CYLPlusButton.h` (hide the glass lens when the button is moved). Check in a screenshot that the
  top of the plus button is above the tab bar. A flat plus button needs the task to ask for it.
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

## Icon and title: CYLAnimatedItemView; CYLPlaceholderStackView only for what it cannot cover

Owner's rule (2026-11-18), for the core and the examples on every platform (iOS, Android, HarmonyOS, the WeChat Mini
Program, React Native, Flutter):

1. **An icon with a title is a CYLAnimatedItemView.** A view or page that shows only an icon (a static image, a GIF or
   an animation) and a title draws it with CYLTabBarController's `CYLAnimatedItemView` (`cyl-animated-item` in the mini
   program), vertical, the title on the icon's center line. It does not wrap that pair in a `CYLPlaceholderStackView`.
   The animation detail pages are the reference case (HarmonyOS `AnimationDetailPage`, 64ab041).
2. **`CYLPlaceholderStackView` only where the item cannot cover the case.** Use the stack when the content is more than
   one icon with one title, or needs what the item view does not offer, for example:
   - several components: a hint or a long text under the title, buttons, separators, illustrations (the scenario
     catalog, the support page);
   - actions and tap handling per component, background actions, the configuration file format;
   - a title the item cannot draw on that platform (several lines where its title is one line only, a font weight or a
     dark-mode color it has no property for).
   Say in a comment why a page uses the stack when it shows little more than an icon and a title.
3. **A missing item feature goes upstream first.** When the stack is used only because `CYLAnimatedItemView` lacks a
   property (title lines, spacing, font weight, a color, GIF looping), record it, ask the owner of the component in
   CYLTabBarController for it (rule "Animation bugs: record, screenshot, fix in CYLTabBarController"), and move the page
   to the item once the pinned commit has it. Track the request as a `TODO` with its points in the task's document.
4. **Playback stays on the core's model.** The item view draws; play from the start, speed and repeat count go through
   the core's API so the examples' playback controls keep working: HarmonyOS the item's own `animationSpeed` /
   `animationLoops` / `CYLAnimatedItemController` with `animationBuilder: CYLPlaceholderAnimatedItemBuilder` (or
   `CYLPlaceholderAnimatedItem` attach / detach when a placeholder model drives it); Android `CYLPlaceholderView` (a
   `CYLAnimatedItemView` subclass) or the item's own `animationSpeed` / `animationLoops` / `restartAnimation()`; the mini
   program's `cyl-animated-item` properties and `cyl_playFromStart()`; iOS `CYLPlaceholderView` (a
   `CYLAnimatedItemView` subclass).
5. **One layout framework on every platform.** Every platform applies the same layout framework as
   `CYLPlaceholderStackView` does on the others: the same components in the same order, a vertical stack centered in
   its container, every component (icon, title, hint, button) on one vertical center line, titles and texts centered
   on one or several lines, the same spacing and metrics as the iOS core (`docs/iOS-API-Map.md`,
   `docs/iOS-Android-Parity.md`). No platform invents its own arrangement for a multi-component placeholder, and the
   item / stack choice of a page is the same on every platform unless point 2 or 3 forces a difference, which the page's
   comment and the task's document then explain.
6. **Verify the center line.** A change to either view is checked on a simulator or emulator: the icon's and the
   title's horizontal centers are equal (layout dump, view hierarchy or pixel bounds) and wrapped lines are centered
   (`docs/HarmonyOS.md` E16).

## One refresh library: CYLRefresh

`CYLRefresh` is the only refresh library and the only refresh kernel on every platform:

- No example and no core module depends on another refresh library: no MJRefresh, SVPullToRefresh,
  CYLRefreshLayout / CYLRefresh styles, android-Ultra-Pull-To-Refresh or easy_refresh package in a Podfile,
  Gradle file, package.json or oh-package. Every refresh call in an example goes through CYLRefresh
  (`cyl_header` / `cyl_footer` / `cyl_trailer` and the CYLRefresh controls).
- A feature such a library has and CYLRefresh lacks is added to CYLRefresh (a new control, or a CYLRefresh API with a
  new parameter), never brought in with the library. Code adapted from one keeps its license and attribution.
- The placeholder keeps an app's own MJRefresh controls above it at run time (`UIScrollView+CYLPlaceholder.swift` looks the
  class up by name), which needs no dependency.

## One HUD: CYLPlaceholderHUD

The HUD follows the same rule as CYLRefresh: `CYLPlaceholderHUD` is the
only HUD kernel on every platform, and its code lives in one folder: `CYLTableViewPlaceHolder/CYLPlaceholderHUD/` (iOS),
`android/placeholder/.../placeholder/hud/` (Android), `ets/hud/` (HarmonyOS) and `src/cyl-placeholder-hud/` (WeChat
mini program). No example or core module depends on another HUD library (SVProgressHUD, MBProgressHUD,
JGProgressHUD, a toast library...); a missing feature is added to CYLPlaceholderHUD. See docs/Placeholder-HUD.md.

## License in every published package (owner's rule, 2026-11-17)

Every piece of code published to an external registry carries its license declaration inside the package itself:
CocoaPods, Carthage / XCFramework, Gradle / Maven, npm, ohpm, pub.dev and any registry added later, on every platform.

- **The project's own license** (the root `LICENSE`, MIT) is copied into the package's built-in resource folder, so it
  ships with the package and is not left behind in the repository:
  - iOS (CocoaPods, Carthage): `CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.bundle/LICENSE`.
    The resource bundle always contains the license file.
  - Android (Gradle / Maven): `src/main/resources/META-INF/<artifact>/LICENSE` in each library module
    (`android/placeholder` → `cylplaceholder`, `android/merged/library` → `cylrefresh`, `android/merged/library/rive`
    → `cylrefresh-rive`). Java resources are packed into the AAR, and a folder per artifact keeps the paths unique,
    since an app that merges two AARs with the same `META-INF` path fails to build.
  - HarmonyOS (ohpm): `LICENSE` at the package root (`CrossPlatform/harmonyos-cylplaceholder/cylplaceholder/`) and in
    its resource folder `src/main/resources/rawfile/cylplaceholder/`.
  - WeChat Mini Program (npm): `LICENSE` at the package root and in the published folder `src/` (the folder
    `miniprogram_npm` copies).
  - A new platform or package: put the license in its existing resource folder; if it has none, create one.
- **Third-party licenses** of code or resources inside a package ship inside the package too, next to the files they
  cover (`LICENSE.<project>`, `NOTICE.<project>`), unchanged. Never drop or edit another author's license or attribution.
- **The manifest declares the license**: `s.license` in the podspec, `"license"` in `package.json` and
  `oh-package.json5`, the POM `licenses` block when a Maven publication is configured.
- **Keep the copies identical** to the root `LICENSE`. `python3 scripts/check_package_licenses.py` checks every copy,
  the third-party copies that must ship and the manifests; CI runs it. Add each new package to its tables.
- Skill: `cyl-package-licenses`.

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
  unclear terms are not acceptable sources. Keep the files unmodified, with one exception (approved
  2026-11-12): a background fill baked into a file (an artboard fill, a "BG" shape) may be made
  transparent by setting its alpha to 0 and nothing else, when the license allows modification; the
  `NOTICE.animations` entry then records the change and both the original and the new SHA-256.
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

## Animation playback controls in examples

Every example page that shows animations (placeholder animations, refresh icons, tab bar item animations, any Lottie /
Rive / PAG / GIF / frame animation) has, next to its one-shot "Play all", a speed slider and a loop switch
(owner's request, 2026-11-13). Details, the engine table and the per-page TODO list are in
`docs/Example-Animation-Playback.md`.

- "Play all" restarts every animation on the page from progress 0, every time.
- The speed slider (0.25x to 3x, default 1x, its value shown as "1x") and the loop switch apply live, to the playing
  animations and the next ones; together with Play all they set the playback strategy.
- Labels are localized in the example's bundle and accessible (the slider is adjustable with a value such as "1.5x";
  the switch reads "Loop").
- When the core or an engine cannot do it, change the core (Swift naming macros, a new core API) instead of hiding a
  control.
- Applies to the examples of every layer: iOS, Android, React Native, Flutter, mini programs, HarmonyOS. A page without
  the controls is a `TODO` row in `docs/Example-Animation-Playback.md`.

## AGENTS.md: Source of truth

- Public headers under `CYLTableViewPlaceHolder/` define the current API.

- `README.md` documents integration and usage; `docs/issue-progress.md` records
  issue history and known limits. If they disagree, verify the code and update
  the affected documentation.

## AGENTS.md: Icon and title vs. the stack view

- **Icon and title: CYLAnimatedItemView only.** A view or page that shows only an icon and a title draws it with
  CYLTabBarController's `CYLAnimatedItemView` (`cyl-animated-item` in the mini program), not a `CYLPlaceholderStackView`.
  The stack is only for what the item cannot cover (several components, hints, buttons, per-component actions, or a
  title the item cannot draw on that platform); a missing item feature is requested upstream and the page moves to the
  item once the pin has it. Playback stays on the core's model (HarmonyOS `CYLPlaceholderAnimatedItem`). Every platform
  applies the same layout framework as `CYLPlaceholderStackView` does on the others (same components and order, one
  vertical center line, centered titles, iOS metrics). See `instructions.md`, "Icon and title: CYLAnimatedItemView;
  CYLPlaceholderStackView only for what it cannot cover".

## AGENTS.md: Naming and compatibility

- Follow the English naming rules in `instructions.md`: new project-owned
  classes use `CYL`; UIKit category files use `+CYL`; category methods and
  properties use `cyl_`, except required system overrides.

- Do not rename existing public symbols, serialized keys, or resources without
  assessing compatibility and obtaining approval for breaking changes.

- Preserve third-party copyright, license text, and original attribution. Do
  not replace an author's name with the project author's name.

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
  inside a stack view is a `CYLPlaceholderView`. A custom view needs explicit approval. Every animation (files and image
  sequences) plays through `CYLPlaceholderView`, so a new animation type is added there once and every component
  supports it ("One animation component" in `instructions.md`).

- Always search for image-setting code (`setImages`, `setImage`, `.image =`, `animationImages`, `UIImageView`) and
  prefer `CYLPlaceholderView`'s image API (`CYLPlaceholderItemImage`, `CYLPlaceholderComponent`,
  `-cyl_setIconImages:duration:forState:`) over a system `UIImage` on a `UIImageView`. Where system image setting is
  unavoidable, a comment next to it says why `CYLPlaceholderView` is not used.

## AGENTS.md: Project and verification

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

- The example's plus button bulges by default: its top edge is above the tab bar's top edge
  (`CYLPlusButtonCenterYMultiplier` / `CYLPlusButtonCenterYOffset`, tappable through `touchableAreaOutsets`); a flat
  plus button needs the task to ask for it.

- CYLRefresh is the only refresh library and the only refresh kernel on every platform: no example or core module
  depends on MJRefresh, SVPullToRefresh, CYLRefreshLayout, android-Ultra-Pull-To-Refresh or easy_refresh, and every
  example refresh call goes through CYLRefresh; a missing feature is added to CYLRefresh. See "One refresh library:
  CYLRefresh" in `instructions.md`.

- `CYLPlaceholderHUD` is the only HUD kernel on every platform, its code in one folder (`CYLPlaceholderHUD/` on iOS,
  `hud/` on Android and HarmonyOS, `cyl-placeholder-hud/` in the mini program); no other HUD library. See "One HUD:
  CYLPlaceholderHUD" in `instructions.md`.

- Fix bugs in the core first (`instructions.md`, "Fix bugs in the core first"): the core is the code published to a
  package registry (CocoaPods, Maven / Gradle, npm, ohpm, pub.dev). Fix an issue or bug there so every app avoids it;
  fixing it only in an example is the worst option. If the core cannot fix it, ask the owner and say why, then record
  in the related document why the core cannot and the example does.

- Animation bugs (`instructions.md`, "Animation bugs: record, screenshot, fix in CYLTabBarController"): record the bug
  first, screenshot it second, and fix it in CYLTabBarController's animation component, not in an example; if a demo
  must change, CYLTabBarController first adds the interface the demo calls.

- Examples have the lowest weight (`instructions.md`, "Examples have the lowest weight"; `docs/Swift-Migration.md`):
  when a core change (the Swift migration or a refactor) breaks an example, fix the example first, freely and in the
  same change. An example's usage is never a compatibility constraint and never a reason for an alias, a shim, a
  wrapper or a lower-quality Swift API in the core; the Swift coding standard decides.

- License in every published package (`instructions.md`, "License in every published package"): all code published to
  an external registry (CocoaPods, Carthage, Gradle / Maven, npm, ohpm, pub.dev and others, every platform) carries
  its license inside the package: the root `LICENSE` copied into the package's built-in resource folder (created if
  missing), e.g. `CYLTableViewPlaceHolder.bundle/LICENSE` on iOS, `src/main/resources/META-INF/<artifact>/LICENSE` in
  each Android library module, `LICENSE` at the ohpm package root and in its `rawfile`, `src/LICENSE` in the mini
  program package; third-party licenses ship unchanged next to the files they cover; manifests declare the license.
  `python3 scripts/check_package_licenses.py` checks it in CI; skill `cyl-package-licenses`.

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

- Animation examples (`instructions.md`, "Animation playback controls in examples"): every example page that shows
  animations has a "Play all" that restarts them from progress 0, a speed slider and a loop switch, applied live and
  combinable; every platform's examples (iOS, Android, React Native, Flutter, mini programs, HarmonyOS); change the
  core when needed. Pages and status: `docs/Example-Animation-Playback.md`.
