# react-native-cylplaceholder

CYLTableViewPlaceHolder for React Native, as a thin layer over CYLTabBarController's `react-native-cyltabbar`:
`CYLPlaceholderItem` is upstream's `CYLAnimationView` plus a title, and the package re-exports `CYLAnimationView`. It has no
native code and no engine logic: both native halves of upstream's view wrap `CYLAnimatedItemView`, the parent of this
project's native `CYLPlaceholderView`.

```tsx
<CYLPlaceholderItem
  file="CYLPlaceholderEmptyBox.json"
  title={t('emptyTitle')}
  animationSpeed={1.5}
  animationLoops
  animationRestartToken={token} // grows: plays again ("restartAnimation" elsewhere)
/>
```

| Name | Meaning |
|:---|:---|
| `animationSpeed`, `animationLoops` | Upstream's names, applied live. |
| `animationRestartToken`, `ref.restart()` | Restart; there is no separate `restartAnimation()`. |

`react-native-cyltabbar` is a peer dependency: npm cannot install a subfolder of a git repository, so install upstream's
package as its README describes, at the commit the repository's `Cartfile` pins. The apps add the animation libraries they
need (iOS subspec, Android dependency), as upstream documents.

## Not covered (TODO)

The native placeholder's repeat count N > 1, its Reduce Motion policy, the scenario catalog, HUD and status views are not in
this package. Not built or run (written statically). MIT, see `LICENSE`.
