//
//  CYLRefreshAutoFooter.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//
//  [EN] Swift since 2026-11-20: the class is in `CYLRefreshAutoFooter.swift` (docs/Swift-Migration.md, step 11), with the
//       same Objective-C API (`automaticallyRefresh` with its `isAutomaticallyRefresh` getter,
//       `triggerAutomaticallyRefreshPercent`, `autoTriggerTimes`, `loadsWhenContentNotFull`).
//       Objective-C code that uses it imports the umbrella header `CYLTableViewPlaceHolder.h`, which brings the
//       generated Swift header; this header keeps the forward declaration. Objective-C cannot subclass a Swift class:
//       subclasses are written in Swift.
//  [CN] 自 2026-11-20 起该类用 Swift 编写（`CYLRefreshAutoFooter.swift`，docs/Swift-Migration.md 第 11 步），Objective-C API 不变
//       （getter 为 `isAutomaticallyRefresh` 的 `automaticallyRefresh`、`triggerAutomaticallyRefreshPercent`、`autoTriggerTimes`、
//       `loadsWhenContentNotFull`）。使用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；
//       本头文件保留前向声明。Objective-C 不能继承 Swift 类：子类请用 Swift 编写。
//

#import "CYLRefreshFooter.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] A footer that sits right after the content and loads more by itself when it scrolls into view (see
 *      `automaticallyRefresh` and `triggerAutomaticallyRefreshPercent`), or when tapped; the base of the automatic
 *      footers.
 *      The class is Swift (`CYLRefreshAutoFooter.swift`); Objective-C code that messages it imports the umbrella header
 *      `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] 紧跟在内容之后的刷新尾，滚动到可见时自动加载更多（见 `automaticallyRefresh` 与
 *      `triggerAutomaticallyRefreshPercent`），也可点击加载；各自动刷新尾的基类。
 *      该类用 Swift 编写（`CYLRefreshAutoFooter.swift`）；需要调用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshAutoFooter;

NS_ASSUME_NONNULL_END
