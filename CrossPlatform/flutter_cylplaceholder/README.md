# flutter_cylplaceholder

CYLTableViewPlaceHolder for Flutter, as a thin layer over CYLTabBarController's `flutter_cyltabbar`: `CYLPlaceholderItem` is
upstream's `CYLAnimationView` plus a title, and the package re-exports `CYLAnimationView` and `CYLAnimationController`.
It has no native code and no engine logic: both native halves of upstream's view wrap `CYLAnimatedItemView`, the parent of
this project's native `CYLPlaceholderView`.

```dart
CYLPlaceholderItem(
  file: 'CYLPlaceholderEmptyBox.json',
  title: l10n.emptyTitle,
  animationSpeed: 1.5,
  animationLoops: true,
  animationRestartToken: token, // grows: plays again ("restartAnimation" elsewhere)
)
```

| Name | Meaning |
|:---|:---|
| `animationSpeed`, `animationLoops` | Upstream's names, applied live. |
| `animationRestartToken`, `controller.restart()` | Restart; there is no separate `restartAnimation()`. |

The package depends on `flutter_cyltabbar` by git and commit (the commit the repository's `Cartfile` pins; run
`scripts/resolve-cyltabbarcontroller-commit.sh --write Cartfile CrossPlatform/flutter_cylplaceholder/pubspec.yaml`). The apps
add the animation libraries they need (iOS subspec, Android dependency), as upstream documents.

## Native Android half (channel contract)

On Android (outside `flutter test`, `CYLPlaceholderNative.enabled`) the widgets below host the native components of this
repository through platform views and method channels; the Dart widgets stay the fallback elsewhere. The Android plugin is in
`android/` and needs `io.github.chenyilong:cyltableviewplaceholder` and `...-refresh` in the local Maven repository
(`scripts/publish-android-native-to-maven-local.sh`, then `:merged:publishToMavenLocal`). Contract tests:
`test/native_backend_test.dart` (mock channels; the native side is covered by the Robolectric tests of `android/`).

| View type / channel | Dart widget | Dart to native | Native to Dart |
|:---|:---|:---|:---|
| `flutter_cylplaceholder/CYLPlaceholderView` (`/<id>`) | `CYLNativePlaceholderView`, used by `CYLPlaceholderView` | creation: the item map plus `animationLoops`, `animationSpeed`, `tappable`; `update` (`name`, `value`) | `onTap` |
| `flutter_cylplaceholder/CYLPlaceholderStackView` (`/<id>`) | `CYLNativePlaceholderStack`, used by `CYLPlaceholderStackView` | creation: `components` (the maps of `CYLPlaceholderComponent.toConfiguration`, an animated icon as an `item`), `backgroundAction`; `update` (`restartAnimation`) | `onAction` (`component-<i>` or `background`) |
| `flutter_cylplaceholder/CYLRefreshView` (`/<id>`) | `CYLNativeRefreshIndicator`, used by the classic, Cupertino, Material, Bezier radar / circle, Delivery, Phoenix and Taurus header and footer classes | creation: `style` (string, see below), `footer` (bool), `scrollMode` (`move`, `front`, `behind`, `locator`: the `name` of `CYLRefreshScrollMode`), `expandHeight` (logical pixels), `loadsAfterNoMoreData`; `drive` (`offset` in logical pixels, negative for a footer, `dragging`, `startedAtEdge`), `release`, `finishRefresh` (`success`; footer: `noMoreData`), footer only `noMoreData` (`value`) | `onPhase` (`phase`, `oldPhase`), `onRefreshing` |
| `flutter_cylplaceholder/hud` | `CYLPlaceholderHUD` | the HUD method names (`showWithStatus`, `showComponents`, ...) | `onAction` |

