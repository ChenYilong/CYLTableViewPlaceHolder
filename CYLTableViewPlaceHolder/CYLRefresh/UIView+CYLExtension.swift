//
//  UIView+CYLExtension.swift
//  CYLRefresh
//
//  Created by MJ Lee on 14-5-28.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

// [EN] The frame shorthands of the refresh controls, in Swift since 2026-11-19 (docs/Swift-Migration.md, step 6) with
//      the same Objective-C accessors (`cyl_x`, `setCyl_x:`, ...). Each setter writes the whole `frame` once, as before.
// [CN] 刷新控件使用的 frame 便捷访问，自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 6 步），Objective-C 存取方法
//      （`cyl_x`、`setCyl_x:` 等）不变。每个 setter 与以前一样只整体写一次 `frame`。

import UIKit

extension UIView {

    /**
     * [EN] `frame.origin.x`, readable and writable on its own.
     * [CN] `frame.origin.x`，可单独读写。
     */
    @objc public dynamic var cyl_x: CGFloat {
        get { frame.origin.x }
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }

    /**
     * [EN] `frame.origin.y`, readable and writable on its own.
     * [CN] `frame.origin.y`，可单独读写。
     */
    @objc public dynamic var cyl_y: CGFloat {
        get { frame.origin.y }
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }

    /**
     * [EN] `frame.size.width`, readable and writable on its own.
     * [CN] `frame.size.width`，可单独读写。
     */
    @objc public dynamic var cyl_w: CGFloat {
        get { frame.size.width }
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }

    /**
     * [EN] `frame.size.height`, readable and writable on its own.
     * [CN] `frame.size.height`，可单独读写。
     */
    @objc public dynamic var cyl_h: CGFloat {
        get { frame.size.height }
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }

    /**
     * [EN] `frame.size`, readable and writable on its own.
     * [CN] `frame.size`，可单独读写。
     */
    @objc public dynamic var cyl_size: CGSize {
        get { frame.size }
        set {
            var frame = self.frame
            frame.size = newValue
            self.frame = frame
        }
    }

    /**
     * [EN] `frame.origin`, readable and writable on its own.
     * [CN] `frame.origin`，可单独读写。
     */
    @objc public dynamic var cyl_origin: CGPoint {
        get { frame.origin }
        set {
            var frame = self.frame
            frame.origin = newValue
            self.frame = frame
        }
    }
}
