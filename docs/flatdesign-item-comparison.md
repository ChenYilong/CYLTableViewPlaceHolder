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

## TODO: outstanding work before 100%

Each entry below maps to a comparison row scoring below 100. Keep these TODOs
until implementation and the stated evidence support a 100 score. Do not raise a
score because a key is reserved, code compiles, or behavior is assumed from a
reference implementation.

| TODO | Current gap and implementation notes | API, defect, or verification considerations |
| --- | --- | --- |
| TODO — item layout (85) | Compare image/title geometry, insets, offsets, clipping, and long-text sizing against `_updateLayout`; cover dynamic type, narrow widths, and orientation changes. | Preserve placeholder-specific centering and wrapping; verify actual frames and rendered layouts, not only helper calculations. |
| TODO — normal item appearance (85) | Implement the supported normal-state appearance behavior that is relevant to a placeholder, including tint updates and fallback behavior. | Avoid depending on tab-controller-only state; define precedence between explicit placeholder attributes and UIKit appearance before adding configuration keys. |
| TODO — selection and indicator (80) | Verify selected image/title/color/font transitions and the indicator through live trait changes and rendered UI; decide whether indicator appearance fallback is needed. | Current indicator is an explicit view property, not `UITabBarAppearance` state mapping. Preserve direct customization and normal values across repeated selection. |
| TODO — appearance and state fallback (25) | Add only meaningful placeholder equivalents of `_effectiveAppearance`, `_stateAppearance`, title-position adjustment, and tint updates. | Define precedence and reset semantics before exposing more keys; avoid importing tab-bar-only APIs without a placeholder use case. |
| TODO — badge behavior (40) | Add a shared/configurable appearance model, supported badge animation behavior, and complete badge state/accessibility handling where appropriate. | Current public interface exposes a label, raw value, style helper and offset but no global appearance object; assess whether label mutation is the intended stable API. Handle accessible ancestors without overwriting user-owned accessibility values, and test hide/show/reuse. |
| TODO — accessibility parity (75) | Verify the view and badge with VoiceOver, including a placeholder that is itself an accessibility element and one hosted inside an accessible container. | Current badge value is assigned to the placeholder while the badge label is also accessible; determine a single non-duplicating announcement strategy and preserve caller-provided labels/values. |
| TODO — animation item configuration (75) | Complete reference-compatible local source, size, and options behavior and document which generic keys are supported by each backend. | Validate plist and code input equivalently; avoid accepting network URLs as local files or silently treating unsupported option values as active features. |
| TODO — GIF adapter parity (65) | Verify frame timing, content modes, image sizing, decode limits, and rendered behavior against the reference GIF player. | GIF is intentionally decoded with ImageIO in Core rather than a third-party library. Keep input/memory caps and static fallback; decide whether a separate optional subspec has a real packaging benefit before adding one. |
| TODO — GIF lifecycle (95) | Perform a visual playback pass for first-frame, per-frame timing, last-frame, replay, stop, removal/re-attachment, hidden state, and Reduce Motion. | Current simulator checks cover lifecycle and decoded frames but do not constitute visual verification. Keep playback one-shot and ensure animations do not restart after explicit stop. |
| TODO — Objective-C Lottie variant (70) | Decide whether supporting the reference's Objective-C Lottie variant is required; if so, add an isolated adapter/subspec and integration fixture. | Keep legacy Lottie versions optional and ensure Core does not acquire a Lottie dependency; test static and dynamic linkage and minimum iOS requirements. |
| TODO — PAG enterprise variant (70) | Evaluate and, if justified, add the reference-compatible `PAGEnterprise` subspec alongside the existing PAG adapter. | Do not install `libpag` and `libpag-enterprise` together if they provide conflicting modules. Resolve and document the existing upstream license-file warning before distribution. |
| TODO — Rive playback (65) | Verify visible trigger effects, linear animation progression, data-binding values, async load/failure, offscreen pause, and state restoration with real fixtures. | Current trigger and linear tests establish start/stop lifecycle only; they do not prove visible progression or data-binding effects. Validate option names, types, defaults, and unsupported combinations. |
| TODO — animation registry/engine parity (65) | Decide whether to replace or extend the custom extension-factory registry to provide reference-like matcher, factory, player, and engine lifecycle semantics. | The current factory API is simpler and not equivalent. Specify registration precedence, duplicate registration/replacement, thread guarantees, cancellation, errors, and behavior of already-created views before changing the public interface. |
| TODO — dark animation and colors (55) | Verify rendered Lottie keypath overrides and support color overrides for PAG, Rive, and GIF only where those engines expose a reliable facility. | Current tests verify color dictionaries reach the Lottie bridge, not rendered pixels. Keep generic colors below dark/specific overrides, clear stale keypaths on replacement, and log unsupported backend behavior explicitly. |
| TODO — options and playback state (55) | Define and test state transfer across animation source/backend changes, including progress, speed, last-frame, stop, and Rive options. | Capabilities differ by backend. Public methods must return `NO` for unsupported operations and avoid stale state silently affecting replacement animations. |
| TODO — CocoaPods parity (75) | Verify package boundaries and add only justified reference variants, including GIF or enterprise/Objective-C flavors if supported. | Keep optional engines out of Core, preserve the library's iOS 12 minimum, declare newer minimums only on the relevant subspecs, and lint static and dynamic integrations. |
| TODO — Carthage and iOS 12 (30) | Add reproducible Carthage packaging for optional adapters if supported, then build and test Core at its declared iOS 12 deployment target. | Current combined CocoaPods integration does not prove Carthage support or iOS 12 runtime compatibility. Document toolchain limitations and verify resource bundles, Swift module embedding, and dependency linkage. |
