# react-native-cylplaceholder

CYLTableViewPlaceHolder for React Native, as a thin layer over CYLTabBarController's `react-native-cyltabbar`:
`CYLPlaceholderItem` is upstream's `CYLAnimationView` plus a title, and the package re-exports `CYLAnimationView`. It has no
native code and no engine logic: both native halves of upstream's view wrap `CYLAnimatedItemView`, the parent of this
project's native `CYLPlaceholderView`.

```tsx
import { CYLPlaceholderItem } from 'react-native-cylplaceholder/item';

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

The animated item lives in its own entry point, `react-native-cylplaceholder/item`, so an app that only uses the refresh API
(`import { CYLRefresh } from 'react-native-cylplaceholder'`) does not need `react-native-cyltabbar` at all. It is an optional peer
dependency: npm cannot install a subfolder of a git repository, so install upstream's
package as its README describes, at the commit the repository's `Cartfile` pins. The apps add the animation libraries they
need (iOS subspec, Android dependency), as upstream documents.

## CYLRefreshPaging on the native container

`CYLRefreshPagingContainer` puts a `CYLRefreshPaging` on the native `CYLRefreshContainer` (Android: header and load-more footer;
iOS: header and the back footer). The pager keeps loading and ending pages through its JavaScript header and footer; the
container only shows their state:

| Container prop | From the pager |
|:---|:---|
| `refreshing` / `enabled` | `header.isRefreshing` / `header.refreshEnabled` |
| `loadingMore` / `noMoreData` / `loadMoreEnabled` | `footer.isRefreshing` / `footer.isNoMoreData` / a footer with `refreshEnabled` |
| `onRefresh` / `onLoadMore` | `paging.refresh()` / `paging.loadMore()` |

```tsx
<CYLRefreshPagingContainer paging={paging}><FlatList data={paging.items ?? []} /* ... */ /></CYLRefreshPagingContainer>
```

It returns null without the native half (`isCYLRefreshContainerAvailable()`); use `CYLRefresh` then. The prop mapping is covered
by `test/refresh_paging_container.test.ts` (`node --test`); the component is only type-checked (`tsc` not run here) and was not
run on a device.

## CYLPlaceholderStack and CYLPlaceholderHUD on the Android native components

`CYLPlaceholderStack` is the Android `CYLPlaceholderStackView` as a view, `CYLPlaceholderHUD` drives the Android
`CYLPlaceholderHUD` over the current activity's content view (both through the core's `CYLPlaceholderBridge` /
`CYLPlaceholderHUDBridge`, registered by `CYLPlaceholderPackage`). The components are the configuration dictionary of
`docs/Placeholder-Scenarios.md`; the `CYLPlaceholderComponent` builders (`icon`, `hint`, `button`, `separator`) make it. iOS is
not done (TODO). Without the native half the stack renders null and the HUD does nothing
(`isCYLPlaceholderStackAvailable()`, `isCYLPlaceholderHUDAvailable()`).

```tsx
const hud = new CYLPlaceholderHUD();
hud.showProgress(0.5, 'Uploading'); hud.showSuccessWithStatus('Saved'); hud.dismissWithDelay(1);
<CYLPlaceholderStack
  components={[CYLPlaceholderComponent.icon({ style: 'cloudOff', title: 'Failed', animationLoops: true }), CYLPlaceholderComponent.button('Retry', 'retry')]}
  restartToken={token} // grows: every animation plays again; ref.restartAnimation() does the same
  onAction={(action) => { /* 'retry' */ }}
/>
```

| Native | Names |
|:---|:---|
| `CYLPlaceholderStack` props | `components`, `scenario`, `backgroundAction`, `restartToken`, event `onAction(action)`, command `restartAnimation` |
| `CYLPlaceholderHUD` methods | `show`, `showWithStatus`, `showProgress`, `setStatus`, `showInfoWithStatus`, `showSuccessWithStatus`, `showErrorWithStatus`, `showComponents` (a component's `action` is a function), `popActivity`, `dismiss`, `dismissWithCompletion`, `dismissWithDelay`, `dispose` |

`CYLPlaceholderHUD` keeps no state of its own (no `visible`, `state`, `style`, `maskType` of the Dart class: the native HUD's
defaults apply; the Dart-only look fields are a TODO). Tests: 9 Robolectric tests in
`android/src/test/.../CYLPlaceholderStackAndHUDTest.kt`, 4 `node --test` tests in `test/placeholder_hud.test.ts`.

## Not covered (TODO)

The native placeholder's repeat count N > 1, its Reduce Motion policy, the scenario catalog and status views are not in
this package. The Android native container (header, footer) builds and runs in `example/` on an emulator (docs/Refresh-Library-Parity.md); the iOS half (`ios/`, header, back footer, `example/ios`) builds and runs on the iOS 27.2 simulator with real gestures (docs/Refresh-Library-Parity.md, row 5); the iOS placeholder stack and HUD are not bridged (TODO). MIT, see `LICENSE`.
