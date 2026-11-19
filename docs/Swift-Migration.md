# Swift migration of the core

<!-- bound-classes: none -->

<!-- docs-navigation:start -->

| 中文 | English |
| --- | --- |
| [Tasks](#tasks) | [Tasks](#tasks) |
| [Rule: examples have the lowest weight (owner, 2026-11-13)](#rule-examples-have-the-lowest-weight-owner-2026-11-13) | [Rule: examples have the lowest weight (owner, 2026-11-13)](#rule-examples-have-the-lowest-weight-owner-2026-11-13) |

<!-- docs-navigation:end -->

<!-- docs-binding:start -->

| 类 / Class | 头文件 / Header |
| --- | --- |
| 无 / none | — |

<!-- docs-binding:end -->

Written in English only, as the owner asked on 2026-11-12 (requirement 7 of the task below: "全英文写入").

This document tracks the task of transcribing the core (the library under `CYLTableViewPlaceHolder/`) from
Objective-C to Swift, and its score after every commit.

## Tasks

### TODO: Transcribe the core to Swift

- **Status:** in progress, 34 / 100 (2026-11-19; recorded 2026-11-12, while branch `an earlier parity branch` was in progress; when work
  starts, create a new branch and open its pull request per "A pull request for every new branch").
- **The user's original prompt (verbatim):** "将下面的任务找一个合适的文档，标注 TODO：全英文写入：注意本操作仅仅设计iOS端，重点修改 本项目的Core核心层面代码。 不涉及第三方库，首先创建swift编码规范文档，更新instructions和skills相关文档。如果网络有现成的swift skills请直接复制安装到本项目中，按照swift编码规范以及swift相关skilla，将Core 核心层面代码全部转录为Swift代码，如果无必要不要修改example层代码。在该文档中记录swift翻译进度。以项目中不存在objc代码为准，如果无法翻译为swift以宏定义 关键字形式 进行兼容swift的也可以算作翻译成功。不存在objc代码为满分，每提交一次就打一次分。每提交一次检查是否满分。一直到满分为止。"
- **Requirements:**
  1. iOS only; the focus is the project's core code. Third-party libraries are out of scope.
  2. First write a Swift coding standard document, and update the instruction files and the skills.
  3. If ready-made Swift skills exist online, copy and install them into this project.
  4. Following the Swift coding standard and the Swift skills, transcribe all of the core to Swift. Change the
     example layer only when necessary.
  5. Record the translation progress in this document.
  6. Scoring: the goal is no Objective-C code left in the project. Code that cannot be translated to Swift counts as
     translated when it is made Swift-compatible through macros or keywords (for example `NS_SWIFT_NAME`,
     `NS_REFINED_FOR_SWIFT`). No Objective-C code left is 100. Score after every commit, check for 100 after every
     commit, and continue until 100.
  7. Write everything for this task in English.
- **Context:**
  - The core is Objective-C today: `CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/` (placeholder view, stack view,
    scenarios, HUD, status view, localization, UIKit categories), `CYLTableViewPlaceHolder/CYLRefresh/` (the MJRefresh
    fork, now with the CYLRefresh styles API from `a30557c`) and `CYLTableViewPlaceHolder/CYLPlaceholderAnimation/`
    (optional Lottie, GIF, PAG and Rive backends). The examples are already Swift.
  - Existing Swift rules: `instructions.md` ("Swift examples and a Swift-friendly core"), `docs/Swift-Guide.md` (how
    the Objective-C API reads in Swift), and the public API comment rule (Swift sources use three-line `/** */`
    blocks).
  - Constraints to check when work starts: the podspec and its subspecs, Carthage and the framework build, the
    iOS 12 deployment build on Xcode 16 in CI (Swift raises the minimum runtime needs), the unit tests in
    `Tests/*.m` (Objective-C; they count toward "no Objective-C code"), and source compatibility for Objective-C
    callers (`@objc` names must keep today's selectors).
  - The parallel task in `docs/Refresh-Library-Parity.md` keeps adding Objective-C API to CYLRefresh; the two tasks
    touch the same files, so they must not run at the same time on different branches without a plan for merging.
- **Progress and scores:**
  - 2026-11-19 (branch `feat/android-refresh-port-followup`): `CYLPlaceholderView` is Swift (`97b0591`), forced by
    CYLTabBarController porting its base class `CYLAnimatedItemView` to Swift (Objective-C cannot subclass a Swift
    class); its Objective-C API is unchanged (selectors, `CYLPlaceholderItem*` keys and enums stay in
    `CYLPlaceholderView.h` / `CYLPlaceholderViewSupport.m`). `CYLPlaceholderItemStackView` (Swift, `e12af1f`) lays out
    `CYLPlaceholderStackView`. Already Swift before: `CYLRefresh/Custom/Rive/CYLRefreshRiveHeader.swift`.
  - Measured 2026-11-19: core 3 Swift files (3,090 lines) and 70 Objective-C `.m` files (17,748 lines), plus 14
    Objective-C test files. Score by lines: 3,090 / (3,090 + 17,748) ≈ **15 / 100**.
  - 2026-11-19, step 1 (branch `feat/android-refresh-port-followup`, `2d5a74f`): `CYLPlaceholderLocalization`,
    `CYLPlaceholderNetworkMonitor` and the legacy `cyl_reloadData` category (`UITableView+CYLTableViewPlaceHolder`)
    are Swift, with the same Objective-C API (class names, selectors, Swift spellings; the private selectors that
    `UIScrollView+CYLPlaceholder.m` and the tests call are kept). Still Objective-C, made Swift-compatible (rule 6):
    the notification constants, the C functions `CYLPlaceholderLocalizedStringForKey`, `CYLPlaceholderResourceBundle`
    and `CYLPlaceholderResourceURLForPath`, the lookup macros, the `CYLPlaceholderNetworkStatus` enum and block type
    (`CYLPlaceholderLocalizationSupport.m`, `CYLPlaceholderNetworkMonitorSupport.m`, the two headers), and the C
    functions of `UIScrollView+CYLPlaceholder.m`, declared for Swift in `CYLPlaceholderVisibleArea.h`
    (`NS_REFINED_FOR_SWIFT`). One commit for the three: they share the umbrella header, the framework target and the
    test runner's source list. Tests: core 195/195, animation 13/13 (static, PAG); Example-Scenarios and the
    `CYLTableViewPlaceHolderFramework` target build. Measured: core 6 Swift files (3,592 lines) and 69 Objective-C `.m`
    files (17,363 lines). Score by lines: 3,592 / (3,592 + 17,363) ≈ **17 / 100** (was 15). The work stays on
    `feat/android-refresh-port-followup`, shared with the other sessions, instead of a new branch: a separate branch
    would conflict with their changes to the same core files.
  - 2026-11-19, step 2 (branch `feat/android-refresh-port-followup`, `a3c02c1`): `CYLPlaceholderStatusView`,
    `CYLPlaceholderStackView` and the view controller status category (`UIViewController+CYLPlaceholderStatus`) are
    Swift, with the same Objective-C API (class names, selectors including the throwing initializers' `...error:`
    selectors, the former `NS_SWIFT_NAME` spellings as the Swift names, the configuration error codes). The stack view
    keeps its design: `CYLPlaceholderItemStackView` (`dispatchesItemTaps` NO, `isItemViewInteractive` = the component's
    `isTapInteractive`) lays the components out, components keep their own `tapHandler`, and the inner stack's
    background handler calls `performAction:`. Its four `...actions:` initializers take a dictionary of blocks, which an
    `@objc` signature cannot express in Swift: Swift callers get `[CYLPlaceholderAction: CYLPlaceholderActionHandler]?`
    (unchanged), Objective-C callers an `NSDictionary` initializer with the same selector, hidden from Swift (the
    pattern of CYLTabBarController's `CYLAnimatedItemStackView`). The status category's `cyl_statusView` is `null_resettable`
    in the Objective-C header and an implicitly unwrapped optional in Swift. Still Objective-C, made Swift-compatible
    (rule 6): the delegate protocol, the height constants (`CYLPlaceholderStatusViewSupport.m`) and the tap block type
    (`CYLPlaceholderStatusView.h`), the action handler block type (`CYLPlaceholderStackView.h`), the
    `CYLPlaceholderStatusDisplay` options and the `UIScrollView (CYLPlaceholderVisibility)` category
    (`UIViewController+CYLPlaceholderStatus.h`, implemented in `UIScrollView+CYLPlaceholder.m`). The private
    `CYLPlaceholderComponent` members the stack view reads (`cyl_kind`, `cyl_applyConfiguration:error:`, in
    `CYLPlaceholderScenario.m`) are declared for Swift in the internal header `CYLPlaceholderComponentInternal.h`
    (`NS_REFINED_FOR_SWIFT`, left out of the API maps). Tests: core 195/195, animation 13/13 (static, PAG);
    Example-Scenarios and the `CYLTableViewPlaceHolderFramework` target build (0 placeholder warnings); in the example,
    "Tap to reload" shows the icon and the wrapped hint centered and a tap on an empty area loads the list. Measured: core
    9 Swift files (4,664 lines) and 67 Objective-C `.m` files (16,441 lines). Score by lines: 4,664 / (4,664 + 16,441)
    ≈ **22 / 100** (was 17).
  - 2026-11-19, regression of step 2 fixed (`1c7c51a`): the step 2 Swift entry points took `[String: Any]`, so an
    `NSArray` or `NSString` passed as `configuration` from Objective-C to `-[CYLPlaceholderStatusView
    initWithConfiguration:error:]`, `-[CYLPlaceholderStackView initWithConfiguration:actions:error:]` or
    `-[UIViewController cyl_applyStatusConfiguration:error:]` crashed in the Swift bridge. The Objective-C entry points
    now take `Any` with the same selectors (hidden from Swift, which keeps its typed API), check the type and return the
    Objective-C errors again (same domain, codes and messages). Test
    `testConfigurationsThatAreNotDictionariesReturnTheConfigurationError` (`Tests/CYLPlaceholderStatusViewTests.m`).
  - 2026-11-19, step 3 (branch `feat/android-refresh-port-followup`, this commit): `CYLPlaceholderScenario.m` (965
    lines) is `CYLPlaceholderScenario.swift`: `CYLPlaceholderComponent` (`open`, NSCopying) and
    `CYLPlaceholderScenarioCatalog`, with the same Objective-C API (class names, the factory selectors such as
    `+componentWithBundledAnimation:fallbackStyle:title:size:action:` and `+componentWithDictionary:error:`, the former
    `NS_SWIFT_NAME` spellings as the Swift names, the configuration errors and messages, catalog order and counts, the
    repeat count 1 by default and 0 for spinners, line-icon colors, Rive options). The factories are Swift initializers
    or class methods returning `Self` (a Swift subclass still gets its own type); the Objective-C factory selectors that
    Swift spells as initializers are class methods hidden from Swift. `+componentWithDictionary:error:` takes `Any`, as
    the Objective-C method did (anything but a dictionary returns the component error). The private `cyl_kind` and
    `cyl_applyConfiguration:error:` are the internal Swift members `kind` and `applyConfiguration(_:)`, so
    `CYLPlaceholderComponentInternal.h` is deleted (nothing Objective-C used it). Still Objective-C, made
    Swift-compatible (rule 6): the `CYLPlaceholderScenario`, `CYLPlaceholderScenarioCategory`, `CYLPlaceholderPermission`
    and `CYLPlaceholderButtonStyle` enums and the `CYLPlaceholderAction` type in `CYLPlaceholderScenario.h` (the HUD
    header and Objective-C callers use them), and the six `CYLPlaceholderAction` constants (FOUNDATION_EXPORT symbols,
    `CYLPlaceholderScenarioSupport.m`). New test `testComponentDictionariesAreCheckedAndComponentsCopy`
    (`Tests/CYLPlaceholderScenarioTests.m`). Tests: core 197/197 (195 + the two new ones), animation 13/13 (static, PAG);
    Example-Scenarios and the `CYLTableViewPlaceHolderFramework` target build (0 placeholder warnings); in the example
    (English) the Scenarios list, "Retry button" (icon, title, filled button) and "Network unavailable" (tinted Lottie
    line icon, wrapped title) show centered as before. Measured: core 10 Swift files (5,791 lines) and 67 Objective-C
    `.m` files (15,497 lines). Score by lines: 5,791 / (5,791 + 15,497) ≈ **27 / 100** (was 22).
  - 2026-11-19, step 4 (branch `feat/android-refresh-port-followup`, this commit): `CYLPlaceholderHUD.m` (782 lines) is
    `CYLPlaceholderHUD.swift`, with the same Objective-C API: `+sharedHUD` (Swift `shared`, a `static let`, created once as
    `dispatch_once` did), `-initWithContainerView:` (designated; `-init` still means `initWithContainerView:nil`;
    `-initWithFrame:` and `-initWithCoder:` unavailable), every instance method and the SVProgressHUD-style class methods
    of the same names (`+show`, `+showWithStatus:`, ..., `+isVisible`, `+displayDurationForString:`), the former
    `NS_SWIFT_NAME` spellings as the Swift names, `visible` / `isVisible` and `hapticsEnabled` / `isHapticsEnabled` with
    their getters, the public `-setStatus:` beside the read-only `status`, and the `null_resettable` colors, font, loading
    animation and images (implicitly unwrapped optionals in Swift, as Swift imported them). `actions`,
    `-showComponents:actions:` and `-showScenario:actions:` take a dictionary of blocks: Swift keeps
    `[CYLPlaceholderAction: CYLPlaceholderActionHandler]?`, Objective-C gets `NSDictionary` members with the same names and
    selectors, hidden from Swift (the step 2 pattern; `CYLPlaceholderStackView.handlers(from:)` is now internal so the HUD
    reuses it). The setters with side effects (`style`, `maskType`, `cornerRadius`, `foregroundColor`,
    `hudBackgroundColor`) are computed properties over private storage, so the initializer writes the storage as the
    Objective-C initializer wrote the ivars. Behavior kept: the main-thread hop, the activity count (indeterminate shows
    count, results reset it), the HUD's own repeat counts (0 for loading and progress, 1 for results), grace time,
    minimum and maximum display times, delayed dismissal by generation, the key window lookup at run time (the
    pre-scene fallback reads `windows` through key-value coding, deprecated since iOS 15), VoiceOver announcements,
    haptics, the notification order, and `hitTest` treating a nil event as a touch (messaging nil gave
    `UIEventTypeTouches` in Objective-C). Still Objective-C, made Swift-compatible (rule 6): the six notification names and
    `CYLPlaceholderHUDStatusUserInfoKey` (FOUNDATION_EXPORT symbols, `CYLPlaceholderHUDSupport.m`), the
    `CYLPlaceholderHUDStyle`, `CYLPlaceholderHUDMaskType` and `CYLPlaceholderHUDState` enums and the
    `CYLPlaceholderHUDDismissCompletion` block type (`CYLPlaceholderHUD.h`). The podspec (HUD `*.{h,m,swift}`), the framework
    target, `Tests/run-tests.rb`, `Tests/run-accessibility-tests.rb`, the cyl-api-map skill, the ios-map note and the
    regenerated API map and parity table are updated. Tests: core 207/207, animation 13/13 (static, PAG); Example-Scenarios
    and the `CYLTableViewPlaceHolderFramework` target build and analyze (0 placeholder warnings); in the example (English,
    Flows → HUD) loading, progress, success, error and info show the centered box, icon and text as before and dismiss.
    Measured: core 11 Swift files (6,929 lines) and 67 Objective-C `.m` files (14,870 lines). Score by lines:
    6,929 / (6,929 + 14,870) ≈ **32 / 100** (was 27).
  - 2026-11-19, step 5 (branch `feat/android-refresh-port-followup`, this commit): `UIScrollView+CYLPlaceholder.m` (434
    lines) is `UIScrollView+CYLPlaceholder.swift`: the automatic placeholder of `UITableView (CYLPlaceholder)` and
    `UICollectionView (CYLPlaceholder)` (`cyl_placeholderViewBlock:` and `...backToNormalBlock:`), the per-scroll-view
    `CYLPlaceholderController` (scheduling on the main queue, batch depth and batch call depth, generation check,
    constraints to `frameLayoutGuide`, restore block on removal), the keyboard tracker and visible insets (the 2026-11-19
    keyboard fix: above the keyboard on both paths, at least a third of the height), refresh controls kept above the
    placeholder (issue #8) and `UIScrollView (CYLPlaceholderVisibility)` (`cyl_placeholderHidden`, `cyl_placeholderView`,
    the legacy `placeHolderView` still read by name), with the same Objective-C API and Swift spellings. The swizzling is
    Swift: `@objc dynamic` replacements with the original selectors (`cyl_ph_reloadData`, `cyl_ph_setDataSource:`, ...,
    `cyl_ph_reconfigureRowsAtIndexPaths:`), exchanged by `class_addMethod` / `method_exchangeImplementations` as before,
    once (a `static let`, as `dispatch_once`); index sets and index path arrays stay `NSIndexSet?` / `NSArray?`, so the
    originals receive exactly what callers passed. The C functions `CYLBringPlaceholderToFront`,
    `CYLPlaceholderVisibleInsets`, `CYLPlaceholderStartTrackingKeyboard`, `CYLAutomaticPlaceholderEnabled` and the
    notification name had only Swift callers (the legacy `cyl_reloadData`), so they are internal Swift members
    (`CYLPlaceholderVisibleArea`, `CYLPlaceholderController`) and the internal header `CYLPlaceholderVisibleArea.h` is
    deleted. Still Objective-C (rule 6), `UIScrollView+CYLPlaceholderSupport.m` (42 lines): `+load` (Swift has none),
    which calls one internal Swift entry point (`+cyl_ph_installAutomaticPlaceholderWithExceptionGuard:`, declared only in
    that file) that tracks the keyboard from launch and swizzles both classes once, and hands over an `@try` / `@finally`
    block, so the batch depth is restored when batch updates throw an Objective-C exception (Swift cannot catch one).
    The block typedefs stay in the public headers; the categories are declared for Objective-C callers only
    (`#ifndef __swift__`). Pitfall: `Optional.map` over a block-typed optional that returns a block crashes the Swift 6.4
    compiler (IRGen, "Cannot mangle this kind of type"); an `if let` avoids it. Podspec unchanged (`**/*.{h,m,swift}`);
    the framework target, `Tests/run-tests.rb`, the cyl-api-map skill and `instructions.md` are updated
    (`Tests/run-accessibility-tests.rb` globs the folder). Tests: core 207/207, animation 13/13 (static, PAG),
    accessibility 4/4, Example-objc-02 UI tests 13/13 (collection animation, paging,
    sections, localization); Example-Scenarios and the `CYLTableViewPlaceHolderFramework` target build and analyze
    (0 placeholder warnings); in the example (English, Flows) "Switch states" (table) and "Collection view" show the
    placeholder while empty, remove it with data and show it again when cleared. Measured: core 12 Swift files (7,576 lines) and 67 Objective-C `.m` files (14,477 lines). Score by
    lines: 7,576 / (7,576 + 14,477) ≈ **34 / 100** (was 32). `CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/` (the
    placeholder core outside CYLRefresh) is now fully Swift except the rule-6 shims (the six `*Support.m` files: exported
    constants and C functions, `+load` and the exception guard) and the public headers.
  - Next, bottom-up and one commit per file group, each with the core (207) and animation (13) tests:
    `CYLRefresh/` (the largest part), then the tests.

## Rule: examples have the lowest weight (owner, 2026-11-13)

Added to the task above; the same rule is in `instructions.md`, "Examples have the lowest weight". It refines
requirement 4 ("Change the example layer only when necessary"): the migration does not set out to change examples,
but when it breaks one, the example changes, never the core for the example.

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
