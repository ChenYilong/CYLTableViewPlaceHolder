# macOS-only scenario (`macos`)

Full text of the `macos` rules (iOS, Xcode, CocoaPods, Swift, zsh vs bash), moved verbatim from `instructions.md` and `AGENTS.md` on 2026-11-22 (owner's
rule: instruction files by tag, at most 200 lines each). Summaries: [instructions.md](../../instructions.md) and
[AGENTS.md](../../AGENTS.md), heading "Tag: macOS-only scenario". English only.

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

## Simulator rules: stop the app and the simulator after a run (owner's rule, 2026-11-25)

Read this section, or the short text in `instructions.md` / `AGENTS.md`, before running any simulator.

- **Owner's words (verbatim):** 运行模拟器 测试截图结束后 ，立即杀掉终止app，以及模拟器进程。使用时在重新启动。避免运行后，任务完毕也不关掉app ，也不关闭模拟器进程。
- **In English:** when a simulator run (tests, screenshots) is finished, immediately terminate the app and shut down the simulator
  process; boot it again only when the next run needs it. Never leave the app running or the simulator booted after the task is done.
- **How:** at the end of each run or capture batch, `xcrun simctl terminate <UDID> <bundle id>` for each app you started,
  `xcrun simctl shutdown <UDID>`, then stop the helper processes you started (a `simctl io … recordVideo` recording, an `axe`
  driver, a leftover `xcodebuild test`), and check with `xcrun simctl list devices booted` that your UDIDs are gone.
- **Only your own simulators.** The Mac is shared: shut down only the UDIDs you booted, never `simctl shutdown all`, never a
  simulator another session or agent is using (see the own-simulator rules in `cyl-verify`). A batch that still has steps to run
  keeps its simulator until the last step; stopping is part of finishing the batch, not an optional cleanup.
- **Subagents:** every brief that uses a simulator must say "terminate the app and shut down your own simulator when you finish,
  and report that you did".

## AGENTS.md: Naming and compatibility

- The library supports iOS 15.0 and later (raised from 12.0 on 2026-11-20, the owner's decision: "raise iOS .spec the
  minimum to iOS 15"; CHANGELOG.md); the podspec says `15.0`. Guard APIs newer than 15 with `@available`; there are no
  iOS 12-14 branches any more. Runnable projects' Podfiles follow the iOS 15.0 rules in
  `instructions.md`; their CocoaPods dependencies consequently require iOS 15.

- Preserve the Xcode project format: `objectVersion = 46`,
  `compatibilityVersion = "Xcode 3.2"`, explicit file references, and a shared
  scheme. Do not copy device identifiers or signing credentials from another
  machine.

## AGENTS.md: Project and verification

- The main example (`Examples/Example`, Swift) embeds the project's own framework target
  (`CYLTableViewPlaceHolderFramework`, module `CYLTableViewPlaceHolder`) and does not require
  `pod install`. Keep the source files, the resource bundle,
  privacy manifest, and third-party license in the framework target, the app and the podspec.

- Examples contain no Objective-C. When Swift needs a better spelling of a core API, add a Swift
  naming macro (`NS_SWIFT_NAME`, `NS_REFINED_FOR_SWIFT`, `NS_SWIFT_UNAVAILABLE`) next to the
  Objective-C declaration; never change the Objective-C interface itself.

- iOS examples are written in Swift (the library stays Objective-C). When a Swift call
  reads like Objective-C, adapt the core: nullability, `NS_SWIFT_NAME` on new
  declarations, `cyl_` members keep their prefix, and underscored protocol methods get an
  underscore-free sibling instead of a rename. Follow CYLTabBarController's
  `docs/Swift-Guide.md` and record verified spellings in `docs/Swift-Guide.md`. See
  "Swift examples and a Swift-friendly core" in `instructions.md`.

- Run `ruby Tests/run-tests.rb` for relevant simulator tests. Use `DESTINATION`
  to select an installed simulator. Build the example and validate the
  podspec when their integration changes; see `cyl-verify`.

- Xcode 27's simulator SDK requires a deployment target of at least 15.0 during
  builds. Override the build target for that toolchain instead of changing the
  library's minimum (15.0 since 2026-11-20); CI's "iOS 15 deployment build" and "iOS 15 runtime" use 15.0.

## AGENTS.md: Running scripts: bash first

- **Run scripts with bash, not zsh (added 2026-11-16).** The interactive shell here is zsh, which does not split an
  unquoted variable into words: `for f in $list`, `cmd $args` or `sips $box` get one argument holding the whole
  string, where bash would pass several. A command that works in bash then fails or measures the wrong thing in zsh
  (seen: "zsh doesn't split $box into words either", and the measurement had to be run again as a bash script).
  So prefer bash for every script and every command with variables, loops or word lists:
  - run a script file with `bash script.sh` (shebang `#!/usr/bin/env bash`), never `zsh` or `sh` when it relies on
    bash behavior; run a one-off multi-line command as `bash -c '…'` or a heredoc piped to `bash`;
  - in zsh, when bash is not possible, use arrays (`files=(a b)`, `"${files[@]}"`) or `${=var}` to split on purpose;
  - quote every expansion (`"$var"`) unless splitting is wanted.
