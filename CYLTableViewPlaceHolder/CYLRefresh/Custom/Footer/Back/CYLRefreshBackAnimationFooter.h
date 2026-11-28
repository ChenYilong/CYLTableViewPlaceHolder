//
//  CYLRefreshBackAnimationFooter.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24 (as MJRefresh's MJRefreshBackGifFooter; renamed and generalized for CYLRefresh).
//  Copyright (c) 2015年 小码哥. All rights reserved.
//
//  [EN] The animated-image control of the MJRefresh documentation under a general name: per-state image sequences
//       (`setAnimationImages:forState:`), or an icon animation (GIF, Lottie, PAG or Rive) through
//       `CYLRefreshIconAnimating`. `CYLRefreshBackGifFooter` is kept as a subclass whose `gifView` and `setImages:…` call these methods.
//  [CN] MJRefresh 文档中“动画图片”控件的通用命名：按状态设置图片序列（`setAnimationImages:forState:`），或通过
//       `CYLRefreshIconAnimating` 设置图标动画（GIF、Lottie、PAG、Rive）。`CYLRefreshBackGifFooter` 作为子类保留，其 `gifView` 与 `setImages:…` 调用这里的方法。
//
//  [EN] Swift since 2026-11-19: the class is in `CYLRefreshBackAnimationFooter.swift` (docs/Swift-Migration.md, step 9), with the same
//       Objective-C API (`animationView`, `setAnimationImages:duration:forState:`, `setAnimationImages:forState:`, the
//       `CYLRefreshIconAnimating` conformance).
//       Objective-C code that uses it imports the umbrella header `CYLTableViewPlaceHolder.h`, which brings the
//       generated Swift header; this header keeps the forward declaration. Objective-C cannot subclass a Swift class:
//       subclasses are written in Swift.
//  [CN] 自 2026-11-19 起该类用 Swift 编写（`CYLRefreshBackAnimationFooter.swift`，docs/Swift-Migration.md 第 9 步），
//       Objective-C API 不变（`animationView`、`setAnimationImages:duration:forState:`、`setAnimationImages:forState:`、
//       `CYLRefreshIconAnimating` 协议）。
//       使用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；本头文件保留前向声明。
//       Objective-C 不能继承 Swift 类：子类请用 Swift 编写。
//

#import "CYLRefreshBackStateFooter.h"
#import "CYLRefreshIconView.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] Animated images (`setAnimationImages:forState:`, `animationView`), or an icon animation (GIF, Lottie, PAG or
 *      Rive) through `CYLRefreshIconAnimating`, which takes the animation view's place with the same layout.
 *      The class is Swift (`CYLRefreshBackAnimationFooter.swift`); Objective-C code that messages it imports the umbrella header
 *      `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] 动画图片（`setAnimationImages:forState:`、`animationView`），或通过 `CYLRefreshIconAnimating` 设置的图标动画（GIF、Lottie、PAG、Rive），
 *      后者以相同布局替换动画视图。
 *      该类用 Swift 编写（`CYLRefreshBackAnimationFooter.swift`）；需要调用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshBackAnimationFooter;

NS_ASSUME_NONNULL_END
