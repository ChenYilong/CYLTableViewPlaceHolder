# FlatDesign item UI and animation comparison

## Baseline and scoring

The reference is `CYLTabBarController` branch `feat/cross-platform-components`
(HEAD `a6e8c36eb3f46feadf325ff1d1bc60ee082c0cb7` on 2026-11-09). The UI
baseline is `CYLFlatDesignTabBarButton.m`; the animation baseline is
`CYLTabBarItemAnimation/`, `LottieSwift/`, `RiveSwift/` and the subspecs in
`CYLTabBarController.podspec`. The placeholder implementation is
`CYLPlaceholderView.m`, `CYLPlaceholderAnimation/`, `LottieSwift/`,
`RiveSwift/` and `CYLTableViewPlaceHolder.podspec`.

Scope: only item UI and its animation, measured against the placeholder's
public item API (the `CYLPlaceholderItem…` keys, appearance properties and
playback methods). Tab navigation, the tab controller and the plus button are
out of scope.

Scoring per row: 100 = implemented the way the reference does it (or with a
placeholder equivalent where the reference reads a tab-bar-only object) **and**
verified by simulator tests; lower scores list the concrete gap. Reserved keys,
compilation or unverified visual behavior do not count.

## Method-by-method comparison

| FlatDesign item (reference) | Placeholder implementation | Animation support | Score |
| --- | --- | --- | ---: |
| `initWithFrame:` creates image and title views | Yes — `CYLPlaceholderItemView` creates both; every initializer uses it. | — | 100 |
| `layoutSubviews` / `_updateLayout`: title at the bottom (−2 pt), image centered above it, item and appearance title offsets, image offset, insets change size only | Yes — same geometry (restored after an untested rewrite had replaced it with 24 pt spacing); the item's title offset wins, else `defaultTitlePositionAdjustment`. Frame tests plus a rendered-pixel test. | Animation-only item: the image slot takes the animation size, as `isLottieOnlyItem`. | 100 |
| `_updateLayout` image-only / title-only centering (`layoutCentered`) | Yes — always centered when alone. | — | 100 |
| `_updateTabBarButton`: image, title, colors, font, background | Yes — from item keys; light/dark image assets follow trait changes. | — | 100 |
| `setSelected:`, selected image/title/colors/font, `_updateSelectionIndicator` (resizable fills, others centered, tinted) | Yes — explicit selected values, then selected appearance defaults, then normal values; indicator from the view or its appearance default. Rendered-pixel test checks selected image and indicator, and restoration. | — | 100 |
| `_effectiveAppearance`, `_stateAppearance`, `_iconColorForState`, `_appearanceTitlePositionAdjustment`, `tintColorDidChange` | Equivalent — `UI_APPEARANCE_SELECTOR` defaults (title/icon/background color, font, selected variants, title position, indicator image/tint) applied live, including through the appearance proxy. Explicit item values win; values set directly on `textLabel`/`imageView` are kept; an icon without a color follows `tintColor`. | — | 100 |
| `_updateBadgeAppearance`, `actualBadgeSuperView`, `CYLBadgeAppearance` | Equivalent — `CYLPlaceholderBadgeAppearance` (colors, font, insets, corner radius, animation) with the reference's "applied appearance" rule: values set on `badgeLabel` are kept. Dot/number/text styles, offset, synchronous state with a cosmetic pop animation. The badge lives inside the item, so no accessible-ancestor lookup is needed. | Badge pop honors Reduce Motion. | 100 |
| `isAccessibilityElement`, `accessibilityLabel`, `accessibilityTraits` | Yes — element when it has content or explicit labels; label = explicit label or title; selected trait follows selection. Badge announced once: inside the placeholder's value when it is an element, otherwise by the badge label. | — | 95 |
| `initTabBarItemAnimation` / `updateTabBarItemAnimation`, `_animationURL`, `_animationFilePath`, `_animationSizeValue`, `_animationContentMode`, `_animationSpeed` | Yes — generic and engine-specific URL/path/size keys; `contentMode` and `animationSpeed` options are the per-item form of the controller-level settings. Options travel in the URL fragment, as in the reference. | All engines | 100 |
| GIF `CYLGIFTabBarItemAnimator` view provider (`cyl_animationViewWithFileURL:options:contentMode:`) | Yes — `GIF` subspec with `CYLGIFPlaceholderItemAnimator` (ImageIO, per-frame delays, 16 MB / 500 frames / 64 MB caps). Core keeps its built-in decoder when the subspec is absent. | GIF | 100 |
| GIF `cyl_playAnimationView` / `cyl_stopAnimationView` / `cyl_showAnimationViewLastFrame` | Yes — plays once on entering a window, replay/stop/last frame, stop survives reattachment, Reduce Motion. | GIF | 100 |
| Lottie: `LottieSwift` subspec (Swift bridge + Objective-C animator), `lottie-ios` ≥ 4.5.1, iOS 13 | Yes — `LottieSwift/CYLPlaceholderCompatibleLottie.swift` + `CYLLottiePlaceholderItemAnimator` (fallback priority); `Lottie` is an alias. Swift-only by decision: no Objective-C Lottie 2.x flavor. Keypath colors verified by rendered pixels. | Lottie | 100 |
| PAG: `PAG` and `PAGEnterprise` subspecs (`-fno-modules` for enterprise) | Yes — `CYLPAGPlaceholderItemAnimator`; both subspecs pass the runtime suite. | PAG | 100 |
| Rive: `CYLRiveTabBarItemAnimator` + `RiveSwift` views (data binding, legacy inputs/triggers/linear, colors) | Yes — ported views, plus offscreen pause and load/failure callbacks. Load, legacy input/trigger/linear lifecycle, offscreen pause, fallback and color delivery are tested. | Rive | 95 |
| `CYLTabBarItemAnimator` protocols, `CYLTabBarItemAnimatorRegistry`, `CYLTabBarItemAnimationFactory`, `CYLTabBarItemAnimationPlayer`, `CYLTabBarItemAnimationPlayableView`, `CYLTabBarItemViewAnimator`, engine + Core service | Yes — `CYLPlaceholderItem…` equivalents; the engine installs itself into Core's private `CYLPlaceholderItemAnimationService`; custom animators register at runtime (tested). The block-based `registerAnimationFactory:` API is kept and has the highest precedence. | All engines | 100 |
| Dark URL, generic/dark/engine colors, live appearance swap | Yes — dark URLs per engine; generic colors below dark/engine colors; Lottie colors drawn (pixel test); Rive colors reach the view on light/dark switches. PAG and GIF have no color override, as in the reference. | Lottie, Rive | 100 |
| Speed/progress carried across replacement (`copyAnimationStateFromView:toView:`) | Yes — speed and seek survive the dark-mode replacement (tested); unsupported operations return `NO`. | Lottie, PAG | 100 |
| CocoaPods organization (`CYLTabBarItemAnimation`, `<Library>/` folders, per-library subspecs, `static_framework`, `DEFINES_MODULE`) | Yes — same layout and subspec names; static and dynamic integrations pass; `pod lib lint` passes for every subspec (see verification). | All | 100 |
| Carthage and iOS 12 | Carthage builds the core xcframework with its bundles, as the reference's Carthage demo (backends are CocoaPods-only in both). iOS 12 runtime is not verifiable with Xcode 27. | — | 90 |

