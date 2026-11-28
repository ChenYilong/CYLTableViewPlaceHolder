//  代码地址: https://github.com/ChenYilong/CYLTableViewPlaceHolder
//  CYLRefreshHeader.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/3/4.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//  下拉刷新控件:负责监控用户下拉的状态
//
//  [EN] Swift since 2026-11-20: the class is in `CYLRefreshHeader.swift` (docs/Swift-Migration.md, step 11), with the same
//       Objective-C API (`+headerWithRefreshingBlock:`, `+headerWithRefreshingTarget:refreshingAction:`, `lastUpdatedTimeKey`,
//       `lastUpdatedTime`, `ignoredScrollViewContentInsetTop`, `isCollectionViewAnimationBug`, `setExpandHeight:`,
//       `addsRefreshingInset`, `resetsFooterAfterRefresh`, `clipsWhenBehind`, the second floor: `secondaryTriggerOffset`,
//       `secondaryDimension`, `secondaryCloseTriggerOffset`, `secondaryVelocity`, `secondaryView`, `secondaryOpen`,
//       `secondaryOpenedBlock`, `secondaryClosedBlock`, `openSecondary`, `secondaryShouldOpenBlock`,
//       `secondaryAnimationDuration`, `closeSecondary`).
//       Objective-C code that uses it imports the umbrella header `CYLTableViewPlaceHolder.h`, which brings the
//       generated Swift header; this header keeps the forward declaration. Objective-C cannot subclass a Swift class:
//       subclasses are written in Swift.
//  [CN] 自 2026-11-20 起该类用 Swift 编写（`CYLRefreshHeader.swift`，docs/Swift-Migration.md 第 11 步），Objective-C API 不变
//       （`+headerWithRefreshingBlock:`、`+headerWithRefreshingTarget:refreshingAction:`、`lastUpdatedTimeKey`、`lastUpdatedTime`、
//       `ignoredScrollViewContentInsetTop`、`isCollectionViewAnimationBug`、`setExpandHeight:`、`addsRefreshingInset`、`resetsFooterAfterRefresh`、
//       `clipsWhenBehind` 以及二楼的全部属性和方法）。使用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的
//       Swift 头文件）；本头文件保留前向声明。Objective-C 不能继承 Swift 类：子类请用 Swift 编写。
//

#import "CYLRefreshComponent.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The base class of the pull-down refresh controls: it watches the pull above the content and refreshes on
 *      release; set one as a scroll view's `cyl_header`.
 *      The class is Swift (`CYLRefreshHeader.swift`); Objective-C code that messages it imports the umbrella header
 *      `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] 下拉刷新控件的基类：监视内容上方的下拉，松手时刷新；设为滚动视图的 `cyl_header` 使用。
 *      该类用 Swift 编写（`CYLRefreshHeader.swift`）；需要调用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshHeader;

NS_ASSUME_NONNULL_END
