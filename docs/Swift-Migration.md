# Swift migration of the core

<!-- bound-classes: none -->

<!-- docs-navigation:start -->

| 中文 | English |
| --- | --- |
| [Tasks](#tasks) | [Tasks](#tasks) |
| [Rule: examples have the lowest weight (owner, 2026-11-13)](#rule-examples-have-the-lowest-weight-owner-2026-11-13) | [Rule: examples have the lowest weight (owner, 2026-11-13)](#rule-examples-have-the-lowest-weight-owner-2026-11-13) |
| [Migration note: three `CYLPlaceholderView` properties moved to the engine (2026-11-25, `999049e7`)](#migration-note-three-cylplaceholderview-properties-moved-to-the-engine-2026-11-25-999049e7) | [Migration note: three `CYLPlaceholderView` properties moved to the engine (2026-11-25, `999049e7`)](#migration-note-three-cylplaceholderview-properties-moved-to-the-engine-2026-11-25-999049e7) |

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

### 已完成 / Done: Transcribe the core to Swift

- **Status:** 已完成 / Done (2026-11-20, step 13): **100 / 100 by rule 6** for the core and the tests (98 / 100 by
  lines: 32,265 Swift lines against 758 Objective-C `.m` lines, every one a rule-6 shim or the agreed Objective-C smoke
  test). Recorded 2026-11-12, while branch `an earlier parity branch` was in progress; done on
  `feat/android-refresh-port-followup`.
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
  - 2026-11-19, step 6 (branch `feat/android-refresh-port-followup`, this commit): the `CYLRefresh/` root is Swift:
    `CYLRefreshConfig.swift`, `NSBundle+CYLRefresh.swift`, `UIView+CYLExtension.swift`, `UIScrollView+CYLExtension.swift`,
    `UIScrollView+CYLRefresh.swift` and `UICollectionViewLayout+CYLRefresh.swift` replace the six `.m` files (757 lines),
    with the same Objective-C API (class name, `+defaultConfig` as Swift `default`, every selector, the Swift spellings
    of `cyl_beginRefreshing(startHeader:)`, `cyl_endRefreshing(afterDelay:success:noMoreData:)`, ...). The accessors and
    category methods are `@objc dynamic`, so Swift callers dispatch through the Objective-C runtime as before (method
    replacement, as `testMissingRefreshBundleFallsBackWithoutException` does with `+cyl_refreshBundle`, and KVO keep
    working); every setter writes `frame` / `contentInset` / `contentOffset` / `contentSize` once, as before. The setter
    of `languageCode` is computed over private storage (nil never equals, so setting nil always resets the caches and
    posts `CYLRefreshDidChangeLanguageNotification`, as `isEqualToString:` on nil did); the language lookup and its
    caches are kept (`languageCode`, else the preferred language, else English; `i18nBundle` / `i18nFilename` win). The
    categories are declared for Objective-C only (`#ifndef __swift__`) in their headers, so `Base/`, `Custom/` and the
    tests compile unchanged; `CYLRefreshConfig.h` keeps a forward declaration and `CYLRefreshStateHeader.m` imports the
    umbrella header for the generated Swift header (`CYLRefreshComponent.m` already did). Swift spellings that changed:
    `Bundle.cyl_refresh()` returns `Bundle!` (was `Self`; the bundle lookup can return nil), `cyl_arrowImage()` /
    `cyl_trailArrowImage()` return `UIImage!`, and `cyl_beginRefreshing(startHeader:)` takes an optional (the method
    always handled nil). `cyl_inset` reads `adjustedContentInset` without the iOS 11 check (the library needs iOS 12).
    The start header calls `CYLRefreshComponent`'s private `-cyl_hasCallbacks` / `-cyl_copyTargetActionsFrom:` by
    selector until step 7, and copies the refreshing target and action only when there is a target (without one, the
    Objective-C copy called nothing either). Still Objective-C (rule 6): `CYLRefreshConst.h` / `.m` (exported constants,
    C macros, the inline `CYLRefreshExchangeImplementations`; all Swift-readable, nothing Swift can declare);
    `UIScrollView+CYLExtensionSupport.m` (53 lines: `+load`, which hands Swift the writer of the bottom, left and right
    insets with its `@try` / `@finally` depth count, and the C function `CYLRefreshIsWritingSideInset()` that
    `CYLRefreshHeader.m` calls); `UICollectionViewLayout+CYLRefreshSupport.m` (32 lines: `+load`, which calls the Swift
    entry point that exchanges `finalizeCollectionViewUpdates` once); the umbrella `CYLRefresh.h` and the headers. The
    podspec (Core adds `CYLRefresh/*.swift`; `Custom/Rive/*.swift` stays in the Rive subspec), the framework target,
    `Tests/run-tests.rb`, `Tests/run-accessibility-tests.rb`, the cyl-api-map skill, `instructions.md` and the
    regenerated parity table are updated. Tests: core 207/207, animation 13/13 (static, PAG), accessibility 4/4,
    Example-objc-02 UI tests (collection animation, paging, sections, localization) 12/13 on the first full run, with `testDraggingDuringHeaderRefreshKeepsFirstItemPosition` flaky under a load average of 76 to 208 (it then passed 1 of 2 reruns; the same test on the parent commit `3013f38` failed 2 of 2 reruns in the same conditions, so it is not a regression of this step); Example-Scenarios
    and the `CYLTableViewPlaceHolderFramework` target build and analyze (0 placeholder warnings, no warning in the new
    files); in the example (More → Refresh) the normal header ("Loading...", "Last update: Today …", spinner left of the texts), the animated-image header (icon beside the two lines) and the automatic footer ("Loading..." right below the last row) show and place their texts as before, in English and Simplified Chinese ("正在刷新数据中...", "最后更新：今天 …"). Measured: core 18 Swift files (8,551 lines) and 63 Objective-C `.m` files (13,808 lines).
    Score by lines: 8,551 / (8,551 + 13,808) ≈ **38 / 100** (was 34).
  - 2026-11-19, step 7 (branch `feat/android-refresh-port-followup`, this commit; leaves first): the classes with no
    Objective-C subclass are Swift, with the same Objective-C API (class names, selectors, the former `NS_SWIFT_NAME`
    spellings as the Swift names). Checked before translating each one with
    `git grep -P "@interface\s+\w+\s*:\s*<Class>(?!\w)"` (the `\b` form of `git grep -E` matches nothing on macOS, so it
    misses subclasses). Translated:
    - `Base/CYLRefreshIconView.swift` (with the class members of the former `CYLRefreshIconView (CYLRefreshIconAttributes)`
      category): the playback policy, the 2026-11-19 speed / loop / replay API (`animationSpeed`, `loopsWhilePlaying`,
      `replayAnimation`) and the bundled-icon attributes without the scenario repeat count; the setters with side effects
      (`title`, `titleFont`, `titleColor`, `animationSpeed`, `loopsWhilePlaying`) are computed properties over private
      storage; the state attributes stay an `NSMutableDictionary` and the shown attributes an `NSDictionary`, so the
      "any state" fallback and the equality check are the same. `CYLRefreshIconView.h` keeps the forward declaration, the
      `CYLRefreshIconAnimating` protocol and the `CYLRefreshComponent (CYLRefreshIconLayout)` category (implemented in
      `CYLRefreshComponent.m`).
    - `Base/CYLRefreshPaging.swift`: the easy_paging rules (generation check, commit after success, no more data from the
      total, then the page count); the block types stay in `CYLRefreshPaging.h`; `-init` is unavailable.
    - `Custom/Drawn/Support/`: `CYLRefreshValueAnimator.swift` (display link and `CACurrentMediaTime`, the original float
      literals of the bounce curve and the `floatValue` reads of the points kept; the 2026-11-19 leak fix kept: it stops
      once its target and delegate are gone, `testEndlessValueAnimatorStopsWhenItsTargetIsReleased`), with the
      `CYLRefreshAnimatorInterpolator` / `CYLRefreshAnimatorRepeatMode` enums (Swift `@objc` enums whose Objective-C case
      names stay `AnimatorInterpolatorLinear`, ...) and the `CYLRefreshValueAnimatorDelegate` protocol; the vector classes
      `CYLRefreshVectorElement` and its subclass `CYLRefreshVectorPathElement` (converted together), `CYLRefreshVectorImage`
      (the `float` scale of `-scaleToFitInside:` kept), `CYLRefreshVectorUtilities`, `CYLRefreshVectorView`;
      `CYLRefreshVectorPathsParser.swift` (internal: its only caller is the path element and its API passes a C struct,
      so `CYLRefreshCurve` is a Swift struct and `CYLRefreshVectorPathsParser.h` is deleted; it calls the same `NSScanner`
      selectors as before through the runtime, so numbers parse exactly as before and the iOS 13 deprecations are not
      reported); `CYLRefreshStoreHouseLine`, `CYLRefreshStoreHousePath` (the glyph tables built once on first use; the
      original's '-' entry overwritten by the dot's stroke is kept); `CYLRefreshFlyView`, `CYLRefreshMountainView`;
      `CYLRefreshGameStartScene` (nil colors reach SpriteKit through key-value coding, as the Objective-C messages sent
      them).
    The Swift support classes are `public` only because the module's Objective-C drawn styles read them through the
    generated Swift header (a framework's generated header has only public declarations); the private headers keep
    forward declarations, the `CYLRefreshAnimatorInterpolatorBlock` typedef and the `CYLREFRESH_SCREEN_WIDTH` /
    `CYLREFRESH_RATIO_X` / `CYLREFRESH_RATIO_Y` macros (rule 6). Objective-C files that use the Swift classes import the
    umbrella header (the eleven drawn styles that use them, the animation header and both animation footers).
    **Skipped:** `CYLRefreshGamePlayingScene` stays Objective-C: `BattleCityScene` and `HitBlockScene`
    (`CYLRefreshGameBattleCityHeader.m`, `CYLRefreshGameHitBlockHeader.m`) subclass it; it moves with them in step 8.
    **Not kept identical, on purpose:** `CYLRefreshMountainView` mixes a grayscale `colorPrimary` as gray (the
    Objective-C code read past its two components, undefined behavior); `CYLRefreshIconView` treats a size array whose
    last element does not answer `doubleValue` as no size (Objective-C raised an unrecognized-selector exception);
    `CYLRefreshVectorView` ignores a nil tint color (Objective-C raised when adding nil to an array);
    `-[CYLRefreshVectorImage renderInContext:]` does nothing without a context. Podspec (Core adds
    `CYLRefresh/Base/*.swift` and `CYLRefresh/Custom/Drawn/Support/*.swift`), the framework target, `Tests/run-tests.rb`,
    `Tests/run-accessibility-tests.rb` (every CYLRefresh Swift file but the Rive header), the cyl-api-map skill and the
    regenerated parity table (its iOS descriptions of `CYLRefreshIconView` now come from the Android KDoc, as for the
    earlier steps' classes) are updated. Tests: core 207/207, animation 13/13 (static, PAG), accessibility 4/4,
    Example-objc-02 UI tests 13/13 (collection animation, paging, sections, localization); Example-Scenarios and the
    `CYLTableViewPlaceHolderFramework` target build and analyze (0 placeholder warnings, no warning in the new files; the
    7 reported CYLRefresh warnings are in unchanged Objective-C files); in the example (English, More → Refresh →
    CYLRefresh styles) StoreHouse, Phoenix, Taurus, Fly and GameHitBlock (start scene and game) draw and animate while
    refreshing, and More → Feed → Refresh icons → `CYLRefreshActivity.gif` shows the playing icon beside "Loading...".
    Measured: core 32 Swift files (11,763 lines) and 49 Objective-C `.m` files (10,880 lines). Score by lines:
    11,763 / (11,763 + 10,880) ≈ **52 / 100** (was 38).
  - 2026-11-19, step 8 (branch `feat/android-refresh-port-followup`; `e0315fa`, `27f086c`, `c58045f`; leaves first inside
    `Custom/Drawn`): checked before each base with `git grep -P "@interface\s+\w+\s*:\s*<Class>(?!\w)"` across the repo
    (Examples, Tests, CrossPlatform). **Subclass found, base not converted:** `Tests/CYLRefreshDrawnHeaderTests.m` declares
    `CYLStatusRecordingHeader : CYLRefreshBezierRadarHeader` (Objective-C, it records the status order), so
    `CYLRefreshBezierRadarHeader` and its base `CYLRefreshDrawnHeader` stay Objective-C until the tests move (step 13) or
    the owner decides otherwise; the Swift subclasses of `CYLRefreshDrawnHeader` in the examples (`CYLRefreshSVGASceneHeader`,
    `CYLRefreshRiveHeader`) keep working unchanged. Translated, with the same Objective-C API (class names, selectors,
    former `NS_SWIFT_NAME` spellings as Swift names, the overridable hooks `open` with the same selectors):
    - part 1 (`e0315fa`): `CYLRefreshDrawnFooter.swift`: the drawn footer base (subclass of the Objective-C
      `CYLRefreshBackStateFooter`; `+styleClass`, `-initWithStyle:`, `style`), the BezierRadar, Material, Delivery,
      Phoenix and Taurus footers, `CYLRefreshBallPulseFooter` (subclass of the Objective-C `CYLRefreshAutoFooter`) with its
      weak display-link ticker; the hosted header's private driven mode (`-cyl_beginDriven`, `-cyl_driveFrame:`, ...) and
      `CYLRefreshBackFooter`'s private `-happenOffsetY` are called by selector (the pattern of
      `UIScrollView+CYLRefresh.swift`); and `CYLRefreshFlyHeader.swift`.
    - part 2 (`27f086c`): the games: `CYLRefreshGameHeader.swift` (the private `-newPlayingScene` hook is the internal
      `makePlayingScene()`), `CYLRefreshGameBattleCityHeader.swift` and `CYLRefreshGameHitBlockHeader.swift` with their
      private scenes, and `CYLRefreshGamePlayingScene` (skipped in step 7), now internal, so its private header is deleted
      (the frozen `scripts/ios-public-api.json` keeps the maps valid). The Swift scenes implement `init(size:)`, which
      SKScene's `-init` calls (the first test run trapped without it).
    - part 3 (`c58045f`): the header styles BezierCircle, Delivery, DropBox (private `BoxBody`), Material (`shapeLayer`
      stays readable by key-value coding for the tests; `CYLRefreshMaterialSize` stays in the header), Original,
      Phoenix, StoreHouse (the 2026-11-19 leak fix kept: a weak block timer, invalidated in `deinit`; `-init` still draws
      "store house"; the `+newWithString:...` factories keep their selectors, hidden from Swift, which keeps
      `init(string:...)`; `-initLinesWith...:` keep their selectors as `setLines(...)`), Taurus and WaveSwipe.
    The headers keep doc-commented forward declarations (and public enums); Objective-C callers import the umbrella header.
    **Still Objective-C:** `CYLRefreshDrawnHeader` (base, with the variadic `-inStatus:`) and `CYLRefreshBezierRadarHeader`
    (the subclass in the tests), plus the Objective-C bases outside `Custom/Drawn` that the Swift classes subclass
    (`CYLRefreshHeader`, `CYLRefreshBackStateFooter`, `CYLRefreshAutoFooter`, steps 9 to 11). **Not kept identical, on
    purpose:** drawing without a graphics context does nothing; Phoenix keeps its sky colors with a nil `colorPrimary` and
    HitBlock's contact end skips a body without a node (Objective-C raised on a nil array element); a non-finite value
    truncated to an integer gives 0 instead of trapping; BattleCity's unused `isGameWin` (always NO) is dropped. Podspec
    (Core adds `CYLRefresh/Custom/Drawn/*.swift`), the framework target, the cyl-api-map skill and the regenerated parity
    table are updated; the test runners glob the folder. Tests: core 207/207 after each part, animation 13/13 (static,
    PAG), accessibility 4/4 (CI runner on the CYL Placeholder Screens simulator); Example-objc-02 UI tests 12/13 on the
    full run with only `testDraggingDuringHeaderRefreshKeepsFirstItemPosition` failing under a load average of 75 to 122
    (it passed 1 of 2 reruns; Example-objc-02 uses only the Normal header and footers, untouched by this step);
    Example-Scenarios and the `CYLTableViewPlaceHolderFramework` target build and analyze (0 placeholder warnings, no
    warning in the new files; 5 CYLRefresh warnings in unchanged Objective-C files, was 7). Simulator check (English,
    More → Refresh → CYLRefresh styles): every drawn header (Delivery, DropBox, Phoenix, Taurus, BezierRadar,
    BezierCircle, StoreHouse, WaveSwipe, Original, Material, GameHitBlock, GameBattleCity, Fly), SVGA · Bow and Rive · Bow,
    the five drawn footers and both Space footers (SVGA, Rive, hosted by the Swift `CYLRefreshDrawnFooter`) draw, and two
    screenshots 0.5 s apart while refreshing differ; WaveSwipe, Fly, Material and Original were compared with a build of
    the parent commit `01e61b0` and look the same. Measured: core 47 Swift files (17,184 lines) and 34 Objective-C `.m`
    files (5,740 lines). Score by lines: 17,184 / (17,184 + 5,740) ≈ **75 / 100** (was 52).
  - 2026-11-19, step 9 (branch `feat/android-refresh-port-followup`; `5cfb0bd`, `415bcf8`, `c2172f1`, `22a2b1b`; leaves
    first): checked before each class with `git grep -P "@interface\s+\w+\s*:\s*<Class>(?!\w)"` across the repo
    (Examples, Tests, CrossPlatform). **Part A, the step 8 blocker resolved:** the Objective-C test helper
    `CYLStatusRecordingHeader : CYLRefreshBezierRadarHeader` (`Tests/CYLRefreshDrawnHeaderTests.m`) is Swift in
    `Tests/CYLRefreshTestHeaders.swift` (`@objc(CYLStatusRecordingHeader)`, public), added to `Tests/run-tests.rb`, which
    already compiles Swift into the test module `CYLTableViewPlaceHolder`; the Objective-C tests see it through the
    generated Swift header (via `CYLTableViewPlaceHolder.h`) and keep every assertion. **Subclasses found in Part B:**
    `Tests/CYLRefreshStylesAPITests.m` declared `CYLHookHeader` and `CYLAutoHookHeader : CYLRefreshNormalHeader`; both are
    Swift in the same file now (the hook overrides unchanged, `phaseDidChange` still without super). The other subclasses
    are already Swift (`CYLRefreshGifHeader` / `CYLRefreshAuto|BackGifFooter` in the core, translated first;
    `CYLRefreshExampleImagesHeader` / `...Footer` / `...BackFooter` in Example-Scenarios). Translated, with the same
    Objective-C API (class names, selectors, former Swift spellings, overridable hooks `open` + `@objc`; the inherited
    `+headerWithRefreshingBlock:` / `+footerWith...` factories still return the subclass because they call `[self new]`):
    - part A (`5cfb0bd`): `CYLRefreshDrawnHeader.swift` and `CYLRefreshBezierRadarHeader.swift` (the `NSInteger`
      truncations and the `1.9f` literal kept). The variadic `-inStatus:` cannot be `@objc`: it stays an Objective-C
      category (rule 6), `CYLRefreshDrawnHeader+CYLStatusList.h` / `CYLRefreshDrawnHeaderSupport.m` (35 lines); the
      umbrella header imports it last, after the generated Swift header that declares the class, and it declares itself
      only outside `__swift__` (so the umbrella still covers every public header: an import inside the `__swift__` guard
      gave an "umbrella header does not include" warning). Swift gets `isIn(statuses:)`. The driven mode that
      `CYLRefreshDrawnFooter` called by selector is internal and called directly.
    - part B1 (`415bcf8`): `CYLRefreshGifHeader`, `CYLRefreshAnimationHeader` (`CYLRefreshIconAnimating`:
      `iconView`, `usesIconView`, `setIconAnimation(attributes:|filePath:|bundled:...)`, `bundledIconAnimationFileNames`),
      `CYLRefreshNormalHeader` (`arrowView`, `iconSize`, `loadingView`, deprecated `activityIndicatorViewStyle`).
    - part B2 (`c2172f1`): the auto and back GIF, animation and normal footers (`noMoreDataImage`; the back footer's
      arrow and `iconSize`).
    - part B3 (`22a2b1b`): `CYLRefreshCupertinoHeader` / `CYLRefreshCupertinoFooter` (`activityIndicator`, a `let`
      created before `prepare` runs) and `CYLRefreshNormalTrailer`.
    The lazily created subviews (`arrowView`, `loadingView`, `animationView`) are computed properties over weak storage
    (the Objective-C ivars were `__unsafe_unretained`); setters with side effects are computed properties; `setState:`
    overrides keep `CYLRefreshCheckState`; the `-> Self` setters are `@discardableResult`. The spinner style (medium from
    iOS 13, else gray) is `UIActivityIndicatorView.Style.cyl_refreshDefault` (internal), gray spelled by raw value so no
    deprecation is reported. The headers keep doc-commented forward declarations. **Still Objective-C:** the state layer
    (`CYLRefreshStateHeader`, `CYLRefreshAutoStateFooter`, `CYLRefreshBackStateFooter`, `CYLRefreshStateTrailer`, step 10),
    `Base/` (steps 11, 12), the rule-6 shims and the tests (step 13). **Not kept identical, on purpose:** a driven drawn
    header's scroll hooks get the footer's scroll view instead of nil (no override reads it); the GIF names' untyped
    `setImages:` keep only the `UIImage` elements; a removed arrow / spinner / animation view is created again instead of
    dangling. Podspec (Core adds `Custom/Header`, `Custom/Footer/**`, `Custom/Cupertino`, `Custom/Trailer` Swift), the
    framework target, `Tests/run-tests.rb`, the cyl-api-map skill and the regenerated parity table are updated (the
    accessibility and animation runners glob). Tests: core 207/207 after each part, animation 13/13 (static, PAG),
    accessibility 4/4 (CI runner on CYL Placeholder Screens); Example-objc-02 UI tests 13/13 on the first full run (collection animation, paging, sections, localization; load average 50 to 96); Example-Scenarios,
    Example-SwiftUI, Example-objc-01 and the `CYLTableViewPlaceHolderFramework` target build and analyze (0 placeholder
    warnings, 0 CYLRefresh warnings, was 5). Simulator check (Example-Scenarios on CYL Placeholder Screens, held drags with axe): More → Refresh → Default (normal header: arrow turned up at "Release to refresh", spinner and "Loading...", "Last update: Today …", new rows after), Animated images (ring frames beside both texts), Springing-back footer 01 (arrow, "Release to load more", spinner), Springing-back footer 02 ("No more data"), Everything loaded (auto footer "No more data"), Cupertino style (indicator fades in with the pull and spins; footer spinner below the last row), Pull left (trailer arrow and the vertical "Release to see details"), BezierRadar (dots, wave, radar sweep); More → Feed → Refresh icons → `CYLRefreshActivity.gif` (playing icon beside "Loading..."); Simplified Chinese, Default ("松开立即刷新", "正在刷新数据中...", "最后更新：今天 …"). Measured: core 61 Swift files (19,426 lines)
    and 21 Objective-C `.m` files (4,023 lines). Score by lines: 19,426 / (19,426 + 4,023) ≈ **83 / 100** (was 75).
  - 2026-11-20, step 10 (branch `feat/android-refresh-port-followup`; `c4684c9`, `06aae63`, `1323018`; leaves first): the
    state layer is Swift. Checked before each class with `git grep -P "@interface\s+\w+\s*:\s*<Class>(?!\w)"` across the
    repo (Examples, Tests, CrossPlatform): **no Objective-C subclass** of any of the four; their subclasses were already
    Swift (normal / animation / GIF headers and footers, the drawn footers, `CYLRefreshNormalTrailer`). The only other
    Objective-C file under `CYLRefresh/Custom` is the rule-6 shim `CYLRefreshDrawnHeaderSupport.m` (variadic `-inStatus:`),
    which stays. Translated, with the same Objective-C API (class names, selectors, Swift spellings, overridable hooks
    `open` + `@objc`: `prepare`, `placeSubviews`, `state`, `i18nDidChange`, `refreshDidFinishWithSuccess:`,
    `flipsHorizontallyInOppositeLayoutDirectionViews`, `lastUpdatedTimeKey`; the inherited factories still return the
    class they are sent to; the `.h` files keep doc-commented forward declarations):
    - part 1 (`c4684c9`): `Custom/Header/CYLRefreshStateHeader.swift`: `stateLabel`, `lastUpdatedTimeLabel` (weak storage,
      created on first access, `UILabel!` as before), `lastUpdatedTimeText`, `labelLeftInset`, `setTitle:forState:`,
      `titleForState:`, `lastUpdatedTimeFormatter`, `lastUpdatedTimeString`, `titleTimeSpacing`, `succeededImage` /
      `failedImage` (the private result image view), `iconOnTrailingSide`, and the former `ChainingGrammar` category's
      `cyl_modifyLastUpdatedTimeText:` as an extension. The localized default titles and the locale-aware last-updated
      text (`CYLRefreshConfig.languageCode`, else the current locale; `jmm` / `MMddjmm` / `yyyyMMddjmm` templates) are
      unchanged. The `setState:` override keeps the order of its side effects (`CYLRefreshCheckState`, hide the result
      image, state text, the time again through the `lastUpdatedTimeKey` setter); `self.lastUpdatedTimeKey =
      self.lastUpdatedTimeKey` is a private `reapplyLastUpdatedTimeKey()` (Swift rejects a self-assignment).
      `+[UILabel cyl_label]` is imported by Swift as `UILabel.cyl_()` (its name minus the class name), so the Swift files
      call that spelling; the Objective-C declaration is not renamed (it shipped).
    - part 2 (`06aae63`): `Custom/Footer/Auto/CYLRefreshAutoStateFooter.swift` (`refreshingTitleHidden`, property name and
      setter `setRefreshingTitleHidden:` with the getter `isRefreshingTitleHidden`, Swift `isRefreshingTitleHidden`) and
      `Custom/Footer/Back/CYLRefreshBackStateFooter.swift`. The tap on the auto footer's idle text called the
      `CYLRefreshAutoFooter (TapTriggerFix)` category of `CYLRefreshAutoStateFooter.m`, which messaged `super`
      (`CYLRefreshFooter`'s `-beginRefreshing`, past the trigger-count check); Swift cannot call a grandparent's method,
      so it is now the private method `-cyl_beginRefreshingWithoutValidation` of `Base/CYLRefreshAutoFooter.m` (still
      Objective-C until step 11), reached by selector as `CYLRefreshDrawnFooter.swift` reaches `-happenOffsetY`.
    - part 3 (`1323018`): `Custom/Trailer/CYLRefreshStateTrailer.swift` (`cyl_placeStateLabelAtCenterX:`, Swift
      `cyl_placeStateLabel(centerX:)`, `@discardableResult`; the upright / rotated vertical text, the same regular
      expression through `NSString`, the flip inside flipped collection views, the empty flip list).
    **Not kept identical, on purpose:** `setTitle:forState:` takes a nullable title in Swift and in the generated header
    (nil is ignored, as the Objective-C code did; a nonnull Swift parameter would have turned an Objective-C nil into an
    empty title); `-[CYLRefreshBackStateFooter titleForState:]` is nullable like the other three (it could always return
    nil; Swift callers now get `String?` instead of an empty string); a non-date object stored under
    `lastUpdatedTimeKey` counts as no date (Objective-C passed it on); the labels are weak instead of
    `__unsafe_unretained`, so a removed label is created again instead of dangling. Podspec unchanged (the Core globs
    already cover `Custom/Header`, `Custom/Footer/**` and `Custom/Trailer`); the framework target (the four `.m`
    references now point at the `.swift` files), the cyl-api-map skill and the regenerated parity table are updated;
    the test, accessibility and animation runners glob. Tests: core 207/207 after each part, animation 13/13 (static,
    PAG), accessibility 4/4 (CI runner on CYL Placeholder Screens); Example-objc-02 UI tests 12/13 on the full run, the
    failure only `testDraggingDuringHeaderRefreshKeepsFirstItemPosition` (load average 66 to 86), which then passed 2 of 2
    reruns; Example-Scenarios, Example-objc-02, Example-SwiftUI, Example-objc-01, the root Example app and the
    `CYLTableViewPlaceHolderFramework` target build (0 CYLRefresh warnings); `check_doc_comments.py`,
    `check_localizations.py`, the iOS and Android API maps, the parity table, `check_package_licenses.py` and the docs
    navigation check pass. Simulator check (Example-Scenarios on CYL Placeholder Screens, English, held drags with axe):
    More → Refresh → Default ("Pull down to refresh" with the arrow down, "Release to refresh" with the arrow up, spinner
    and "Loading...", "Last update: Today 12:38 AM"), Hide the time (one centered line beside the arrow, then spinner and
    "Loading..."), Hide the state and time (icon only), No automatic loading ("Tap or pull up to load more"; a tap loads
    a row with "Loading..."), Hide the refreshing text (spinner only while loading), Everything loaded ("No more data"),
    Springing-back footer 01 ("Release to load more" with the arrow, then spinner and "Loading..."), Springing-back
    footer 02 ("No more data"), Pull left (rotated "Swipe to see details", then "Release to see details" with the arrow
    turned; release opens the details page), Refresh text languages in Simplified Chinese ("松开立即刷新",
    "正在刷新数据中...", "最后更新：今天 00:45") and Russian ("Отпустите чтобы обновить", "Загрузка...",
    "Последнее обновление: Сегодня 00:49", 24-hour time in both). Measured: core 65 Swift files (20,348 lines) and 17
    Objective-C `.m` files (3,376 lines). Score by lines: 20,348 / (20,348 + 3,376) ≈ **86 / 100** (was 83).
  - 2026-11-20, step 11 (branch `feat/android-refresh-port-followup`; `9b2f455`, `843fb8a`, `0c5a18c`, `5bbcfa5`,
    `35c694d`; leaves first): the subclassing bases in `Base/` are Swift. Checked before each class with
    `git grep -P "@interface \w+ : <Class>\b"` across the repo (Examples, Tests, CrossPlatform): **no Objective-C
    subclass** of any of the five; their subclasses were already Swift (the state layer, Cupertino, the drawn header and
    footers, Ball Pulse, the Example-Scenarios DIY controls), so no test helper had to move. Translated, with the same
    Objective-C API (class names, selectors, Swift spellings, overridable members `open`; the overrides of
    `CYLRefreshComponent`, still Objective-C, keep its selectors and the super-call order; the `.h` files keep
    doc-commented forward declarations; Objective-C callers get the classes from the generated Swift header through the
    umbrella header):
    - part 1 (`9b2f455`): `Base/CYLRefreshHeader.swift`. `+headerWithRefreshingBlock:` /
      `+headerWithRefreshingTarget:refreshingAction:` are class methods hidden from Swift (`@available(swift, obsoleted:
      1)`, returning `Self`, so a subclass gets its own type), and Swift keeps the initializers `init(refreshingBlock:)` /
      `init(refreshingTarget:refreshingAction:)` it imported before (convenience initializers, inherited by the Swift
      subclasses); `secondaryOpen` keeps its `isSecondaryOpen` getter. Kept: issue #1628 (an inset written by someone
      else during a refresh becomes the new baseline, a list at rest scrolls back to show the header), #1483 (a footer's
      side-inset write is not a new top; the start of a refresh measures from the original top), PR #1444 (rotation:
      the original top is rebuilt from the header's own delta), the first-item position across repeated refreshes,
      `ignoredScrollViewContentInsetTop`, `lastUpdatedTimeKey` (its setter still runs from `prepare` and from
      `lastUpdatedTime`, so the state header redraws the time), the end-of-refresh animation (`slowAnimationDuration`,
      `reboundAnimationOptions`) and the bounds animations of `isCollectionViewAnimationBug` (their delegate is a private
      object that holds the header strongly, as the animation held the header when it was its own delegate).
      `UIScrollView+CYLExtensionSupport.m` now hands Swift, from `+load`, the reader of the side-inset depth (replacing
      the C function `CYLRefreshIsWritingSideInset()`, which only `CYLRefreshHeader.m` called) and an `@try` / `@finally`
      guard, so `updatingRefreshInset` is reset when a `contentInset` observer throws (Swift cannot catch an Objective-C
      exception).
    - part 2 (`843fb8a`): `Base/CYLRefreshBackFooter.swift`: the bottom inset while loading, the paging restore
      (MJRefresh #1430), `noMoreDataDisplayDuration` / `followsContentWhenNoMoreData` (#1585, the hold token, the weak
      delayed restore), `scrollsContentAfterLoading`, the trigger mode and the second floor. The private `-happenOffsetY`
      is the internal `happenOffsetY`, read directly by `CYLRefreshDrawnFooter.swift` (no selector any more).
    - part 3 (`0c5a18c`): `Base/CYLRefreshAutoFooter.swift`: `isAutomaticallyRefresh`,
      `triggerAutomaticallyRefreshPercent`, `autoTriggerTimes` (once per drag), `loadsWhenContentNotFull`,
      `loadsAfterNoMoreData`, the inset kept by `setHidden:` and the page alignment after a load (#1610). The private
      `-cyl_beginRefreshingWithoutValidation` of step 10 is the internal `cyl_beginRefreshingWithoutValidation()`
      (`super.beginRefreshing()`, past the trigger-count check), called directly by `CYLRefreshAutoStateFooter`.
    - part 4 (`5bbcfa5`): `Base/CYLRefreshTrailer.swift`: the horizontal pull, the right inset and its refresh
      generation, the automatic trailer once per drag (#1623), the end of a refresh and the bounce settings given back
      when it leaves its scroll view; the factories as for the header.
    - part 5 (`35c694d`): `Base/CYLRefreshFooter.swift`: the factories, `endRefreshingWithNoMoreData` /
      `resetNoMoreData` (main-queue hop without retaining the footer), the deprecated `noticeNoMoreData` and
      `automaticallyHidden`, `isNoMoreData`, `loadsAfterNoMoreData`, `ignoredScrollViewContentInsetBottom`, the auto-hide
      below the bottom bars, and the `CYLRefreshNoMoreDataImage` methods as a Swift extension.
    The leak fixes of `bce488f` are untouched (they live in `UIScrollView+CYLRefresh.swift`, the drawn styles and the
    value animator); the delayed work in the new files holds the controls weakly as before (the no-more-data hold, the
    main-queue hops). **The private members of the Objective-C `CYLRefreshComponent` the Swift classes still reach**, by
    selector in the internal `Base/CYLRefreshComponentPrivateAccess.swift` (a header Swift can read would be public; the
    file goes in step 12): `-cyl_reportPhase` (header and back footer, second floor), `-cyl_offsetForDragRate:happenOffset:`
    (header and back footer, `dragRate`) and the new `-cyl_setScrollViewOriginalInset:` (header, back footer, trailer),
    which writes the protected ivar `_scrollViewOriginalInset` (Swift cannot reach ivars; `_scrollView` is read through
    the public `scrollView`). `CYLRefreshComponent.m` also still uses the five classes (`attach:`, `-cyl_pullsUp`,
    `beginRefreshingWithDuration:...`) through the generated Swift header. **Still Objective-C:** `CYLRefreshComponent`
    (step 12), the rule-6 shims and the tests (step 13). **Not kept identical, on purpose:** the two exported string
    globals `CYLRefreshHeaderRefreshing2IdleBoundsKey` / `CYLRefreshHeaderRefreshingBoundsKey` (never in a header) and
    the C function `CYLRefreshIsWritingSideInset()` (never in a header) are gone (private Swift constants and the reader
    block); the header no longer conforms to `CAAnimationDelegate` itself; `lastUpdatedTime` returns nil for a non-date
    object stored under the key (as step 10's time label does); `secondaryShouldOpenBlock` takes `CYLRefreshHeader`
    instead of `__kindof CYLRefreshHeader` in the generated header (a block typed with the base class, as the tests
    write it, still fits); a KVO change whose value is not an `NSValue` counts as zero (Objective-C raised); the dead
    iOS 10 branch of `resetInset` (no reset without a window) is dropped (the library needs iOS 12); the private
    Objective-C selectors of the five classes (`happenOffsetY`, `heightForContentBreakView`, `happenOffsetX`,
    `cyl_dragStartedAtEdge`, ...) are no longer in the runtime. Podspec unchanged (the Core already globs
    `CYLRefresh/Base/*.swift`); the framework target (the five `.m` references now point at the `.swift` files, plus the
    access file), the cyl-api-map skill, `CYLRefresh/instructions.md` and the regenerated parity table are updated; the
    test, accessibility and animation runners glob. Tests: core 207/207 after each part, animation 13/13 (static, PAG),
    accessibility 4/4 (CI runner on CYL Placeholder Screens); Example-objc-02 UI tests 12/13 on the full run (load
    average up to 92), the failure only `testDraggingDuringHeaderRefreshKeepsFirstItemPosition` ("the drags happen
    during the refresh"), which then passed 2 of 2 reruns; Example-SwiftUI UI tests 4/4 on CYL Placeholder Audit iOS26
    (#1628, the real pull included); Example-Scenarios, Example-objc-02, Example-SwiftUI, Example-objc-01, the root
    Example app and the `CYLTableViewPlaceHolderFramework` target build (0 CYLRefresh warnings);
    `check_doc_comments.py`, `check_localizations.py`, the iOS and Android API maps, the parity table,
    `check_package_licenses.py` and the docs navigation check pass. Simulator check (Example-Scenarios on CYL Placeholder
    Screens, English, held drags with axe): More → Refresh → Default (arrow down with "Pull down to refresh", arrow up
    with "Release to refresh", spinner and "Loading...", new rows after, "Last update: Today 1:35 AM"), the pull-up
    Default ("Tap or pull up to load more"; a pull-up release and a tap each load a row with "Loading..."), Everything
    loaded ("No more data"), Springing-back footer 01 ("Release to load more", spinner and "Loading...", a new row and
    the rebound), Springing-back footer 02 ("No more data"), Pull left (vertical "Release to see details"; release opens
    the details page), Paging (pull up loads page 2, Test data 11 to 20), BezierRadar (drawn header: dots, wave, radar
    sweep, retract) and BezierRadar footer (drawn footer: dots, then the radar while loading); More → Feed (pull to
    refresh with "Loading..." and the time, the failing refresh shows the error placeholder as designed, the next one
    the posts; scrolling loads more up to Post 30 and "No more data"). Measured: core 71 Swift files (22,892 lines) and
    12 Objective-C `.m` files (1,520 lines; `CYLRefreshComponent.m` 1,070 of them). Score by lines: 22,892 /
    (22,892 + 1,520) ≈ **94 / 100** (was 86).
  - 2026-11-20, step 12 (branch `feat/android-refresh-port-followup`; `6944b32`, `5c0c159`): the root class
    `CYLRefreshComponent` is Swift. Checked first with `git grep -P "@interface \w+ : CYLRefreshComponent\b"` across the
    repo (Examples, Tests, CrossPlatform): **no Objective-C subclass** (all of them became Swift in steps 8 to 11), so no
    test helper had to move. Translated, with the same Objective-C API:
    - part 1 (`6944b32`): `Base/CYLRefreshComponent.m` (1,070 lines) is `Base/CYLRefreshComponent.swift`: class name,
      every selector (the `is…` getters of `refreshing`, `exclusiveWithOtherRefresh`, `autoChangeAlpha`,
      `automaticallyChangeAlpha`, `attached`, `expanded`, `refreshEnabled`, `autoRefresh` kept with `@objc(name)` on the
      property and `@objc(isName)` on the getter), the Swift spellings Swift imported from the header (including the
      odd imported ones kept for source compatibility: `UILabel.cyl_()`, `cyl_(afterBeginningAction:)`,
      `cyl_(afterEndingAction:)`), the overridable hooks `open` with the same selectors, `+attach:` returning `Self`
      (`self.init()`), and the former categories `CYLRefreshIconLayout`, `CYLRefreshStateTitles`, `ChainingGrammar`
      and `UILabel (CYLRefresh)` as Swift extensions. **KVO:** `addObserver(_:forKeyPath:options:context:)` with a
      private static context for `contentOffset`, `contentSize`, `contentInset` and the pan gesture's `state`;
      `observeValue` hands other contexts to super and gives the hooks the change dictionary with the same string keys
      (`"new"`, `"old"`); the observed scroll view (weak) and pan gesture (strong) are cleared after removal, so nothing
      is removed twice; `removeObservers` runs on `willMove(toSuperview:)` as before and the KVO part again in
      `deinit`; `addObservers` called twice does not register twice. The setters with side effects (`state`,
      `pullingPercent`, `automaticallyChangeAlpha`, `triggerRate`, `autoHideRefresh`, `disablesContentWhileRefreshing`,
      `colorAccent`, `colorPrimary`) are computed properties over private storage, written by the initializer in the
      Objective-C order (`prepare`, then `state = idle` with the first phase report from 0, then the durations,
      `triggerRate` 1, `refreshEnabled` YES); `state` and `pullingPercent` are `@objc dynamic`, so key-value observers
      of them still see every change, also the ones Swift subclasses make. The delayed and off-main-thread work holds
      the control weakly as before (the async `setNeedsLayout`, `-endRefreshingWithSuccess:` off the main thread, the
      finishing hold, `beginRefreshingAfterDelay:` / `endRefreshingAfterDelay:success:`, the overshoot of
      `beginRefreshingWithDuration:overOffset:force:`, `didMoveToWindow`'s start), so the 2026-11-19 teardown fixes
      hold (`testControllerTeardownWhileRefreshingReleasesWithoutObserverExceptions` and the table-driven teardown
      tests pass). **Rule 6:** the enums (`CYLRefreshState`, `CYLRefreshScrollMode`, `CYLRefreshTriggerMode`,
      `CYLRefreshPhase`) and block typedefs stay in `CYLRefreshComponent.h` (with a doc-commented forward declaration
      and the `UILabel (CYLRefresh)` declarations for Objective-C only, `#ifndef __swift__`); the variadic
      `-isInPhases:` cannot be `@objc`, so it is the Objective-C category `CYLRefreshComponent+CYLPhaseList.h` /
      `CYLRefreshComponentSupport.m` (34 lines), imported by the umbrella header after the generated Swift header, as
      step 9 did for `-inStatus:`. The `CYLRefreshIconLayout` declarations left `CYLRefreshIconView.h` (Objective-C
      gets them from the generated header). **Selector access removed:** `Base/CYLRefreshComponentPrivateAccess.swift`
      and the start header's selector helpers in `UIScrollView+CYLRefresh.swift` are deleted; `git grep -n
      "NSSelectorFromString\|#selector(" CYLTableViewPlaceHolder/CYLRefresh` now lists only target-action and display
      link selectors and the `NSScanner` calls of the vector parser.
    - part 2 (`5c0c159`): the internal members drop their selector-era names: `reportPhaseChange()`,
      `offset(forDragRate:happenOffset:)`, `hasCallbacks`, `copyTargetActions(from:)`; `-cyl_setScrollViewOriginalInset:`
      is removed, the header, back footer and trailer set `scrollViewOriginalInset` (settable inside the module,
      read-only outside).
    **Not kept identical, on purpose:** target-actions of `-addTarget:action:` are held weakly (the Objective-C code
    kept an unretained pointer and messaged a released target); `addTarget:action:` / `removeTarget:action:`,
    `addPhaseObserver:` / `addScrollObserver:` and `removePhaseObserver:` / `removeScrollObserver:` take nullable
    arguments (Objective-C passed nil and the code checked it; Swift callers are unaffected); the Swift `async` variants
    `beginRefreshing() async` / `endRefreshing() async` that Swift derived from the completion-block methods are gone
    (nothing used them; the stored completion block runs on every refresh, so they could resume twice); the deprecated
    `endRefreshingAnimateCompletionBlock` getter returns `endRefreshingAnimationBeginAction` (it returned an ivar that
    was never written, always nil); the block parameters of `canTriggerBlock`, `addPhaseObserver:` and
    `addScrollObserver:` are `CYLRefreshComponent *` instead of `__kindof CYLRefreshComponent *` in the generated header
    (`refreshingHandler` keeps the `CYLRefreshComponentHandler` typedef); `scrollView` is a read-only computed property
    (the generated header prints it `strong`, the storage is weak); `NS_REQUIRES_SUPER` is gone with the Objective-C
    declarations; the private Objective-C selectors (`-cyl_reportPhase`, `-cyl_hasCallbacks`, ...) are no longer in
    the runtime. Framework target (the `.m` reference points at the `.swift` file, the access file's at
    `CYLRefreshComponentSupport.m`, plus the public `+CYLPhaseList.h`), podspec comment, cyl-api-map skill and the
    regenerated parity table (its `CYLRefreshComponent` descriptions now come from the Android KDoc, as for the earlier
    steps' classes) are updated; the test, accessibility and animation runners glob the folder. Tests: core 207/207
    after each part and 207/207 twice more at the end; animation 13/13 (static, PAG); accessibility 4/4 (CI runner on CYL Placeholder
    Screens); Example-objc-02 UI tests 13/13 on the first full run (collection animation, paging, sections,
    localization); Example-SwiftUI UI tests 4/4 on CYL Placeholder Audit iOS26; Example-Scenarios, Example-objc-01, the
    root Example app and the `CYLTableViewPlaceHolderFramework` target build, and a simulator archive of the framework
    with `BUILD_LIBRARY_FOR_DISTRIBUTION=YES` packs into an XCFramework (the device slice and `scripts/pod-lint.sh
    xcframework` were skipped: they need CYLTabBarController's device slices, not built locally);
    `check_doc_comments.py`, `check_localizations.py`, the iOS and Android API maps, the parity table,
    `check_package_licenses.py` and the docs navigation check pass. Simulator check (Example-Scenarios on CYL Placeholder
    Screens, English, held drags with axe): Scenarios list scrolls; More → Refresh → Default (arrow with "Pull down to
    refresh", spinner and "Loading...", new rows after), the pull-up Default ("Tap or pull up to load more"; a tap and a
    pull-up each load a row with "Loading..."), Springing-back footer 01 ("Release to load more" with the arrow, then
    "Loading..."), Pull left (rotated "Swipe to see details"; a fast swipe past the end opens the details page),
    DropBox (drawn header) and Delivery footer (drawn footer), Rive · Bow and SVGA · Bubbles, SVGA refresh icon (the
    icon beside "Loading..."), each animating (two frames 0.6 s apart differ); More → Feed (refresh with "Loading..."
    and the time, the failing refresh shows the error placeholder as designed, scrolling loads up to Post 30 and "No
    more data"); Flows → Refresh controls (pull to refresh on the empty list, then 12 items and "No more data").
    **Remaining `.m` files under `CYLTableViewPlaceHolder/` (12 files, 484 lines), each a rule-6 shim Swift cannot
    express:** `CYLPlaceholderHUD/CYLPlaceholderHUDSupport.m` (24; six exported notification names and a userInfo key,
    `FOUNDATION_EXPORT` constants); `CYLRefresh/Base/CYLRefreshComponentSupport.m` (34; the variadic `-isInPhases:`);
    `CYLRefresh/CYLRefreshConst.m` (44; exported `CGFloat` and string constants of `CYLRefreshConst.h`);
    `CYLRefresh/Custom/Drawn/CYLRefreshDrawnHeaderSupport.m` (31; the variadic `-inStatus:`);
    `CYLRefresh/UICollectionViewLayout+CYLRefreshSupport.m` (32; `+load`, which Swift has none of);
    `CYLRefresh/UIScrollView+CYLExtensionSupport.m` (61; `+load` and the `@try` / `@finally` guards Swift cannot
    write); `CYLTableViewPlaceHolder/CYLPlaceholderLocalizationSupport.m` (47; an exported notification name and the
    C functions `CYLPlaceholderResourceBundle`, `CYLPlaceholderResourceURLForPath`, `CYLPlaceholderLocalizedStringForKey`
    behind the lookup macros); `CYLPlaceholderNetworkMonitorSupport.m` (16; an exported notification name);
    `CYLPlaceholderScenarioSupport.m` (21; the six `CYLPlaceholderAction` constants); `CYLPlaceholderStatusViewSupport.m`
    (17; the two exported height constants); `CYLPlaceholderViewSupport.m` (115; the exported `CYLPlaceholderItem*`
    keys and the other constants of `CYLPlaceholderView.h`); `UIScrollView+CYLPlaceholderSupport.m` (42; `+load` and
    the `@try` / `@finally` guard of batch updates). Measured: core 71 Swift files (24,655 lines) and 12 Objective-C
    `.m` files (484 lines). **Score by lines:** 24,655 / (24,655 + 484) ≈ **98 / 100** (was 94). **Score by rule 6:**
    every remaining `.m` is a Swift-compatible shim of something Swift cannot declare (exported C constants and
    functions, `+load`, Objective-C exception guards, variadic methods), and every class is Swift, so the core counts
    as **100 / 100 by rule 6**; the tests (14 Objective-C files under `Tests/`) are excluded until step 13.
  - 2026-11-20, step 13 (branch `feat/android-refresh-port-followup`), **done**: the tests.
    **Decision (the owner, 2026-11-20):** asked as a choice for the 14 Objective-C test files, answered "Swift tests +
    small ObjC smoke test": every test file under `Tests/` becomes Swift with the same assertions and the same test
    method names (`- (void)testX` is `func testX()`), and one small Objective-C file,
    `Tests/CYLObjectiveCAPISmokeTests.m`, calls the public Objective-C API surface so CI still proves that Objective-C
    callers compile and work. The smoke file counts as a rule-6 shim; the rule is also in `Tests/instructions.md`.
    - **Runners:** `590c28c` the core runner compiles every `Tests/*.swift` and `Tests/*.m` (except the animation and
      accessibility tests) into the library's own module, so the Swift tests reach internal members without
      `@testable` or selectors; `f8db9ef` the animation runner compiles its three Swift tests, which import the
      `CYLTableViewPlaceHolder` and `CYLAnimatedItem` modules (static and dynamic frameworks; its Swift runtime file
      and the PAGEnterprise `-fno-modules` case are gone); `f806e71` the accessibility runner compiles the Swift UI
      tests and the Swift host app. CI (`.github/workflows/ios.yml`, `ios12-runtime.yml`) and the scripts call the
      runners only, so nothing else named the test files.
    - **Files and commits** (one commit per file, or per runner group; the core runner passed after each group):
      `f8db9ef` `CYLPlaceholderLottiePlaybackTests`, `CYLPlaceholderBackendPlaybackTests`,
      `CYLPlaceholderAnimationRegistryTests`; `f806e71` `CYLPlaceholderAccessibilityUITests` and
      `Tests/AccessibilityHost/main.m` (now `CYLAccessibilityHostApp.swift`, `@main`); `1fffed0` `PlaceholderTests`;
      `4e1fbd3` `CYLAutomaticPlaceholderTests`; `c143884` `CYLRefreshConsolidationTests`; `deb446f`
      `CYLRefreshStylesAPITests` (with the polling of `7ca7a56`, which another session pushed to the Objective-C file
      meanwhile, carried over); `f43c3cd` `CYLRefreshIconTests`; `808c1f3` `CYLRefreshDrawnHeaderTests` (the comments of
      `CYLRefreshTestHeaders.swift` updated); `2b349c2` `CYLAndroidParityTests`; `6885eca` `CYLPlaceholderHUDTests`;
      `efb1439` `CYLPlaceholderStatusViewTests`; `b58a6c0` `CYLPlaceholderScenarioTests`; `4d19388` the smoke test.
    - **Smoke test** (`4d19388`, 4 tests, 274 lines): `CYLPlaceholderView` (`initWithItemAttributes:imageBundle:error:`,
      `initWithImage:text:`, `initWithStyle:text:`, `+imageForStyle:`, `+pathForBundledAnimation:`, a bad attribute
      returning the item-attributes error), `CYLPlaceholderStackView` (`initWithScenario:actions:` with an action block,
      `initWithComponents:actions:`, `initWithConfiguration:actions:error:`, `initWithContentsOfURL:actions:error:`),
      every `CYLPlaceholderComponent` factory, `CYLPlaceholderScenarioCatalog`, `CYLPlaceholderStatusView` (both
      initializers, the height constants), `CYLPlaceholderHUD` (`initWithContainerView:`, show and dismiss, the class
      methods, the notification names and userInfo key), `CYLPlaceholderLocalization` with the lookup macros and C
      functions, `CYLPlaceholderNetworkMonitor`, `UITableView` `cyl_placeholderViewBlock:` and `cyl_reloadData`,
      `UICollectionView` `cyl_placeholderViewBlock:`, `UIViewController` `cyl_statusDisplay` and
      `cyl_applyStatusConfiguration:error:`, the `CYLPlaceholderAction` constants; every concrete CYLRefresh header,
      footer and trailer through `headerWith…` / `footerWith…` / `trailerWith…` (block and target-action, drawn styles,
      the MJRefresh-named `CYLRefreshGifHeader`, `CYLRefreshAutoGifFooter`, `CYLRefreshBackGifFooter`),
      `setTitle:forState:`, `setIconAnimationFilePath:size:forState:` (`CYLRefreshIconAnimating`), `setImages:forState:`,
      `beginRefreshingWithCompletionBlock:` / `endRefreshingWithCompletionBlock:` on a table in a window, the variadic
      `-isInPhases:` and `-inStatus:`, `CYLRefreshConfig.defaultConfig`, the `CYLRefresh` constants and
      `+[NSBundle cyl_localizedStringForKey:value:]`. It also holds the checks only Objective-C can make: the
      `NSDictionary` entry points (`-[CYLPlaceholderStatusView initWithConfiguration:error:]`,
      `-[CYLPlaceholderStackView initWithConfiguration:actions:error:]`, `-cyl_applyStatusConfiguration:error:`,
      `+componentWithDictionary:error:`) given an `NSArray` or `NSString` return the configuration error (domain, code,
      message), and a refresh control moving between views raises no Objective-C exception (`XCTAssertNoThrow`).
    - **Tests:** core 207 before, 211 after (207 + the 4 smoke tests), 0 failures; animation 13 / 13 before and after,
      with static PAG, dynamic PAG and static PAGEnterprise; accessibility 4 / 4 before and after (the CI runner on CYL
      Placeholder Screens). **Test names:** the 224 `- (void)test…` names of the 14 Objective-C files (class plus
      method) diffed against the 224 `func test…` names of the Swift files: identical.
    - **Not kept identical, on purpose:** checks wrapped in `XCTAssertNoThrow` in Swift tests are plain calls (Swift
      cannot catch an Objective-C exception; an exception still fails the run, and the smoke file keeps the
      `XCTAssertNoThrow` form); the variadic calls are `isIn(phases:)` / `isIn(statuses:)` in Swift (the smoke file keeps
      the variadic form); the PAG view is read by class name and key-value coding instead of libpag's header (the
      PAGEnterprise umbrella header cannot be imported as a module); the `NSDictionary` entry points and
      `-cyl_setStatus:constrained:expensive:` (private in Swift) are reached by selector in the Swift tests; a few values
      read by key-value coding are internal members now; failure messages print Swift type names; some optional results
      are unwrapped with `XCTUnwrap`, which is stricter. No core bug was found.
    - Repo checks pass: `check_doc_comments.py`, `check_localizations.py`, `ios-api-map.py --check`,
      `android-api-map.py --check`, `ios-android-parity.py --check`, `check_package_licenses.py`, the docs navigation
      check; Example-Scenarios builds. Not checked locally: the iOS 12 deployment-target job
      (`ios12-runtime.yml`, Xcode 16), which this Mac (Xcode 27 only) cannot run; the Swift tests guard iOS 13+ API with
      `#available` as the Objective-C tests did.
    - **Remaining `.m` files:** the 12 rule-6 shims of the core listed in step 12 (484 lines) and
      `Tests/CYLObjectiveCAPISmokeTests.m` (274 lines). Measured: 87 Swift files (24,655 lines in the core, 7,610 in
      `Tests/`) and 13 `.m` files (758 lines). **Score by lines:** 32,265 / (32,265 + 758) ≈ **98 / 100**. **Score by
      rule 6: 100 / 100**: every class and test is Swift, and every remaining `.m` is a shim Swift cannot express
      (exported C constants and functions, `+load`, Objective-C exception guards, variadic methods) or the agreed
      Objective-C smoke test. The task is done.
  - Next, bottom-up and one commit per file group, each with the core (207) and animation (13) tests, the
    example builds and a simulator check (plan of 2026-11-19, `CYLRefresh/` measured at 14,000 Objective-C lines):
    - step 6: the `CYLRefresh/` root (configuration, categories; 7 files, 801 lines) — done (`804b73d`).
  - **Decision (the owner, 2026-11-19): convert the whole CYLRefresh class tree to Swift**, asked as "Keep them
    Objective-C / Convert all to Swift / Convert, keep ObjC bases" and answered "Convert all to Swift". Objective-C
    cannot subclass a Swift class, so after the migration an app can no longer subclass `CYLRefreshComponent`,
    `CYLRefreshHeader`, the footers, the trailer or any style in Objective-C: **a breaking change for the published
    library**. The release that ships it is a major version, and its notes carry the migration: write the subclass in
    Swift (the Objective-C API names and selectors stay, so the overridden methods are the same), or compose (add a view
    to the control instead of subclassing). The Swift API and every Objective-C caller that only uses the controls stay
    source-compatible.
  - **Breaking, same major version (the owner, 2026-11-20: "raise iOS .spec the minimum to iOS 15"):** the minimum
    deployment target is iOS 15.0 (was 12.0); apps on iOS 12-14 stay on the previous release. The iOS 13/14 availability
    branches were removed; see `CHANGELOG.md`. No release is tagged by this change.
  - **Order: leaves first.** A Swift class may subclass an Objective-C class, not the reverse, so each class is
    translated only after all its subclasses (plan of 2026-11-19, replacing the bottom-up plan above):
    - step 7: `Custom/Drawn/Support` and the internal helpers with no subclasses (`CYLRefreshPaging`,
      `CYLRefreshIconView`, the vector, StoreHouse, value-animator, fly/mountain views and the SpriteKit game scenes) — done, except `CYLRefreshGamePlayingScene` (subclassed by the two games; step 8);
    - step 8: the whole `Custom/Drawn` tree (the styles, `CYLRefreshGameHeader` after its two games, then
      `CYLRefreshDrawnHeader` and `CYLRefreshDrawnFooter`) — done, except `CYLRefreshDrawnHeader` and `CYLRefreshBezierRadarHeader` (an Objective-C
      test subclassed BezierRadar; done in step 9 after the test helper moved to Swift);
    - step 9: the remaining concrete controls: Normal / Animation (Gif) headers, the auto and back Normal / Animation
      (Gif) footers, Ball Pulse, Cupertino header and footer, `CYLRefreshNormalTrailer` — done, with `CYLRefreshDrawnHeader`
      and `CYLRefreshBezierRadarHeader` (their test subclass moved to Swift);
    - step 10: the state layer: `CYLRefreshStateHeader`, `CYLRefreshAutoStateFooter`, `CYLRefreshBackStateFooter`,
      `CYLRefreshStateTrailer` — done;
    - step 11: `CYLRefreshHeader`, `CYLRefreshAutoFooter`, `CYLRefreshBackFooter`, `CYLRefreshTrailer`, then
      `CYLRefreshFooter` — done;
    - step 12: `CYLRefreshComponent` (the root) — done;
    - step 13: the tests (14 Objective-C files under `Tests/`) — done.

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

## Migration note: three `CYLPlaceholderView` properties moved to the engine (2026-11-25, `999049e7`)

| 中文 | English |
| --- | --- |
| `CYLPlaceholderView` 自己声明的 `onResourceMissing`、`showsImageWhenAnimationEnds`、`isShowingImageAfterAnimationEnd` 已删除，改用引擎 `CYLAnimatedItemView`（CYLTabBarController `d0aadcd7`）的同名属性。引擎把它们声明为不带 `@objc` 的 Swift 属性，所以从 Objective-C 看不到。检查结果：本仓库没有 Objective-C 调用者（`Tests/CYLObjectiveCAPISmokeTests.m`、`Examples/Example-objc-01`、`Examples/Example-objc-02`、`CrossPlatform/` 的 iOS 宿主都不使用），`scripts/ios-public-api.json` 与 `docs/iOS-API-Map.md` 也没有列出它们（`isShowingImageAfterAnimationEnd` 一直只是 `private(set)` 的内部属性，从未公开），所以不添加不同名称的 Objective-C 转发。按照“示例权重最低”规则，不为示例增加额外的 `@objc` 名称。 | `CYLPlaceholderView` no longer declares its own `onResourceMissing`, `showsImageWhenAnimationEnds` and `isShowingImageAfterAnimationEnd`; it uses the properties of the same names on the engine's `CYLAnimatedItemView` (CYLTabBarController `d0aadcd7`). The engine declares them as Swift properties without `@objc`, so Objective-C does not see them. Checked: this repository has no Objective-C caller (neither `Tests/CYLObjectiveCAPISmokeTests.m`, `Examples/Example-objc-01`, `Examples/Example-objc-02` nor the iOS hosts under `CrossPlatform/` use them), and neither `scripts/ios-public-api.json` nor `docs/iOS-API-Map.md` lists them (`isShowingImageAfterAnimationEnd` was only ever an internal `private(set)` property, never public), so no Objective-C forwarder with a different name is added, and under the rule "examples have the lowest weight" no extra `@objc` name is added for an example. |
| **Swift 替代**：`view.onResourceMissing = { resource, reason in … }`、`view.showsImageWhenAnimationEnds = true`、`view.isShowingImageAfterAnimationEnd`（只读）。仍有 `@objc` 的：`CYLPlaceholderComponent.showsImageWhenAnimationEnds`（组件，由 `CYLPlaceholderStackView` 转发给视图）与 `CYLPlaceholderResourceReporter.onResourceMissing`。需要从 Objective-C 读取视图上的这三项的应用，应在自己的 Swift 文件中用 `@objc` 包装并向 `CYLAnimatedItemView` 提出声明 `@objc` 的请求。 | **Swift replacement**: `view.onResourceMissing = { resource, reason in … }`, `view.showsImageWhenAnimationEnds = true`, `view.isShowingImageAfterAnimationEnd` (read-only). Still `@objc`: `CYLPlaceholderComponent.showsImageWhenAnimationEnds` (the component; `CYLPlaceholderStackView` passes it on to the view) and `CYLPlaceholderResourceReporter.onResourceMissing`. An app that needs these three on the view from Objective-C wraps them with `@objc` in its own Swift file (and may ask for `@objc` on `CYLAnimatedItemView`'s declarations). |