## Verification (2026-11-09, Xcode 27.2, iOS 17.5 simulators)

- `ruby Tests/run-tests.rb`: 76 tests pass (Core, built-in GIF, shared
  animation module without engines, layout geometry, rendered selection,
  appearance proxy, badge appearance and accessibility).
- `ruby Tests/run-animation-tests.rb` (LottieSwift, GIF, PAG, Rive): passes
  with `LINKAGE=static` and `LINKAGE=dynamic`, and with
  `PAG_SUBSPEC=PAGEnterprise`.
- Example app builds through the workspace; `carthage build --no-skip-current
  --use-xcframeworks` builds `CYLTableViewPlaceHolder.xcframework`.
- `pod lib lint` with `scripts/pod-lint.xcconfig`; the upstream `libpag` pod
  warns about a missing license file.

The baseline `master` (826c07e) did not compile: three property
redeclarations, `title.length` on `id`, and an undeclared
`CYLPlaceholderItemPAGDarkColors`. The scores in
[flatdesign-vs-placeholder-comparison.md](flatdesign-vs-placeholder-comparison.md)
were therefore never verified; this document replaces them.

## TODO: outstanding work before 100%

| TODO | Current gap and implementation notes | Verification needed |
| --- | --- | --- |
| TODO — accessibility parity (95) | Behavior matches the reference and is asserted programmatically (element, label, traits, one badge announcement, caller values preserved). No VoiceOver speech session or Accessibility Inspector audit has been run. | Run VoiceOver (or an XCUITest accessibility audit) on the example for a placeholder that is an element and one inside an accessible container. |
| TODO — Rive playback (95) | Implementation is the reference port. Visible trigger effects, linear progression and data-binding color rendering are not pixel-verified; the `icons.riv` fixture has no `color` view-model property, so color delivery is tested, not drawing. | Add a fixture with a bound color and a trigger, then compare rendered frames before and after. |
| TODO — Carthage and iOS 12 (90) | Xcode 27 SDKs require iOS 15, and no iOS 12 simulator is installed, so the declared iOS 12 minimum is unverified at runtime. Carthage parity (core framework only) matches the reference. | Build and test Core with an older Xcode against an iOS 12 simulator or device. |

Known risks: `registerAnimationFactory:` (block API) and the registry coexist;
a block factory wins for its extension. The Lottie animator only takes
`.json`/`.lottie` (the reference takes any file) so unknown formats still
report `CYLPlaceholderAnimationErrorUnsupportedFormat`. `libpag` license-file
warning needs review before distribution.
