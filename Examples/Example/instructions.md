# Folder instructions

This folder contains the main example app (scheme `CYLTableViewPlaceHolder` in
the repository's `CYLTableViewPlaceHolder.xcworkspace`). It demonstrates the
placeholder library and reproduces this repository's own issues. It inherits the
repository instructions.

## Run

```sh
pod install && open CYLTableViewPlaceHolder.xcworkspace
```

From the repository root, run the `CYLTableViewPlaceHolder` scheme. The app uses the
UIScene lifecycle (`CYLSceneDelegate`, named in `Info.plist`).

## Linked issues and how to reproduce them

| Issue | Problem | Status |
| --- | --- | --- |
| [#3](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/3) | Network-error and no-data placeholders cannot be switched | 100/100 |
| [#2](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/2) | Repeated refreshes make the placeholder's subviews disappear | 100/100 |
| [#6](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/6) | The placeholder disappears after another empty refresh | 85/100 (original iOS 9 environment not retested) |
| [#11](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/11) | Placeholders for UICollectionView and plain pages | 85/100: collection views supported and tested; plain pages still have no automatic integration |
| [#15](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/15) | Layout on iPhone XR, XS and XS Max | 80/100 (only XS Max checked) |

### #3: switching placeholders

1. Launch: the table refreshes and ends empty, showing one of two placeholders
   (`makePlaceHolderView` picks the Taobao-style network reloader or the
   WeChat-style empty view at random).
2. Tap the placeholder (or pull down) to refresh again; repeat several times.
3. Bug: the first placeholder stays forever. Expected: each empty refresh can
   show the other placeholder, and the old one is removed.

### #2 and #6: repeated empty refreshes

1. With a placeholder visible, pull down to refresh repeatedly.
2. Bug #2: the placeholder's image or text disappears. Bug #6: the whole
   placeholder disappears after the second empty refresh. Expected: it stays
   intact after every empty refresh.

### #11: automatic placeholders for table and collection views

1. Tap **Auto** (top right).
2. With **Table** selected: tap **Clear**, and the placeholder appears; tap
   **+**, and it disappears after the inserted row.
3. Switch to **Collection** and repeat **Clear** / **+**.
4. Tap **Disable**: clearing no longer shows a placeholder; **Enable**
   restores it.

### #15: screen sizes

Run on iPhone XS Max, XR and XS simulators (or the closest available) and
check that the placeholder fills the table bounds without clipping or scaling
artifacts.

### Not reproduced in this app

[#8](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/8),
[#16](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/16) and
[#17](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/17) (the
placeholder covering a footer or table header) need the frame callback; they are
covered by `Tests/PlaceholderTests.m` (`ruby Tests/run-tests.rb`), not by a demo.

## Styles and FlatDesign items

**Auto → Styles** previews every bundled style and message, a custom image, the
FlatDesign item configured in code and from a plist, and dot, number and text
badges. These are demos, not issue reproductions; parity is tracked in
`docs/flatdesign-item-comparison.md`.
