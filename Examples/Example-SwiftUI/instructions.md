# Folder instructions

This folder contains the SwiftUI reproduction for upstream refresh issues. It
inherits the repository and vault instructions. Preserve attribution to the
original demo author and keep the local CocoaPods dependency path portable.

## Linked issues

| Issue | Problem | Status (docs/issue-progress.md) |
| --- | --- | --- |
| [MJRefresh #1628](https://github.com/CoderMJLee/MJRefresh/issues/1628) | The refresh animation disappears in SwiftUI after a data update | 50/100: fixed for refreshes started in code; a real pull still needs investigation |
| [MJRefresh #1589](https://github.com/CoderMJLee/MJRefresh/issues/1589) | Removing the KVO observer crashes when a footer leaves a SwiftUI non-scroll-view container | 90/100: no crash in five round trips on iOS 17.5; iOS 15.4 not verified |

## Run

```sh
cd Examples/Example-SwiftUI && pod install && open Example-SwiftUI.xcworkspace
```

Run the `ExampleSwiftUI` scheme on an iPhone simulator.

## Reproduce #1628 (the original, broken configuration)

1. In Xcode, Product → Scheme → Edit Scheme → Run → Arguments, add the launch
   argument `-reproduce-1628`. It restores the original demo's introspection
   callback, which reinstalls the refresh header on every SwiftUI update.
2. Run the app, then tap **Start refresh**.
3. Bug: the status text under the button shows **Lost refresh**; the refresh
   header disappears while the list data updates.

## Check the #1628 fix

1. Run without `-reproduce-1628`.
2. Tap **Start refresh**: the status shows **Refreshing**, then **Finished**
   after the data update, with the header visible the whole time.
3. Pull the list (`songList`) down by hand: it should also show
   **Refreshing** then **Finished**. If the header vanishes during a real pull,
   that is the open part of #1628.

## Reproduce #1589

1. Tap **Open footer lifecycle**; the page shows **Footer lifecycle** and a
   footer wrapped in `UIViewRepresentable`.
2. Tap Back, and repeat five times.
3. Bug (before the fix): a crash removing the KVO observer when the footer
   leaves its container. Expected now: no crash.

## Automated tests

```sh
xcodebuild test -workspace Examples/Example-SwiftUI/Example-SwiftUI.xcworkspace -scheme ExampleSwiftUI \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.5'
```

`testOriginalConfigurationLosesRefreshAfterDataUpdate` reproduces #1628;
`testRefreshSurvivesSwiftUIDataUpdate` and `testPullGestureSurvivesSwiftUIDataUpdate`
check the fix; `testRepresentedFooterSurvivesRepeatedNavigationTeardown` covers #1589.
