//
//  CYLRefreshTrailer.h
//  CYLRefresh
//
//  Created by kinarobin on 2020/5/3.
//  Copyright © 2020 小码哥. All rights reserved.
//
//  [EN] Swift since 2026-11-20: the class is in `CYLRefreshTrailer.swift` (docs/Swift-Migration.md, step 11), with the
//       same Objective-C API (`+trailerWithRefreshingBlock:`, `+trailerWithRefreshingTarget:refreshingAction:`,
//       `ignoredScrollViewContentInsetRight`, `automaticallyRefresh` with its `isAutomaticallyRefresh` getter,
//       `triggerAutomaticallyRefreshPercent`, `autoTriggerTimes`).
//       Objective-C code that uses it imports the umbrella header `CYLTableViewPlaceHolder.h`, which brings the
//       generated Swift header; this header keeps the forward declaration. Objective-C cannot subclass a Swift class:
//       subclasses are written in Swift.
//  [CN] 自 2026-11-20 起该类用 Swift 编写（`CYLRefreshTrailer.swift`，docs/Swift-Migration.md 第 11 步），Objective-C API 不变
//       （`+trailerWithRefreshingBlock:`、`+trailerWithRefreshingTarget:refreshingAction:`、`ignoredScrollViewContentInsetRight`、
//       getter 为 `isAutomaticallyRefresh` 的 `automaticallyRefresh`、`triggerAutomaticallyRefreshPercent`、`autoTriggerTimes`）。
//       使用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；本头文件保留前向声明。
//       Objective-C 不能继承 Swift 类：子类请用 Swift 编写。
//

#import "CYLRefreshComponent.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The base class of the horizontal controls at the trailing end of the content: swiping past the end and
 *      releasing runs the refreshing callback (for example to open details); set one as a scroll view's
 *      `cyl_trailer`.
 *      The class is Swift (`CYLRefreshTrailer.swift`); Objective-C code that messages it imports the umbrella header
 *      `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] 位于内容末端的横向控件基类：越过末端滑动并松手时执行刷新回调（例如打开详情）；设为滚动视图的 `cyl_trailer` 使用。
 *      该类用 Swift 编写（`CYLRefreshTrailer.swift`）；需要调用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshTrailer;

NS_ASSUME_NONNULL_END
