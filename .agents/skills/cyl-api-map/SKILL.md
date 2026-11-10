---
name: cyl-api-map
description: Map the placeholder and refresh APIs to their headers, example, tests, and documentation.
---

# API map

Inspect the headers and implementation before changing behavior. Code is the
source of truth; update the README and issue tracker if they become stale.

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
| Placeholder provider and frame | `CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLTableViewPlaceHolderDelegate.h` |
| Refresh public API | `CYLTableViewPlaceHolder/CYLRefresh/CYLRefresh.h` |
| Refresh categories | `CYLTableViewPlaceHolder/CYLRefresh/UIScrollView+CYLRefresh.h` |
| Refresh header inset updates | `CYLTableViewPlaceHolder/CYLRefresh/Base/CYLRefreshHeader.m` |
| Example | `Examples/Example/ViewController.m` |
| Automatic placeholder and style-combination example | `Examples/Example/CYLPlaceholderDemoViewController.m` |
| Reproduction examples | `Examples/Example-SwiftUI/`, `Examples/Example-objc-01/`, `Examples/Example-objc-02/` |
| Regression tests | `Tests/PlaceholderTests.m` |
| Automatic placeholder tests | `Tests/CYLAutomaticPlaceholderTests.m` |
| Swift call sites and verified Swift spellings | `docs/Swift-Guide.md`; Swift examples `Examples/Example-SwiftUI/`, `Examples/Example-objc-01/` |
| Integration and usage | `README.md` |
| Issue history | `docs/issue-progress.md` |

Preserve API compatibility and keep this map current when a mapped file or
public API changes.
