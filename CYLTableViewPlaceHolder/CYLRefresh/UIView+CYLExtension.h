// 代码地址: https://github.com/ChenYilong/CYLTableViewPlaceHolder
//  UIView+Extension.h
//  CYLRefresh
//
//  Created by MJ Lee on 14-5-28.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// [EN] Implemented in Swift since 2026-11-19 (`UIView+CYLExtension.swift`, the same selectors; docs/Swift-Migration.md, step 6). This
//      declaration is for Objective-C callers only: Swift reads the Swift extension itself (`__swift__` is defined while
//      Swift imports the header), so the two never meet.
// [CN] 自 2026-11-19 起用 Swift 实现（`UIView+CYLExtension.swift`，选择器不变；docs/Swift-Migration.md 第 6 步）。这里的声明只供 Objective-C
//      调用方使用：Swift 直接读取 Swift 扩展（Swift 导入头文件时定义了 `__swift__`），两者不会冲突。
#ifndef __swift__
/*!
 * [EN] Shorthand accessors for the parts of a view's frame, used by the refresh controls.
 * [CN] 刷新控件使用的视图 frame 各部分的便捷访问方法。
 */
@interface UIView (CYLExtension)
/*!
 * [EN] `frame.origin.x`, readable and writable on its own.
 * [CN] `frame.origin.x`，可单独读写。
 */
@property (assign, nonatomic) CGFloat cyl_x;
/*!
 * [EN] `frame.origin.y`, readable and writable on its own.
 * [CN] `frame.origin.y`，可单独读写。
 */
@property (assign, nonatomic) CGFloat cyl_y;
/*!
 * [EN] `frame.size.width`, readable and writable on its own.
 * [CN] `frame.size.width`，可单独读写。
 */
@property (assign, nonatomic) CGFloat cyl_w;
/*!
 * [EN] `frame.size.height`, readable and writable on its own.
 * [CN] `frame.size.height`，可单独读写。
 */
@property (assign, nonatomic) CGFloat cyl_h;
/*!
 * [EN] `frame.size`, readable and writable on its own.
 * [CN] `frame.size`，可单独读写。
 */
@property (assign, nonatomic) CGSize cyl_size;
/*!
 * [EN] `frame.origin`, readable and writable on its own.
 * [CN] `frame.origin`，可单独读写。
 */
@property (assign, nonatomic) CGPoint cyl_origin;
@end
#endif

NS_ASSUME_NONNULL_END
