# FlatDesign item UI and animation comparison

## Baseline and scoring

The reference is `CYLTabBarController` branch `feat/cross-platform-components`,
commit `ca8beda38c2ca49b81b1782bd932da35ad16640e`. The UI baseline is
`CYLFlatDesignTabBarButton.m`; animation behavior and optional dependencies
are in `CYLTabBarItemAnimation/` and `CYLTabBarController.podspec`. The
placeholder implementation is `CYLPlaceholderView.m` in this repository.
This table compares item UI and the existing placeholder configuration API,
not tab navigation or the tab controller itself.

Scores are per row, not a claim that the entire project has reached 100:
100 means the relevant behavior is implemented and verified; partial scores
identify concrete gaps; 0 means no implementation. A reserved configuration
key alone is not playback support. Where a tab-only behavior has no equivalent
placeholder state, it remains a gap rather than being counted as complete.

| FlatDesign item method or behavior | Placeholder implementation | Score |
| --- | --- | ---: |
| `initWithFrame:` creates image and title views | `CYLPlaceholderItemView` creates both; legacy and configured initializers use it. | 100 |
| `layoutSubviews` / `_updateLayout`: image, title, offsets, insets | Image and title share a centered item; original image dimensions, relative positioning and offsets are implemented. The placeholder constrains long text and uses a separate centered container. | 85 |
| `_updateLayout`: image-only and title-only centering | Both center within the item. | 100 |
| `_updateTabBarButton`: image, title, normal appearance | Image, title, colors, font and background are set from configuration. | 85 |
| `setSelected:`, selected image/title/colors and selection indicator | Explicit selected state switches configured image/title/font/colors and restores normal values; an optional indicator centers or stretches behind the item. Normal and selected light/dark image assets resolve during live trait changes. On-screen rendering has not been visually verified, and indicator configuration does not yet follow `UITabBarAppearance`. | 80 |
| `_effectiveAppearance`, `_stateAppearance`, `_appearanceTitlePositionAdjustment`, `tintColorDidChange` | Explicit normal-state values work; `UITabBarAppearance` state mapping and appearance fallback do not. | 25 |
| `_updateBadgeAppearance`, `actualBadgeSuperView` | Dot, number, and text badges support colors, font, offset and an accessibility value, with localized dot descriptions. No reference `CYLBadgeAppearance` global defaults, animations, full customization, accessible-ancestor handling, or `UITabBarAppearance` state mapping. | 40 |
| `isAccessibilityElement`, `accessibilityLabel`, `accessibilityTraits` | Explicit identifier, label and hint work; selected trait follows explicit selected state. Tab-button accessibility behavior is not fully replicated. | 75 |
| `initTabBarItemAnimation`, `updateTabBarItemAnimation`, `_animationURL`, `_animationSizeValue` | Local GIF and optional or registered backend URL/path and size are recognized; generic keys work. Registration uses a placeholder-specific player protocol rather than the reference engine. | 75 |
| GIF `cyl_animationViewWithFileURL:options:contentMode:` | ImageIO decodes local frames and individual frame delays; capped input/frame memory. It does not use the reference's independently installed GIF subspec. | 65 |
| GIF `cyl_playAnimationView`, `cyl_stopAnimationView`, `cyl_showAnimationViewLastFrame` | Plays once on entering a window; public replay, stop and last-frame controls are tested, including stop across reattachment. Reduce Motion suppresses playback. | 95 |
| Lottie adapter, Objective-C and Swift subspecs | Swift adapter and optional Lottie subspec play and advance with both static and dynamic CocoaPods integration; Objective-C Lottie variant is absent. | 70 |
| PAG adapter and PAG/PAGEnterprise subspecs | libpag adapter and optional PAG subspec play and advance with both static and dynamic integration; PAGEnterprise is absent. | 70 |
| Rive adapter, Swift bridge and Rive subspec | Optional Swift adapter loads a named artboard and state machine, pauses offscreen and falls back on invalid input. Legacy boolean, trigger and linear fixtures start and stop; trigger effects, linear visual progression and data binding remain unverified. | 65 |
| Animation engine registry, factory, custom player registration | Case-insensitive custom extension factories and player lifecycle/error callbacks are available and tested; GIF remains built-in. Registry and engine are not API-equivalent to the reference. | 65 |
| Dark animation URL, dark colors, live appearance swap | Format-specific and generic dark assets switch on trait changes, with static fallback and light recovery tested for Lottie. Generic and Lottie-specific colors reach the Lottie value-provider bridge and custom players; rendered colors and other formats are not yet verified, and PAG/Rive/GIF color overrides are unsupported. | 55 |
| Animation options, playback speed, progress, state preservation | Rive options are wired; Lottie speed and Lottie/PAG seek are exposed and tested. Seek is preserved across window reattachment; cross-format replacement and other option/state parity remain incomplete. | 55 |
| CocoaPods optional animation subspecs and library organization | GIF uses ImageIO in core; Lottie, PAG and Rive have optional subspecs. Static and dynamic combined installations pass runtime tests; reference subspec variants remain absent. | 75 |
| Carthage and iOS 12 compatibility | Existing framework and static UI remain buildable; four-backend animation packaging and runtime behavior are not verified. | 30 |

## Verification and remaining work

The regression suite exercises local GIF decoding, duration, sizing, hiding,
explicit playback/last-frame controls and removal from a window, static layout,
custom animation factory registration, failure fallback and configuration.
It also verifies selection restoration and image-asset resolution during a live
trait transition; the latter is not a visual test.
Badge sizing, selected indicator layout and accessibility-value restoration
are covered by simulator tests, not visual inspection.
Lottie color tests verify the resolved colors reach the provider bridge on
light/dark transitions, not that a particular keypath renders in those colors.
The separate CocoaPods simulator suite checks combined static and
dynamic integration, Lottie and PAG progress, playback controls and last frames,
Lottie dark/light recovery, and
Rive loading, legacy boolean input, trigger and linear playback lifecycle,
pausing and invalid-file fallback. It uses
local fixtures from the sibling reference checkout; it does not verify Rive
visual progression or data-binding effects.
The branch uses a registry, player and factory with separate adapters:
Lottie (`lottie-ios`), PAG (`libpag`), Rive (`RiveRuntime`), and GIF (ImageIO).
Completing the rows above requires Rive data-binding and visual trigger/linear tests,
remaining reference behavior and packaging verification for each format.
Carthage does not yet include the optional animation backends. The upstream
`libpag` pod emitted a missing license-file warning during lint and needs
separate licensing review before distribution.
