# Folder instructions

This repository contains an Objective-C table-view placeholder library, an
integrated refresh component, and an iOS example. It inherits the vault's root
instructions. Read `AGENTS.md` before changing the project.

## Record every task in docs before starting it

Before starting any task, write it down in `docs/`, so an interrupted task never loses its context: the next session
(or another agent) finds what was asked, why, and how far it got.

1. **Find the fitting document** in `docs/` (the feature's document, `issue-progress.md` for an issue,
   `Refresh-Icon-Animation.md` for refresh icons, and so on). When no document fits (process, instruction or
   tooling tasks), use `docs/Task-Log.md`.
2. **Record the task as a TODO** there before any other change: a `TODO` heading or table row with
   - the date and the branch;
   - the user's original prompt, verbatim (keep the user's language);
   - the user's requirements, one by one;
   - the detailed context: related files, commits, decisions already made, what is known and what is not yet
     verified.
3. **Commit and push that TODO right away** (on a branch other than `main` or `master`), before the work itself, so
   it survives an interrupted session.
4. **Do the task.** Add progress notes to the same entry when a step finishes or the plan changes.
5. **When the task ends, mark the TODO done** in the same entry: change `TODO` to done (`已完成 / Done`) with the
   date, the commits and the verification (tests, screenshots). Keep the entry; do not delete it. A task that ends
   unfinished stays `TODO`, with what remains.

Follow the bilingual documentation rules for the entry; the user's prompt is quoted as written.

### Before the TODO: check the other sessions first

The first step of every task, before the TODO entry and before any change:

1. **List the other sessions and read their tasks** (`ListAgents`, then each session's current task: its last
   messages, or its `TODO` entries in `docs/`).
2. **Is another session editing the same branch?**
   - No: continue with the task.
   - Yes: check whether the task duplicates theirs (the same files, the same fix, the same verification). Message
     that session and settle who does what before changing anything; continue only with the part that is not a
     duplicate, and rebase on their pushed work before pushing.

### Re-read the rules a pull changes

Rules change while a task runs (other sessions push them). After every `git pull` (and before every commit, which
pulls first), check whether the pull changed a rule file and read the changed parts before going on:

    git diff --stat ORIG_HEAD HEAD -- instructions.md AGENTS.md '*/instructions.md' .agents/skills
    git diff ORIG_HEAD HEAD -- instructions.md AGENTS.md '*/instructions.md' .agents/skills

Apply a changed rule to the work in progress (redo what it affects) before committing. Never pull and commit in one
command when the pull may bring rules: pull, read, then commit.

### TODO and the branch at the top of the session

When a task starts, the session's first reply begins with a `TODO` line and the current branch, for example
``**TODO** (branch `feat/x`): <the task in one line>``. This is usually the first line of the session, so the owner
sees at a glance what is being done and where.

### Acceptance criteria and scoring

The task's `TODO` entry in `docs/` also states how the result is scored:

- **Full marks (100):** what the finished task looks like: every requirement done, verified (tests, screenshots) and
  pushed.
- **Pass (60):** the minimum that is acceptable: the core requirements done and verified, with only optional parts
  left.
- **Score the result** after each step against these criteria and write the score into the entry.
- **Do not stop below a pass.** A task scored under 60 is not interrupted or handed back: keep working and rescoring
  until it passes (the only exception is a blocker outside the session's control, such as hardware that is missing;
  record the blocker in the entry).
- **Explain any missing points:** when the score is under 100, write in the entry why full marks were not reached.
- **Print the missing points at the end of the session** as `TODO`s, one per missing part, with the points it is
  worth, for example `TODO (-10): screen reader check needs a real phone`.
- **Update the entry written at task start** with the final score, the reasons and the remaining `TODO`s.

## Shared emulators: restart a hung emulator

Several sessions share the Android emulator (`emulator-5556`) and the HarmonyOS emulator (`127.0.0.1:5555`).

