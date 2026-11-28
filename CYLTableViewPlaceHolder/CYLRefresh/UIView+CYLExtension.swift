//
//  UIView+CYLExtension.swift
//  CYLRefresh
//
//  Created by MJ Lee on 14-5-28.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

// [EN] The frame shorthands of the refresh controls, in Swift since 2026-11-19 (docs/Swift-Migration.md, step 6) with
//      the same Objective-C accessors (`cylX`, `setCyl_x:`, ...). Each setter writes the whole `frame` once, as before.
// [CN] 刷新控件使用的 frame 便捷访问，自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 6 步），Objective-C 存取方法
//      （`cylX`、`setCyl_x:` 等）不变。每个 setter 与以前一样只整体写一次 `frame`。

import UIKit

extension UIView {

    /**
     * [EN] `frame.origin.x`, readable and writable on its own.
     * [CN] `frame.origin.x`，可单独读写。
     */
    @objc(cyl_x) public dynamic var cylX: CGFloat {
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
    @objc(cyl_y) public dynamic var cylY: CGFloat {
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
    @objc(cyl_w) public dynamic var cylW: CGFloat {
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
    @objc(cyl_h) public dynamic var cylH: CGFloat {
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
    @objc(cyl_size) public dynamic var cylSize: CGSize {
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
    @objc(cyl_origin) public dynamic var cylOrigin: CGPoint {
        get { frame.origin }
        set {
            var frame = self.frame
            frame.origin = newValue
            self.frame = frame
        }
    }
}
