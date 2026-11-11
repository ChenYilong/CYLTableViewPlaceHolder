---
name: cyl-api-map
description: Map the placeholder and refresh APIs to their headers, example, tests, and documentation.
---

# API map

Inspect the headers and implementation before changing behavior. Code is the
source of truth; update the README and issue tracker if they become stale.

Core features reuse `CYLPlaceholderView` (the packaged icon and title) for every icon and text instead of custom
views; every element inside a `CYLPlaceholderStackView` is a `CYLPlaceholderView` (`instructions.md`, "Reuse
CYLPlaceholderView in the core").

| Area | Source |
| --- | --- |
| Public umbrella | `CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h` |
| Placeholder reload | `CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/UITableView+CYLTableViewPlaceHolder.h` |
| Automatic table and collection placeholders | `CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/UITableView+CYLPlaceholder.h`, `CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/UICollectionView+CYLPlaceholder.h`, `CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/UIScrollView+CYLPlaceholder.m` |
| Default placeholder and localized resources | `CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderView.h`, `CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.bundle` |
| Placeholder style and message selection | `CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderView.h` (`CYLPlaceholderStyle`, `CYLPlaceholderMessage`, custom image/text initializers) |
| FlatDesign-style item configuration | `CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderView.h` (`initWithItemAttributes:imageBundle:error:` and `initWithItemContentsOfURL:imageBundle:error:`); local GIF and optional Lottie/PAG/Rive adapters, with limitations documented in the README and FlatDesign comparison |
| Placeholder badge and selection indicator | `CYLPlaceholderView.h` (`showBadgeWithStyle:value:`, `badgeValue`, `badgeLabel`, `selectionIndicatorImage`) |
| Custom placeholder animation | `CYLPlaceholderView.h` (`CYLPlaceholderAnimationPlayer`, `registerAnimationFactory:forFileExtension:`) |
| Placeholder appearance layers | `CYLPlaceholderView.h` (`default…` `UI_APPEARANCE_SELECTOR` properties, `CYLPlaceholderBadgeAppearance`); precedence in `-cyl_applyAppearance` |
| Animation module (mirrors CYLTabBarController `CYLTabBarItemAnimation`) | `CYLTableViewPlaceHolder/CYLPlaceholderAnimation/` (`CYLPlaceholderItemAnimator`, `…AnimatorRegistry`, `…AnimationFactory`, `…AnimationPlayer`, `…AnimationPlayableView`, `…ViewAnimator`, `…AnimationEngine`, host `CYLPlaceholderAnimationView`); Core seam `CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderItemAnimationService.h` (private) |
| Engine adapters | `CYLPlaceholderAnimation/{GIF,Lottie,PAG,Rive}/`, Swift bridges `CYLTableViewPlaceHolder/LottieSwift/`, `CYLTableViewPlaceHolder/RiveSwift/`; subspecs in `CYLTableViewPlaceHolder.podspec` |
| Animation integration tests | `Tests/run-animation-tests.rb`, `Tests/CYLPlaceholderAnimationRegistryTests.m`, `Tests/CYLPlaceholder{Lottie,Backend}PlaybackTests.m` |
| FlatDesign parity tracker | `docs/flatdesign-item-comparison.md` |
| Scenario placeholders (component stack, scenario enum, actions) | `CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderStackView.h`, `CYLPlaceholderScenario.h` (`CYLPlaceholderScenario`, `CYLPlaceholderAction`, `CYLPlaceholderComponent`, `CYLPlaceholderScenarioCatalog`); title chrome keys in `CYLPlaceholderView.h`; tests `Tests/CYLPlaceholderScenarioTests.m`; doc `docs/Placeholder-Scenarios.md`; demo `Examples/Example-Scenarios/` (Swift) |
| Core localization macro and run-time language | `CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderLocalization.h` (`CYLPlaceholderLocalizedString`, `CYLPlaceholderLocalization.language`) |
| Core resource lookup | `CYLPlaceholderLocalization.h` (`CYLPlaceholderResourceBundle()`, `CYLPlaceholderResourceURL(path)`); example lookups `CYLScenarioLocalizedString` / `CYLScenarioExampleResourceURL` in `Examples/Example-Scenarios/Sources/CYLScenarioLocalization.swift`, `CYLPlaceholderExampleLocalizedString` / `CYLPlaceholderExampleResourceURL` in `Examples/Example/CYLPlaceholderExampleLocalization.swift` |
| Accessibility of placeholders and components | `CYLPlaceholderView.m` (`-cyl_updateTapAccessibility`, `accessibilityActivate`, Reduce Motion highlight), `CYLPlaceholderStackView.m` (`-cyl_updateAccessibilityOfComponent:`, grouping); rules in `instructions.md` ("Accessibility"); skills `ios-accessibility`, `accessibility-audit` |
| Placeholder provider and frame | `CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLTableViewPlaceHolderDelegate.h` |
| Refresh public API | `CYLTableViewPlaceHolder/CYLRefresh/CYLRefresh.h` |
| Refresh animated icons | `CYLTableViewPlaceHolder/CYLRefresh/Base/CYLRefreshIconView.h` (icon component, playback policy, `CYLRefreshIconAnimating` protocol: `iconView`, `setIconAnimation…:forState:`, `bundledIconAnimationFileNames` = the `CYLRefresh*` files of `Animations/` plus refresh-suited placeholder files; `cyl_` layout plumbing on `CYLRefreshComponent`), adopted by the animated-image controls `CYLRefreshAnimationHeader`, `CYLRefreshBackAnimationFooter`, `CYLRefreshAutoAnimationFooter` (`animationView`, `setAnimationImages:forState:`); the MJRefresh names `CYLRefreshGifHeader`/`BackGifFooter`/`AutoGifFooter` are compatibility subclasses (`gifView`, `setImages:…` call the general methods); the Normal arrow controls have no icon API; tests `Tests/CYLRefreshIconTests.m`; doc `docs/Refresh-Icon-Animation.md`; demo `Examples/Example-Scenarios/Sources/CYLRefreshIconListViewController.swift` (one page per file, file path, attributes, `RefreshIcons/refresh-icons.json`) |
| HUD style | `CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderHUD.h` (SVProgressHUD-style API on a CYLPlaceholderStackView: show/progress/success/error/info/image, popActivity, dismiss, styles, masks, notifications), scenario `CYLPlaceholderScenarioHUD` in `CYLPlaceholderScenario.h`; tests `Tests/CYLPlaceholderHUDTests.m`; doc `docs/Placeholder-HUD.md`; demo `Examples/Example-Scenarios/Sources/CYLHUDViewController.swift` (Flows tab → HUD) |
| Status bar (red bar, from CYLChatKit `LCCKStatusView`) | `CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderStatusView.h` (`delegate`, `statusViewClicked:`, `CYLPlaceholderStatusViewHight`, `initWithItemAttributes:error:`, `initWithConfiguration:error:`); placement and combination with the placeholder in `UIViewController+CYLPlaceholderStatus.h` (`cyl_statusView`, `cyl_statusDisplay`, `cyl_showsStatusViewWhenOffline`, `cyl_applyStatusConfiguration:`, `UIScrollView.cyl_placeholderHidden`, implemented in `UIScrollView+CYLPlaceholder.m`); network detection `CYLPlaceholderNetworkMonitor.h` (NWPathMonitor); horizontal item key `CYLPlaceholderItemContentAxis` in `CYLPlaceholderView.h`; icon `CYLPlaceholderStatusFail@2x/@3x.png` and `LICENSE.CYLChatKit` in the core bundle; tests `Tests/CYLPlaceholderStatusViewTests.m`; demo `Examples/Example-Scenarios/Sources/CYLStatusBarViewController.swift` with `CYLScenarioExample.bundle/StatusBar/*.json`; doc `docs/Status-Bar.md` |
| Refresh categories | `CYLTableViewPlaceHolder/CYLRefresh/UIScrollView+CYLRefresh.h` |
| Refresh header inset updates | `CYLTableViewPlaceHolder/CYLRefresh/Base/CYLRefreshHeader.m` |
| Example (Swift; issues #2, #3, #6; custom placeholders `PlaceHolderView/WeChatStyle/CYLWeChatStylePlaceHolder.swift`, `PlaceHolderView/XTNetReloader/CYLXTNetReloader.swift`) | `Examples/Example/CYLExampleViewController.swift`, app and scene delegates in `Examples/Example/CYLExampleAppDelegate.swift` |
| Automatic placeholder and style-combination example (Swift) | `Examples/Example/CYLPlaceholderDemoViewController.swift` |
| Main example localization and resource lookup | `Examples/Example/CYLPlaceholderExampleLocalization.swift` (`CYLPlaceholderExampleLocalizedString`, `CYLPlaceholderExampleResourceURL`), table `Examples/Example/CYLPlaceholderExample.bundle/<language>.lproj/CYLPlaceholderExample.strings` |
| Reproduction examples | `Examples/Example-SwiftUI/`, `Examples/Example-objc-01/`, `Examples/Example-objc-02/` |
| Regression tests | `Tests/PlaceholderTests.m` |
| Automatic placeholder tests | `Tests/CYLAutomaticPlaceholderTests.m` |
| Swift call sites and verified Swift spellings | `docs/Swift-Guide.md`; Swift examples `Examples/Example/`, `Examples/Example-SwiftUI/`, `Examples/Example-objc-01/`, `Examples/Example-Scenarios/` |
| Bilingual README and docs, generated navigation | `README.md`, `docs/`, `scripts/update-docs-navigation.py`, `.markdownlint.json`; rules in `instructions.md` ("Bilingual documentation") |
| MJRefresh in every example Podfile (latest version) | `scripts/resolve-mjrefresh-version.sh`, `Examples/*/Podfile`, `scripts/ci-build-example.sh`; rule in `instructions.md` ("Depending on MJRefresh in the examples") |
| CYLTabBarController dependency (latest commit, any branch) | `scripts/resolve-cyltabbarcontroller-commit.sh`, `Examples/Example-Scenarios/Podfile`; rule in `instructions.md` ("Depending on CYLTabBarController") |
| CYLTabBarController in the examples (default integration) | A PlusButton with a plus child view controller, initialized from a configuration file in the example's own `.bundle` with `CYLTabBarController(configurationFile:)`; rule in `instructions.md` "Integrating CYLTabBarController in the examples"; API in CYLTabBarController's `CYLTabBarController.h` and `CYLPlusButton.h`; current example `Examples/Example-Scenarios/Sources/CYLScenarioTabBarController.swift` |
| Integration and usage | `README.md` |
| Issue history | `docs/issue-progress.md` |

Preserve API compatibility and keep this map current when a mapped file or
public API changes.
