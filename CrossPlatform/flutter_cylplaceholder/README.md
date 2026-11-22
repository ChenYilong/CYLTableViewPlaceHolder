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

## Not covered (TODO)

The native placeholder's repeat count N > 1, its Reduce Motion policy, the scenario catalog, HUD and status views are not in
this package. Not built or run (written statically). MIT, see `LICENSE`.
