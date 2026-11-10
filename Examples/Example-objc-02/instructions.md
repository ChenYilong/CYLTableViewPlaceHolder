# Folder instructions

This folder contains the issue 1523 collection reproduction adapted from the
upstream example, plus a paging table. Preserve the upstream copyright and
license; inherit the repository instructions.

## Linked issues

| Issue | Problem | Screen | Status (docs/issue-progress.md) |
| --- | --- | --- | --- |
| [MJRefresh #1523](https://github.com/CoderMJLee/MJRefresh/issues/1523) | `isCollectionViewAnimationBug` makes collection items flicker | Collection (default) | 30/100: gestures tested; the flicker itself is not reproduced or fixed |
| [MJRefresh #1506](https://github.com/CoderMJLee/MJRefresh/issues/1506) | Collection animation goes wrong when loading with a large pull | Collection (default) | 25/100: a large pull triggers and ends loading; drift and flicker not checked |
| [MJRefresh #1483](https://github.com/CoderMJLee/MJRefresh/issues/1483) | Items move up after repeated header refreshes | Collection (default) | 50/100: inset restore fixed; dragging again while refreshing not reproduced |
| [MJRefresh #1430](https://github.com/CoderMJLee/MJRefresh/issues/1430) | After a refresh restores the offset, the next swipe jumps to the first item | Paging (`-paging`) | 45/100: the jump is not reproduced; the footer case is still offset (fails) |

## Run

```sh
cd Examples/Example-objc-02 && pod install && open Example-objc-02.xcworkspace
```

Run the `ExampleObjC02` scheme. The collection screen opens by default; add the
launch argument `-paging` (Edit Scheme → Run → Arguments) for the paging table.

## Reproduce #1523 (flicker)

1. On **Collection animation**, pull down to refresh; the title shows
   **Header refreshing**, then **Header completed 1**.
2. Watch the items while the header animates closed.
3. Bug: items flicker or redraw while the header ends. Record the screen
   (simulator: File → Record Screen) to compare, since the UI test cannot
   detect flicker.

## Reproduce #1506 (large pull to load)

1. Swipe up about four times to reach the bottom.
2. Pull up far past the footer and release; the title shows
   **Footer refreshing**, then **Footer completed**.
3. Bug: cells drift or flicker while the footer loads and closes.

## Reproduce #1483 (position after repeated refreshes)

1. Note where the first item (`item-0`) sits.
2. Pull down to refresh four times in a row, waiting for
   **Header completed N** each time; also try dragging again while it is still
   refreshing.
3. Bug: after the animation the first item sits higher than before.
   Expected: it returns to its original position (within 2 points).

## Reproduce #1430 (paging, run with `-paging`)

1. Tap **Refresh**; the title shows **Refresh completed** and the table
   restores to `page-2`.
2. Swipe up once. Bug: it jumps back to `page-0`. Expected: `page-3`.
3. Footer case: tap **Last page** (`page-7`), pull up to load more, wait for
   **Load completed**. Bug (still open): the page is offset by about 140–190
   points instead of staying in place, and the next swipe does not land on
   `page-8`.

## Automated tests

```sh
xcodebuild test -workspace Examples/Example-objc-02/Example-objc-02.xcworkspace -scheme ExampleObjC02 \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.5'
```

`CYLCollectionAnimationUITests` covers #1523/#1506 (header and footer complete)
and #1483 (first item position after four refreshes). `CYLPagingUITests`
covers #1430; `testAppendingPageRestoresPreviousPageAfterFooterRefresh` is
expected to fail until the footer case is fixed (also with the old app
delegate, on iOS 17.5 and 26.1).
