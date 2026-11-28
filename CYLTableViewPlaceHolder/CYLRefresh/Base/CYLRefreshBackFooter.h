//
//  CYLRefreshBackFooter.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//
//  [EN] Swift since 2026-11-20: the class is in `CYLRefreshBackFooter.swift` (docs/Swift-Migration.md, step 11), with the
//       same Objective-C API (`noMoreDataDisplayDuration`, `followsContentWhenNoMoreData`, `scrollsContentAfterLoading`, the
//       second floor: `secondaryTriggerOffset`, `secondaryDimension`, `secondaryCloseTriggerOffset`, `secondaryView`,
//       `secondaryOpen`, `secondaryOpenedBlock`, `secondaryClosedBlock`, `secondaryVelocity`, `openSecondary`,
//       `closeSecondary`).
//       Objective-C code that uses it imports the umbrella header `CYLTableViewPlaceHolder.h`, which brings the
//       generated Swift header; this header keeps the forward declaration. Objective-C cannot subclass a Swift class:
//       subclasses are written in Swift.
//  [CN] 自 2026-11-20 起该类用 Swift 编写（`CYLRefreshBackFooter.swift`，docs/Swift-Migration.md 第 11 步），Objective-C API 不变
//       （`noMoreDataDisplayDuration`、`followsContentWhenNoMoreData`、`scrollsContentAfterLoading` 以及二楼的全部属性和方法）。
//       使用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；本头文件保留前向声明。
//       Objective-C 不能继承 Swift 类：子类请用 Swift 编写。
//

#import "CYLRefreshFooter.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] A footer that stays hidden below the content and loads more when the user pulls up past it and releases; the
 *      scroll view rebounds when loading ends. The base of the back footers, with the optional second floor.
 *      The class is Swift (`CYLRefreshBackFooter.swift`); Objective-C code that messages it imports the umbrella header
 *      `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] 隐藏在内容下方的刷新尾，用户上拉越过它并松手时加载更多，加载结束后滚动视图回弹。各回弹刷新尾的基类，支持可选的二楼。
 *      该类用 Swift 编写（`CYLRefreshBackFooter.swift`）；需要调用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshBackFooter;

NS_ASSUME_NONNULL_END