**Creation parameter `style`** (one per view; a header and a footer are separate views): the lower camel case name of exactly the styles the
Dart API exposes, the same eight values on Android and iOS: `classic`, `cupertino`, `material`, `bezierRadar`, `bezierCircle`, `delivery`,
`phoenix`, `taurus`. A missing or unknown value falls back to `classic`, logs one line (Android: `Log.w`, tag `CYLRefreshView`) and never
throws; any other creation key is ignored. Android maps it in `CYLRefreshStyle` (`android/merged/library`): headers are
`CYLRefreshNormalHeader`, `CYLRefreshCupertinoHeader`, `CYLRefreshMaterialHeader`, `CYLRefreshBezierRadarHeader`,
`CYLRefreshBezierCircleHeader`, `CYLRefreshDeliveryHeader`, `CYLRefreshPhoenixHeader`, `CYLRefreshTaurusHeader`; footers are
`CYLRefreshBackNormalFooter` (`classic`), `CYLRefreshCupertinoFooter` (an auto footer) and, for the rest, a `CYLRefreshDrawnFooter` around the
style's header (`CYLRefreshMaterialFooter`, ... `CYLRefreshTaurusFooter`; `bezierCircle` has no footer class, so it wraps
`CYLRefreshBezierCircleHeader` directly). Every style has an Android class. The Dart style classes build `CYLNativeRefreshIndicator(style: ...)`
only when the native switch is on (`CYLPlaceholderNative.refreshEnabled`) and no builder, text builder, icon builder or image is set; the
drawn styles' colors are sent as creation parameters (written, not built; iOS is the Mac session's to mirror): `foregroundColor` (the
drawing: Android `colorAccent`) and `backgroundColor` (the background: Android `colorPrimary`), both an ARGB integer `0xAARRGGBB`
(`Color.toARGB32()`; it arrives as an Int or a Long, read it as a number), sent only by the drawn Dart classes (`bezierRadar`, `bezierCircle`,
`delivery`, `phoenix`, `taurus`, header and footer) with their Dart values (the defaults too); `classic`, `cupertino` and `material` send neither
key; a missing or non-number value leaves the native style's own color. There is no channel update: the Dart color fields are final.
Drawn footers show the localized "no more data" text (`CYLDrawnFooterView.noMoreDataLabel`, the string of the classic footer) and hide the
style while it is set (written, not built).

The refresh view hosts `CYLRefreshDrivenLayout` (the driven mode of `android/merged`) with the header of the `style` (`CYLRefreshNormalHeader` for `classic`). Flutter
keeps the scrolling and the phase machine (`CYLRefreshComponent`, still ended with `endRefreshing`); the indicator mirrors it:
`drive` while pulled, `release` when the finger lifts or a refresh starts, `finishRefresh` when it ends. A footer (creation parameter
`footer: true`) hosts a `CYLRefreshBackNormalFooter` in the same driven layout: the pull is driven as a negative offset,
`finishRefresh` with `noMoreData: true` ends a load and shows "no more data" in one call, and `noMoreData` (`value`) shows or clears it
without a load; `loadsAfterNoMoreData` is a creation parameter. The Dart indicator stays the fallback off Android, in `flutter test`, and
for a footer with a builder, text, icon or image. The Dart contract is tested with mock channels (`test/native_backend_test.dart`); the
native side is `CYLRefreshDrivenLayout` (footer path: `CYLRefreshDrivenLayoutTest`). Not run on a device: the footer view's placement
in the list slot and the native footer's trigger height versus the Dart `expandHeight`. Slot fit (written, not built): the Dart slot shows
the bottom (header) or top (footer) `pull` points of a view one open height tall, so `CYLRefreshPlatformView` sizes the driven layout to the pull
(`CYLRefreshDrivenLayout.slotHeight`) anchored at that edge, as iOS `CYLRefreshDrivenHost` does; the indicator keeps its own open height (the view's
height changes with every pull for the stretched drawn styles).

**Creation parameters `scrollMode` and `expandHeight`** (always sent, written, not run; one key for Android and iOS; `behind` replaces the earlier Android-only flag):
`scrollMode` is the `.name` of Dart's `CYLRefreshScrollMode` (`move`, `front`, `behind`, `locator`; the hosts also accept `stretch`). `front` and `behind`
pin the native indicator at its own open height at the slot's far edge in a layout as tall as the slot (Dart slides or covers the view); `move` and `stretch`
size the layout to the pull. A missing value is `move`; an unknown one (`locator` included) is `move` and logs one line (Android: `Log.w`, tag `CYLRefreshView`), never
throws. `expandHeight` is Dart's `expandHeight` in dp: Android converts it with the display density and sets it as the header or footer height
(`setHeaderHeightPx` / `setFooterHeightPx`), so the native indicator opens at Dart's height (60 dp, not the classic default 54 dp) and the 6 dp gap
at the slot edge closes; missing or 0 keeps the style's own height. The second floor creation parameters (`secondaryTriggerOffset`,
`secondaryDimension`, `secondaryCloseTriggerOffset`) are sent only with a `secondaryView`, and `openSecondary` / `closeSecondary` follow `isSecondaryOpen`.

## Not covered (TODO)

The native placeholder's repeat count N > 1, its Reduce Motion policy, the scenario catalog, HUD and status views are not in
this package. Not built or run (written statically). MIT, see `LICENSE`.