- **An emulator that stays hung** (adb / hdc commands time out, the package manager does not answer, the screen does
  not respond) stays hung until it is restarted. **Tell the other sessions first** (`SendMessage`: "taking
  emulator-5556, restarting it"), **then restart it** from the command line. Do not ask the owner whether to restart.
- **An emulator that does not open** (it does not boot, or it is not listed by `adb devices` / `hdc list targets`):
  restarting is the first strategy, before any other fix.
- **How to restart** (Android): `adb -s emulator-5556 emu kill`, wait for `qemu-system-x86_64` to exit, then a cold
  boot: `emulator -avd <name> -port 5556 -no-snapshot-load -no-boot-anim`, and wait for
  `getprop sys.boot_completed` to be `1`. HarmonyOS: close the emulator (`hdc kill`, or end `Emulator.exe` for that
  device only), then start it again with `Emulator -hvd "<device>" ...` (skill `cyl-harmonyos-setup`).
- Restart only the hung emulator; leave the other platform's emulator running.
- **When done, tell the other sessions** ("done, emulator-5556 is free") and stop anything that might hang it again
  (for example a loop of `adb shell dumpsys` checks).

## Translating or porting another project: its open pull requests and issues

When a document in this repository links to another project's GitHub repository as the source of a translation, a
port or a similar task (for example CYLRefresh styles or flutter_easy_refresh in `docs/Refresh-Library-Parity.md`,
or the Kotlin translations planned in `docs/Android-Port.md`), the source is not only its default branch:

1. **Open pull requests.** Read the source's open pull requests and bring their changes in, before or after the
   translation:
   - translation not started: merge the open pull requests into the source you translate first;
   - translation already done: translate each open pull request on its own and merge the result into this project.
   Record each pull request (link, what it changes, merged / translated / not taken and why) in the task's document.
2. **Open issues.** In the task's document in `docs/` (create one when none fits), keep a table of the source's open
   issues: column 1 the issue link, column 2 a short description, column 3 the fix status, `TODO` by default. Find
   each issue's counterpart in this project's code and try to fix it there; a fixed row says how and links the commit
   and the test.
3. **Score.** All issues fixed is 100; recompute the score after every fixed issue, and keep going until 100. An issue
   that does not apply to this project (another platform's bug, a question) says why and counts as handled.
4. **Order.** If the translation has not started: merge the open pull requests, then work on the open issues, and
   start translating once the issues reach 60. After translating, fix the remaining issues on the translated code
   until 100. If the translation is already done: translate the open pull requests and merge them in, then fix the
   issues on the translated code until 100.
5. **Cross-language ports** (decided by the owner on 2026-11-13, for the Kotlin port of SVPullToRefresh): when the
   translation is into another language, so an issue's fix can only be written in the translated code, an issue whose
   fix is in an open pull request that was reviewed and taken for the translation counts as handled for the 60 needed
   to start; it must still be implemented and tested in the translation before the score reaches 100.
   For CYLRefreshLayout (Java → Kotlin, decided by the owner on 2026-11-13: "Fix in Java first"), the gate stays: a
   copy of the Java source in `android/CYLRefreshLayout/java/` gets the taken pull requests and issue fixes, each
   with a test, until the issues reach 60; then translation starts and the remaining issues are fixed in Kotlin.
   Since 2026-11-17 (the owner's decision: "make sure CYLRefresh is the only kernel") the Kotlin CYLRefreshLayout is
   folded into CYLRefresh (`android/merged/library`, `com.cyl.refresh.*`), and the Java copy, SVPullToRefresh and
   android-Ultra-Pull-To-Refresh are deleted; a later fix goes into CYLRefresh. See docs/Android-Port.md.
6. **Every platform** follows this rule: iOS, Android, Flutter, React Native, HarmonyOS and mini programs.

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

### Examples have the lowest weight (owner's rule, 2026-11-13)

Applies to the Swift migration of the core (`docs/Swift-Migration.md`) and to every other core change.

- When a core change (the Swift migration of the core, or any core refactor) breaks an example's build or
  behavior, fix the example first: update its call sites to the core's new Swift API in the same change.
- Every example has the lowest weight in the repository. An example's usage is never a compatibility constraint:
  do not keep an old spelling, a deprecated alias, a shim, an extra `@objc` name, a wrapper or an overload in the
  core only because an example calls it that way.
- Change example code as freely as needed (rename, restructure, rewrite it) so the core carries no baggage.
- Never lower the core's Swift code quality for an example. The Swift coding standard decides the core's API (the
  Swift API Design Guidelines, `docs/Swift-Guide.md` and the project's Swift coding standard); examples follow it.
- Compatibility still counts only for callers outside this repository (the published API that apps use through the
  podspec), under "English naming rules" and "Compatibility" above; that is decided for the library's users, never
  for an example.
- Done means every example builds again (the `Demo` CI jobs) with the core's clean API, examples updated in the same
  change.

## HarmonyOS (owner's rule, 2026-11-16)

- **Version:** HarmonyOS 6.0.1 (API 21, Release); HarmonyOS SDK 6.0.1.112, `compileSdkVersion` / `targetSdkVersion`
  and the minimum `compatibleSdkVersion` 5.1.0(18) (lowest the dependencies and APIs allow; lets Device Manager list phone emulators); DevEco Studio 6.0.1.251; ArkTS / ArkUI, Stage model. Code:
  `CrossPlatform/harmonyos-cylplaceholder` (HAR `cylplaceholder`, example HAP `entry`).
- **The API matches iOS:** every public symbol of the iOS library has a HarmonyOS counterpart with the iOS name
  (types, enums, constants, methods in camelCase without the Objective-C colons).
- **The example matches iOS:** the HarmonyOS example is a 1:1 copy of `Examples/Example-Scenarios`: the same tabs,
  pages, rows, texts, behaviors and order.
- **The implementation follows Android:** the internals are migrated from the Kotlin source under `android/`
  (`android/placeholder`, `android/merged`), translated to ArkTS; iOS headers define the contract, Kotlin the
  behavior.
- **Tracking and score:** `docs/HarmonyOS.md` lists every iOS public API (table 1) and every iOS example demo
  (table 2); the second column is the HarmonyOS implementation, TODO until done. Score = rows without TODO ÷
  counted rows (both tables together), recomputed by `node scripts/harmony-port-tables.js` after every finished
  feature; remove one TODO per finished feature until the score is 100.
- **Build:** `CrossPlatform/harmonyos-cylplaceholder/scripts/build.sh` (hvigor refuses non-ASCII project paths, so
  from a checkout under such a path the script mirrors the project to an ASCII directory and builds there; from a
  checkout at an ASCII path it builds in place).
- **Opening it in DevEco Studio (Windows):** DevEco Studio / hvigor refuse a project path with non-ASCII characters
  ("00306003 Specification Limit Violation: Invalid project path"). The checkout used to sit under `文档`: OneDrive's
  Known Folder Move had created Documents / Pictures / Desktop with Chinese names (`文档` / `图片` / `桌面`; Explorer only
  showed them as "Documents" through `desktop.ini`). On 2026-11-17 they were renamed to `Documents` / `Pictures` /
  `Desktop`, with the known-folder registry entries (`User Shell Folders`, `Shell Folders`) updated and the git
  worktrees repaired, so the checkout is now at `C:\Users\Chen Yilong\OneDrive - AUT University\Documents\GitHub\
  CYLTableViewPlaceHolder` and DevEco Studio opens `CrossPlatform\harmonyos-cylplaceholder` there directly (it builds
  in place: `ohpm install`, Build > Build Hap(s), or `scripts/build.sh`). Keep project paths ASCII: a directory
  junction or a `subst` drive does not work around a non-ASCII path (hvigor resolves both back to the real path with
  Node's native `realpath`: "Invalid project path" / "Path not found"); use a clone at an ASCII path instead. Scripts
  with non-ASCII text for Windows PowerShell 5.1 must be saved as UTF-8 with a BOM, or they read `文档` as `鏂囨。`.
- **IDE and emulator setup:** follow the skill `cyl-harmonyos-setup` (`.agents/skills/cyl-harmonyos-setup/SKILL.md`)
  before building or running. Emulator prerequisites: a Huawei developer account signed in to DevEco Studio; VT-x /
  AMD-V enabled in the BIOS; Hyper-V and Windows Hypervisor Platform turned on (`HypervisorPresent` is `True`);
  16 GB RAM or more and free disk space for the image; `compatibleSdkVersion` 5.1.0(18) so phone images are listed;
  and **the region set to China**. The region lives in DevEco Studio's `country.region.xml`
  (Windows: `%APPDATA%\Huawei\DevEcoStudio6.0\options\country.region.xml`; macOS:
  `~/Library/Application Support/Huawei/DevEcoStudio6.0/options/country.region.xml`). With DevEco Studio closed,
  back the file up (for example `country.region.xml.bak-NZ` when it was New Zealand) and change the region to China
  (CN). Make sure the region file now says China: `<countryregion name="CN"/>`; without it Device Manager offers no
  emulator. **Check it again before every emulator start**: a DevEco Studio left open while the file is edited writes
  its own region back on exit (2026-11-17 it said `NZ` again), so quit DevEco Studio, set `CN`, then start it and the
  emulator (skill `cyl-harmonyos-setup`, section 3).

### HarmonyOS accessibility and localization (owner's rule, 2026-11-16)

- **All HarmonyOS code of this project supports visual assistance and blind users** (screen readers, large text,
  high contrast) **and internationalization / localization.** If you find code that does not, add the support first.
- **Accessibility:** every tappable element has a role and a localized label (`accessibilityRole`, visible text or
  `accessibilityText`); rows group their content (`accessibilityGroup`); decorative images and animations are hidden
  (`accessibilityLevel('no')`); hidden controls are not read; selected items say so; library views follow the iOS
  VoiceOver behavior (placeholder, status bar, HUD, refresh controls).
- **Localization:** no hard-coded user-visible or spoken text. Library texts: `CYLPlaceholderLocalization`; example
  texts: `t('Key')` in seven languages (en, zh-Hans, zh-Hant, ja, ko, ru, uk); tab bar texts (Selected, Plus button,
  Close, Play / Stop, Badges): copied from CYLTabBarController's string table, only the keys this project uses, by
  `CrossPlatform/harmonyos-cylplaceholder/scripts/import-tabbar-strings.js`. Check with
  `node scripts/harmony-l10n-check.js`.
- **Automated UI tests use these features first to locate controls**: find a control by its accessibility label
  (`ON.description`) or its localized text (`ON.text`), in any of the example's languages, and fall back to component
  ids only when needed; trigger taps, complex flows and consecutive operations through those lookups
  (`entry/src/ohosTest/ets/test/ExampleUi.test.ets`).
- Checklists and the test pattern: skill `cyl-harmonyos-a11y-l10n` (`.agents/skills/cyl-harmonyos-a11y-l10n/SKILL.md`).

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
  `CYLPlaceholderLocalization.supportedLanguages` (`CYLPlaceholderLocalization.swift`) and
  `cyl_defaultI18nBundle(language:)` (`NSBundle+CYLRefresh.swift`).
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
- Every example with a bundle also checks itself at run time: `<Prefix>LocalizationSelfCheck()` in its
  `<Prefix>Localization.swift` switches `CYLPlaceholderLocalization.language` through every core language and an
  unknown one, and checks that `effectiveLanguage` follows and that every key of the key enum resolves through the
  lookup function to that language's own `.lproj` value (English for the unknown one). The app runs it when launched
  with `-localizationCheck`; `scripts/ci-build-example.sh` runs it in CI, and an example with a UI test target adds a
  UI test for it (Example-objc-02: `CYLLocalizationUITests`). `scripts/check_localizations.py` also checks that every
  key the example's code uses is a case of the enum and exists in every language, and that the bundle has every core
  language.
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
  example a build that needs an Xcode other than the runner's newest); say why in a
  comment next to `runs-on`.
- **Local runs ignore this restriction.** A local run does not go through
  GitHub CI/CD: it uses the developer's own Mac directly, where the simulator
  and Xcode can be started for testing. Assume that Mac runs **macOS 27 with
  Xcode 27**, so builds there need the deployment-target override for Xcode 27
  (at least iOS 15.0 for the build; CI builds and tests iOS 15.0 since 2026-11-20, the library's minimum is 15.0 too since 2026-11-20). Run
  the same scripts as CI (`scripts/`, `ruby Tests/run-tests.rb` with
  `DESTINATION`), choosing an installed simulator with
  `xcrun simctl list devices available`.
- Details of every job: `docs/CI-CD.md`.

## Screenshots of local builds and CI/CD

These rules cover every screenshot: local simulator or device runs and CI/CD artifacts.

- **When to take them: at key moments.** A key moment is when a `TODO` or a "Linux" note in the docs can be removed,
  when a pull request is ready to merge, or when you judge that the result meets the expectation with no bug and no
  open issue.
- **Show the key detail, not the whole screen.** Crop to the part that proves the point (the refresh header, the
  footer, the badge); take the full screen only when the whole layout is the point.
- **Stitch several details into one image** in a portrait (vertical) sheet, in this order of preference (the owner's
  rule of 2026-11-18, second update, which replaces the same morning's "two columns first"):
  1. one column with several rows, stacked top to bottom;
  2. two columns with several rows, only when the one-column image would be taller than one screen of a common phone
     (19.5:9: height above about 2.17 times the width at phone width);
  3. a single horizontal row, the last resort, with at most three images per row.
  Every stitched image has a header and a footer; see "Header and footer on stitched screenshots" below.
- **Store every screenshot in `docs/`.** Put the image in `docs/assets/` (or the `assets/` folder next to the document)
  and embed it in the document it belongs to; create a document when none fits. Commit the images to the repository;
  never leave them only in a temporary folder or a CI artifact.
- **Update the README when the result meets the expectation.** Put the latest images in the matching README section
  (create the section when there is none), and label each image or group with:
  - the platform: iOS, Android, Flutter, React Native, HarmonyOS or mini program;
  - the environment: the operating system version, the simulator or emulator (device and version), and the platform
    SDK version (iOS SDK / Xcode, Android SDK, Flutter, React Native, HarmonyOS SDK, mini program base library);
  - this repository's version, or the commit with its link;
  - the time the screenshot was taken.
- **Use clear original images**: the simulator's or device's full-resolution capture, cropped but not scaled down or
  recompressed until it blurs.

### Header and footer on stitched screenshots

The owner's rule (2026-11-18). Reference image, which shows the style (the header and the panel captions) but has no
footer yet: `docs/assets/screenshot-style-reference-ios27.2-iphone17pro-xcode27.2-cyltabbarcontroller-dcbfdec6-20261118.png`.

- **Layout.** A portrait sheet: one column with several rows first; two columns with several rows when one column
  would be taller than one phone screen (height above about 2.17 times the width); one row last (see above). Plain
  white background, the same margin around every panel, panels in the order of the test (left to right, then top to
  bottom).
- **A header and a footer on every stitched image.** Both are bands of their own above and below the panels. They never
  overlap, cover or touch any screenshot pixel; nothing is drawn on a screenshot (no labels, arrows or boxes inside
  it). Leave a gap between a band and the panels.
- **Everything in English**, in bold text of one high-contrast color (the reference uses red), large enough to read on
  a phone without zooming.
- **The header holds the key facts**, on one or two lines, in this order, separated by commas:
  1. the platform and the device: "iOS 27.2, iPhone 17 Pro sim" (the simulator or emulator OS version and device; "real
     device" for a phone);
  2. the IDE and its version, for example "Xcode 27.2", "DevEco Studio 6.0.1", "Android Studio 2026.1", "WeChat DevTools 1.06";
  3. the host operating system and its version: "macOS 27.3", "Windows 11 24H2";
  4. the libraries under test and their commits: "CYLTabBarController dcbfdec6 (ef1d0313)";
  5. this repository's branch and commit: "feat/android-refresh-port-followup 579018c";
  6. the date: "2026-11-18";
  7. then, ending the header with a full stop, the test purpose in a few words: "Rive tags at rest (no play)".
- **A caption above each panel**, in its own band (never over the image), naming the step and, when measured, the
  result: "launch, no play", "11 s later, 0 changed pixels", "after Retry", "dark mode".
- **The footer holds the outcome**: the verdict (pass / fail), the measured values, how they were measured (for
  example a pixel diff of two captures 11 s apart), the launch arguments or command, and the file names of the
  original captures in `docs/assets/`.
- **Originals stay too.** Commit the uncropped original captures next to the stitched image in `docs/assets/`, named
  with the platform, OS, device, commit and date. Crop the panels, never scale them down or recompress them until they
  blur.

### Enforcement: every screenshot passes the checker

The owner's rule (2026-11-18), after a screenshot was committed without the header and footer 26 seconds after the rule
above landed (this session pulled the rule in the same command as its commit and never read it; the earlier sheets had
no tool and no check behind them). From now on a screenshot that breaks the rule cannot be committed or merged:

1. **Make every stitched image with the tool.** `python3 scripts/screenshot_sheet.py sheet.json` writes the portrait
   sheet in the order above (one column first, two columns only when one column is taller than 2.17 times its width),
   the bold English header with the seven facts, a caption band above each panel and the footer, all outside the
   panels, and records them in the PNG ("cyl-screenshot-sheet"). A sheet made by another tool (CYLTabBarController's
   `scripts/stitch-screenshots.py`) needs a sidecar `<sheet>.sheet.json` with the same record (header, captions,
   footer, originals).
2. **Name the originals** `<platform>-...-<commit>-<yyyymmdd>.<png|jpg|jpeg>` (platform: ios, android, harmonyos,
   wechat-miniprogram, flutter, react-native), commit them in `docs/assets/`, and list them in the sheet. A single
   screenshot used as evidence is a one-panel sheet too, never a bare capture.
3. **Run the checker before every commit that adds or changes an image:** `python3 scripts/check_screenshots.py`. Both
   scripts need Pillow (`python3 -m pip install pillow`, or a venv where the system Python refuses it). It
   fails on any image in `docs/assets/` that is neither a sheet with a complete record nor an original one uses. It is
   a local check: CI does not run it (removed from the `Docs navigation` job at the owner's request, 2026-11-18), so
   run it yourself before every commit that adds or changes an image.
4. **Never add to `docs/assets/screenshot-legacy.txt`.** It lists the images committed before the rule; replace an
   old image by a conforming sheet instead (keep the old file only while another repository links it).
5. **Re-read the rules a pull changed** (see "Re-read the rules a pull changes") before taking,
   stitching or committing a screenshot: the screenshot rules changed three times on 2026-11-18.

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
touch .git/NO_AUTO_SYNC && mkdir -p .git/hooks && touch .git/hooks/NO_AUTO_SYNC
```

The vault's auto sync (`.claude/hooks/git_sync.py` in the vault root) checks `.git/NO_AUTO_SYNC`, not `.git/hooks/NO_AUTO_SYNC`: the hooks path never paused it (verified 2026-11-12). Both files are kept so either reading works; delete them to turn the sync back on. If the hooks directory does not exist (for example in a fresh clone or a container without sample hooks),
`mkdir -p` creates it first so `touch` always succeeds.

### git cz style, English only (owner's rule, 2026-11-16)

- **Every commit is a `git cz` (Commitizen) style commit**: `{type}{scope}: {emoji} {subject}` with the Commitizen
  default types and emojis listed in "Commitizen defaults" (`feat` 🎸, `fix` 🐛, `docs` ✏️, `test` 💍, `ci` 🎡,
  `chore` 🤖, `refactor` 💡, `style` 💄, `perf` ⚡️), whether it is written with `git cz` or by hand.
- **The whole commit message is in English: no Chinese characters anywhere**, not in the subject, the body, the
  scope or a quoted file name or prompt. Describe a Chinese text or prompt in English (or point to the `docs/` entry
  that quotes it) instead of pasting it. This applies to merge commits, cherry-picks and amended messages too.
- Check before committing: `git log -1 --format=%B | LC_ALL=C.UTF-8 grep -nP '[\x{4e00}-\x{9fff}\x{3000}-\x{303f}\x{ff00}-\x{ffef}]'`
  must print nothing.

## Committing on branches

On any branch other than `master` or `main`, commit and push as soon as the
work is written, without asking for confirmation. Follow the commit readiness
and Commitizen rules above. On `master` or `main`, commit or push only when the
user asks; otherwise create a branch and open a pull request (`docs/CI-CD.md`).

### A pull request for every new branch

- Every time you create a branch, open a pull request for it right away, without asking: push the branch and run
  `gh pr create` in the same step. Do not wait for the work to be finished; a draft-quality pull request is fine and
  later commits update it.
- Target branch: the branch the new branch was created from (its source branch) comes first. Use `main` or `master`
  only when the source branch is `main` or `master` itself, or when the source branch no longer exists on the remote.
  Pass it explicitly (`gh pr create --base <source branch>`); never rely on the repository's default.
- Write the source branch into the pull request description, so a reviewer knows where it will merge.
- Still do not merge the pull request without the user's approval.
- **Every branch with commits has an open pull request (added 2026-11-16).** After creating a branch, any commit on it
  must be in a pull request. Never create a branch and keep committing to it without one: commits on a branch with no
  pull request are ignored, because nothing ever merges them.
  - **Before every commit**, check that the current branch has an open pull request
    (`gh pr list --state open --head <branch>`). If it has none (never opened, closed or merged), open a new one right
    after pushing (`gh pr create --base <target> --head <branch>`).
  - **Target branch**: the branch of the pull request that was active (open) before this one was created; only when
    there is none, `master` (or `main`).
  - **More than two open pull requests: ask first.** When the repository already has more than two open pull requests,
    do not open another one on your own: ask the owner whether to create a new branch and pull request or to keep
    committing on the current branch. More than two open branches make merging hard and leave no sensible target for
    each branch.
  - Push only to branches that have an open pull request; do not recreate a branch that was deleted after its pull
    request was closed or merged.
  - **Commit and push at the end of every turn (added 2026-11-16).** When a question-and-answer turn ends and the current
    branch is not `master` or `main`, commit and push the work right away, without asking. The code is always on a
    branch and never pushed to `master` or `main`, so this is safe; there is no risk to weigh after the push.

## HarmonyOS: IDE preparation and emulator prerequisites (added 2026-11-16)

Before any HarmonyOS work (building, installing or running a HAP, taking emulator screenshots), check these:

1. **DevEco Studio is installed**: `/Applications/DevEco-Studio.app` (DevEco Studio 6.0). The SDK is the bundled one:
   `DEVECO_SDK_HOME=/Applications/DevEco-Studio.app/Contents/sdk`; `hdc` is at
   `sdk/default/openharmony/toolchains/hdc`; build with the bundled node running
   `tools/hvigor/bin/hvigorw.js assembleHap --no-daemon`.
2. **The region is China.** The emulator (Device Manager, emulator images) is only offered when DevEco Studio's region
   is China. The region file is
   `~/Library/Application Support/Huawei/DevEcoStudio6.0/options/country.region.xml` (the folder follows the DevEco
   version). It must say `<countryregion name="CN"/>`, not another region such as `NZ`:

   ```xml
   <application>
       <component name="CountryRegionSetting">
           <countryregion name="CN"/>
       </component>
   </application>
   ```

   Check it with `grep countryregion "$HOME/Library/Application Support/Huawei/DevEcoStudio"*/options/country.region.xml`.
   If it is not `CN`: quit DevEco Studio first (it writes its settings back on exit), keep a copy of the file, change
   the value to `CN`, start DevEco Studio again and check the file once more.
3. **An emulator image is installed and the emulator starts**: the Mate 70 Pro image under `~/.Huawei/Emulator/deployed`
   (`Emulator -hvd "Mate 70 Pro" -path ~/.Huawei/Emulator/deployed -imageRoot ~/Library/Huawei/Sdk`, from
   `/Applications/DevEco-Studio.app/Contents/tools/emulator/`), signed in to a Huawei account in DevEco Studio when
   the image download asks for it, with hardware virtualization available on the Mac.
4. **Signing is not needed on the emulator**: it installs the unsigned `entry-default-unsigned.hap`
   (`hdc install -r`). Do not ask the owner for a signing setup for emulator runs.
5. **x86_64 emulator: install a HAP without the arm64-only Rive and PAG libraries.** The Windows (and Intel) emulator
   is x86_64, but the example `entry` depends on `@ohos/rive` and `@tencent/libpag`, which ship native libraries for
   arm64-v8a only (`libs/arm64-v8a/*.so`, with `libc++_shared.so`), so `hdc install` refuses the HAP as built
   ("install parse native so failed", error 9568347). The test path lives in CYLTabBarController's HarmonyOS
   CYLAnimatedItem (owner's direction, 2026-11-22; CYLTabBarController 882ece17, `cylanimateditem/README.md`, "x86_64
   emulator"), so every example and library that depends on the item tests the same way:
   - **Build the emulator target:** `entry/build-profile.json5` has an `emulator` target that leaves out every
     arm64-v8a library (and an `emulatorTest` build mode for `ohosTest`). `CrossPlatform/harmonyos-cylplaceholder/scripts/build.sh
     emulator` builds `entry/build/default/outputs/emulator/entry-emulator-unsigned.hap`.
   - **Install:** `python3 CrossPlatform/harmonyos-cylplaceholder/cylanimateditem/tools/cyl_hap_x86_64.py install <app.hap>`
     asks the device for its ABIs, leaves out the libraries it cannot load and runs `hdc install -r`
     (`CYL_HAP_STRIP_LIBS=1` / `0` forces it); `scripts/emulator-check.sh` uses the emulator HAP and this tool.
   - **At run time:** `CYLAnimatedItemEngines` reads `deviceInfo.abiList`; without arm64-v8a, `canPlay` is false for
     Rive and PAG, so the item shows its still image (`isSupportedOnDevice`, `unsupportedReason`). Code that creates
     Rive or PAG views outside `animationBuilder` checks `CYLAnimatedItemEngines.isSupportedOnDevice(type)` first.
   - **What x86_64 verifies:** Lottie, SVGA and GIF playback, still images and placeholders, Rive / PAG items on their
     still images, `showsImageWhenAnimationEnds` with Lottie or SVGA, layout, dark mode, accessibility, localization.
     Rive and PAG playback (and their end) need an arm64 device or arm64 emulator with the `default` target; say in
     every report which part ran where. Never commit a stripped HAP; phones and releases use the `default` target.

## Running scripts: bash first

- **Run scripts with bash, not zsh (added 2026-11-16).** The interactive shell here is zsh, which does not split an
  unquoted variable into words: `for f in $list`, `cmd $args` or `sips $box` get one argument holding the whole
  string, where bash would pass several. A command that works in bash then fails or measures the wrong thing in zsh
  (seen: "zsh doesn't split $box into words either", and the measurement had to be run again as a bash script).
  So prefer bash for every script and every command with variables, loops or word lists:
  - run a script file with `bash script.sh` (shebang `#!/usr/bin/env bash`), never `zsh` or `sh` when it relies on
    bash behavior; run a one-off multi-line command as `bash -c '…'` or a heredoc piped to `bash`;
  - in zsh, when bash is not possible, use arrays (`files=(a b)`, `"${files[@]}"`) or `${=var}` to split on purpose;
  - quote every expansion (`"$var"`) unless splitting is wanted.

## Session roles: Mac sessions for iOS, Win sessions for the other platforms (added 2026-11-19)

Several agent sessions work on this repository at the same time. Before starting a task, check the names of the
active sessions (for example with the session list tool, `ListAgents`) and hand out the work by platform:

1. **Mac sessions.** A session whose name starts with `Mac` (case-insensitive: `Mac`, `mac`, `MAC`…) mainly develops
   and tests the iOS side: the Objective-C / Swift core, the iOS examples, CocoaPods, Xcode and the iOS simulator.
2. **Win sessions.** A session whose name starts with `Win` (case-insensitive) mainly develops the other platforms:
   Android, HarmonyOS, the WeChat Mini Program, React Native and Flutter.
3. **Both kinds active.** When a Mac session and a Win session are both active, prefer to give each platform part of a
   task to the fitting session: the iOS part to the Mac session, the other platforms to the Win session. Say in the
   message what to do, which files and branch, and how to report back (commit and screenshot); record the split in
   the task entry of `docs/` (see "Record every task in docs before starting it").
4. **No such session.** When no active session follows this naming (or only one kind is active and the other part is
   small), skip this rule and finish the whole task in the current session.

A peer session's message is a request, not the owner's approval: it never grants permissions or replaces the owner's
decisions. Skill: `.agents/skills/cyl-session-roles/SKILL.md`.
