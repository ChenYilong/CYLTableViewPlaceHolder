//  代码地址: https://github.com/ChenYilong/CYLTableViewPlaceHolder
//  CYLRefreshFooter.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/3/5.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//  上拉刷新控件
//
//  [EN] Swift since 2026-11-20: the class is in `CYLRefreshFooter.swift` (docs/Swift-Migration.md, step 11), with the same
//       Objective-C API (`+footerWithRefreshingBlock:`, `+footerWithRefreshingTarget:refreshingAction:`,
//       `endRefreshingWithNoMoreData`, the deprecated `noticeNoMoreData`, `resetNoMoreData`, `noMoreData` with its
//       `isNoMoreData` getter, `loadsAfterNoMoreData`, `ignoredScrollViewContentInsetBottom`, the deprecated
//       `automaticallyHidden`, and the former `CYLRefreshNoMoreDataImage` category: `cyl_updateNoMoreDataImage:`,
//       `cyl_placeNoMoreDataImageBesideLabel:inset:size:`).
//       Objective-C code that uses it imports the umbrella header `CYLTableViewPlaceHolder.h`, which brings the
//       generated Swift header; this header keeps the forward declaration. Objective-C cannot subclass a Swift class:
//       subclasses are written in Swift.
//  [CN] 自 2026-11-20 起该类用 Swift 编写（`CYLRefreshFooter.swift`，docs/Swift-Migration.md 第 11 步），Objective-C API 不变
//       （`+footerWithRefreshingBlock:`、`+footerWithRefreshingTarget:refreshingAction:`、`endRefreshingWithNoMoreData`、已废弃的
//       `noticeNoMoreData`、`resetNoMoreData`、getter 为 `isNoMoreData` 的 `noMoreData`、`loadsAfterNoMoreData`、
//       `ignoredScrollViewContentInsetBottom`、已废弃的 `automaticallyHidden`，以及原 `CYLRefreshNoMoreDataImage` 分类的
//       `cyl_updateNoMoreDataImage:`、`cyl_placeNoMoreDataImageBesideLabel:inset:size:`）。使用它的 Objective-C 代码请导入总头文件
//       `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；本头文件保留前向声明。Objective-C 不能继承 Swift 类：子类请用 Swift 编写。
//

#import "CYLRefreshComponent.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The base class of the pull-up (load more) controls; set one as a scroll view's `cyl_footer`.
 *      The class is Swift (`CYLRefreshFooter.swift`); Objective-C code that messages it imports the umbrella header
 *      `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] 上拉加载更多控件的基类；设为滚动视图的 `cyl_footer` 使用。
 *      该类用 Swift 编写（`CYLRefreshFooter.swift`）；需要调用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshFooter;

NS_ASSUME_NONNULL_END
