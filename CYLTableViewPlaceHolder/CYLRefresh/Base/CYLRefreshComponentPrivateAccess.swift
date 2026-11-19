//
//  CYLRefreshComponentPrivateAccess.swift
//  CYLRefresh
//
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//

// [EN] The private members of the Objective-C root `CYLRefreshComponent` (`CYLRefreshComponent.m`) that its Swift
//      subclasses in `Base/` call (docs/Swift-Migration.md, step 11). They are not in a header (a header Swift can read
//      would be part of the module's public interface), so they are reached by selector, as earlier steps did; this file
//      goes away when `CYLRefreshComponent` is Swift (step 12).
// [CN] Objective-C 根类 `CYLRefreshComponent`（`CYLRefreshComponent.m`）中被 `Base/` 里 Swift 子类调用的私有成员
//      （docs/Swift-Migration.md 第 11 步）。它们不在头文件中（Swift 能读取的头文件会成为模块公开接口的一部分），因此与之前的步骤一样按选择器调用；
//      `CYLRefreshComponent` 改为 Swift（第 12 步）后删除本文件。

import UIKit

extension CYLRefreshComponent {

    // [EN] `-cyl_reportPhase`: tells the phase observers when `phase` changed. [CN] `-cyl_reportPhase`：`phase` 变化时通知观察者。
    func cyl_reportPhaseChange() {
        let selector = NSSelectorFromString("cyl_reportPhase")
        typealias Function = @convention(c) (AnyObject, Selector) -> Void
        unsafeBitCast(method(for: selector), to: Function.self)(self, selector)
    }

    // [EN] `-cyl_offsetForDragRate:happenOffset:`: the offset to use under `dragRate` (it may move the content).
    // [CN] `-cyl_offsetForDragRate:happenOffset:`：`dragRate` 下要使用的偏移（可能移动内容）。
    func cyl_offset(forDragRate offsetY: CGFloat, happenOffset happenOffsetY: CGFloat) -> CGFloat {
        let selector = NSSelectorFromString("cyl_offsetForDragRate:happenOffset:")
        typealias Function = @convention(c) (AnyObject, Selector, CGFloat, CGFloat) -> CGFloat
        return unsafeBitCast(method(for: selector), to: Function.self)(self, selector, offsetY, happenOffsetY)
    }

    // [EN] `-cyl_setScrollViewOriginalInset:`: writes the protected ivar `_scrollViewOriginalInset`, which Swift cannot
    //      reach (the public `scrollViewOriginalInset` is read-only).
    // [CN] `-cyl_setScrollViewOriginalInset:`：写入受保护的实例变量 `_scrollViewOriginalInset`（Swift 无法访问；公开的
    //      `scrollViewOriginalInset` 只读）。
    func cyl_setScrollViewOriginalInset(_ inset: UIEdgeInsets) {
        let selector = NSSelectorFromString("cyl_setScrollViewOriginalInset:")
        typealias Function = @convention(c) (AnyObject, Selector, UIEdgeInsets) -> Void
        unsafeBitCast(method(for: selector), to: Function.self)(self, selector, inset)
    }
}
