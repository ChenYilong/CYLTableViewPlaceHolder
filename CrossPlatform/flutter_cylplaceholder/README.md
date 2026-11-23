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
| `flutter_cylplaceholder/CYLRefreshView` (`/<id>`) | `CYLNativeRefreshIndicator`, used by `CYLRefreshClassicHeader`, `CYLRefreshClassicFooter` and `CYLRefreshClassicAutoFooter` | creation: `footer` (bool), `loadsAfterNoMoreData`; `drive` (`offset` in logical pixels, negative for a footer, `dragging`, `startedAtEdge`), `release`, `finishRefresh` (`success`; footer: `noMoreData`), footer only `noMoreData` (`value`) | `onPhase` (`phase`, `oldPhase`), `onRefreshing` |
| `flutter_cylplaceholder/hud` | `CYLPlaceholderHUD` | the HUD method names (`showWithStatus`, `showComponents`, ...) | `onAction` |

The refresh view hosts `CYLRefreshDrivenLayout` (the driven mode of `android/merged`) with a `CYLRefreshNormalHeader`. Flutter
keeps the scrolling and the phase machine (`CYLRefreshComponent`, still ended with `endRefreshing`); the indicator mirrors it:
`drive` while pulled, `release` when the finger lifts or a refresh starts, `finishRefresh` when it ends. A footer (creation parameter
`footer: true`) hosts a `CYLRefreshBackNormalFooter` in the same driven layout: the pull is driven as a negative offset,
`finishRefresh` with `noMoreData: true` ends a load and shows "no more data" in one call, and `noMoreData` (`value`) shows or clears it
without a load; `loadsAfterNoMoreData` is a creation parameter. The Dart indicator stays the fallback off Android, in `flutter test`, and
for a footer with a builder, text, icon or image. The Dart contract is tested with mock channels (`test/native_backend_test.dart`); the
native side is `CYLRefreshDrivenLayout` (footer path: `CYLRefreshDrivenLayoutTest`). Not run on a device: the footer view's placement
in the list slot and the native footer's trigger height versus the Dart `expandHeight`.

## Not covered (TODO)

The native placeholder's repeat count N > 1, its Reduce Motion policy, the scenario catalog, HUD and status views are not in
this package. Not built or run (written statically). MIT, see `LICENSE`.
