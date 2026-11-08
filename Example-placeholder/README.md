# KLTableViewAndCollectionViewPlaceholder
![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat) ![CocoaPods](https://img.shields.io/cocoapods/v/KLTableViewAndCollectionViewPlaceholder.svg?style=flat) ![CocoaPods](http://img.shields.io/cocoapods/p/KLTableViewAndCollectionViewPlaceholder.svg?style=flat) ![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)

受 [CYLTableViewPlaceHolder](https://github.com/ChenYilong/CYLTableViewPlaceHolder) 启发，将更新数据的方法尽可能的封装（不只是`reload`），使得不用修改现有代码，及可非常容易的实现`UITableView`和`UICollectionView`的“无数据”提示，零成本。

#### 相比`CYLTableViewPlaceHolder`优点：
* 不用修改`reload`
* 支持更多刷新数据方法。如：`insertSections:`、`deleteSections:`、`insertRowsAtIndexPaths:`等等
* 使用`Auto Layout`设置`placeholderView`位置，更准确，且支持横竖屏切换
* 可随时取消`placeholderView`逻辑(`[self.tableView kl_placeholderViewBlock:nil];`)
* 支持`UICollectionView`

## 使用
CocoaPod
```
pod 'KLTableViewAndCollectionViewPlaceholder'
```
Carthage
```
github "klaus01/KLTableViewAndCollectionViewPlaceholder" 
```
Objective-C
```objective-c
[self.tableView kl_placeholderViewBlock:^UIView * _Nonnull(UITableView * _Nonnull tableView) {
    // 这里做空数据操作，例如弹出提示
    
    // 禁止 TableView 滚动
    tableView.scrollEnabled = NO;
    // 返回无数据提示视图
    return placeholderView;
} backToNormalBlock:^(UITableView * _Nonnull tableView) {
    // 这里做恢复操作
    
    // 恢复 TableView 滚动
    tableView.scrollEnabled = YES;
}];
```
Swift
```swift
tableView.kl_placeholderViewBlock({ (tableView) -> UIView in
    tableView.isScrollEnabled = false
    return placeholderView
}, backToNormalBlock: { (tableView) in
    tableView.isScrollEnabled = true
})
```

## 适用场景
| ![](Images/image1.jpg) | ![](Images/image2.jpg) |
|-------------|-------------|

# License
Centipede is released under the MIT license. See LICENSE for details.

