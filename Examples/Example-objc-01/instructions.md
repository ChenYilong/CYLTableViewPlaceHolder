# Folder instructions

This folder contains the adapted issue 1575 reproduction. Preserve the
original demo author's attribution and inherit the repository instructions.

## Linked issue

| Issue | Problem | Status (docs/issue-progress.md) |
| --- | --- | --- |
| [MJRefresh #1575](https://github.com/CoderMJLee/MJRefresh/issues/1575) (upstream fix attempt: [PR #1576](https://github.com/CoderMJLee/MJRefresh/pull/1576)) | Crash when pulling to refresh a collection view inside JXSegmentedView | 50/100: not reproduced on iPhone 15 / iOS 17.5; the reporter's iOS 16, iPhone 14 Pro and JXSegmentedView setup are not verified |

The demo is the reporter's collection view, moved to a `SceneDelegate` and
pointed at the local pod. It does not include JXSegmentedView.

## Run

```sh
cd Examples/Example-objc-01 && pod install && open Example-objc-01.xcworkspace
```

Run the `ExampleObjC01` scheme. To match the report, use an iPhone 14 Pro
simulator or device on iOS 16 if available.

## Reproduce

1. The navigation title shows **Ready**.
2. Pull the collection view (`issue1575Collection`) down until the header
   starts refreshing; the title shows **Refreshing**.
3. Wait about 3 seconds: the title shows **Finished**.
4. Bug: the app crashes during or after the pull (reported with a floating
   point comparison of the top inset). Expected: no crash, title **Finished**.
5. Repeat several pulls, including pulling again while it is refreshing.

## Automated test

```sh
xcodebuild test -workspace Examples/Example-objc-01/Example-objc-01.xcworkspace -scheme ExampleObjC01 \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.5'
```

`testSceneDelegateCollectionRefreshCompletes` performs one pull and waits for
**Finished**.
