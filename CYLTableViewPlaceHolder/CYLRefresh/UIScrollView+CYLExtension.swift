//
//  UIScrollView+CYLExtension.swift
//  CYLRefresh
//
//  Created by MJ Lee on 14-5-28.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

// [EN] The inset, offset and content size shorthands of the refresh controls and the scroll metrics, in Swift since
//      2026-11-19 (docs/Swift-Migration.md, step 6) with the same Objective-C accessors. The `CYLScrollDirection` enum
//      stays in `UIScrollView+CYLExtension.h`. What Swift cannot express stays in `UIScrollView+CYLExtensionSupport.m`
//      (rule 6): `+load`, which hands `cylInstallSideInsetWriter(_:reader:exceptionGuard:)` below the writer of the
//      bottom, left and right insets, the reader of its depth (`cylIsWritingSideInset`, read by the Swift
//      `CYLRefreshHeader`) and an `@try` / `@finally` guard for the header's own inset writes; the writer keeps the depth
//      right with `@try` / `@finally` when a `contentInset` observer throws an Objective-C exception (Swift cannot catch
//      one).
// [CN] 刷新控件使用的 inset、偏移、内容尺寸便捷访问与滚动采样，自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 6 步），
//      Objective-C 存取方法不变。`CYLScrollDirection` 枚举保留在 `UIScrollView+CYLExtension.h`。Swift 无法表达的部分保留在
//      `UIScrollView+CYLExtensionSupport.m`（第 6 条）：`+load` 把下、左、右 inset 的写入函数、其嵌套深度的读取函数（`cylIsWritingSideInset`，
//      Swift 的 `CYLRefreshHeader` 读取）以及刷新头写入自身 inset 时使用的 `@try` / `@finally` 保护交给下面的
//      `cylInstallSideInsetWriter(_:reader:exceptionGuard:)`；写入函数用 `@try` / `@finally` 保证 `contentInset` 的观察者抛出
//      Objective-C 异常时深度仍然正确（Swift 无法捕获这种异常）。

import UIKit
import ObjectiveC

// [EN] Writes `contentInset` while counting the write as a side-inset write (`UIScrollView+CYLExtensionSupport.m`).
// [CN] 写入 `contentInset`，并把这次写入计为侧边 inset 写入（`UIScrollView+CYLExtensionSupport.m`）。
typealias CYLRefreshSideInsetWriter = @convention(block) (UIScrollView, UIEdgeInsets) -> Void

// [EN] YES while a side-inset write runs (`UIScrollView+CYLExtensionSupport.m`). [CN] 侧边 inset 写入期间为 YES（`UIScrollView+CYLExtensionSupport.m`）。
typealias CYLRefreshSideInsetWriteReader = @convention(block) () -> Bool

// [EN] Runs `body`, then `cleanup` even when `body` throws an Objective-C exception (`@try` / `@finally` in
//      `UIScrollView+CYLExtensionSupport.m`; Swift cannot catch one).
// [CN] 执行 `body`，即使 `body` 抛出 Objective-C 异常也会执行 `cleanup`（`UIScrollView+CYLExtensionSupport.m` 中的 `@try` / `@finally`；
//      Swift 无法捕获这种异常）。
typealias CYLRefreshExceptionGuard = @convention(block) (@escaping @convention(block) () -> Void,
                                                         @escaping @convention(block) () -> Void) -> Void

// [EN] The samples of `cylUpdateScrollMetrics`, one per scroll view (an associated object).
// [CN] `cylUpdateScrollMetrics` 的采样，每个滚动视图一个（关联对象）。
private final class CYLScrollMetrics {
    var previousOffset = CGPoint.zero
    var distance: CGFloat = 0
    var direction = CYLScrollDirection.none
}

// [EN] The associated-object key of the scroll metrics: a stable address for the process's lifetime.
// [CN] 滚动采样的关联对象 key：进程内地址固定。
private enum CYLScrollExtensionKey {
    static let metrics = UnsafeRawPointer(UnsafeMutablePointer<UInt8>.allocate(capacity: 1))
}

extension UIScrollView {

    // [EN] Set once from `+load` (`UIScrollView+CYLExtensionSupport.m`). [CN] 由 `+load` 设置一次（`UIScrollView+CYLExtensionSupport.m`）。
    private static var cylSideInsetWriter: CYLRefreshSideInsetWriter?
    // [EN] Set once from `+load`, with the writer. [CN] 由 `+load` 与写入函数一起设置一次。
    private static var cylSideInsetWriteReader: CYLRefreshSideInsetWriteReader?

    // [EN] The entry point of `+load` (`UIScrollView+CYLExtensionSupport.m`, which declares this selector).
    // [CN] `+load` 的入口（`UIScrollView+CYLExtensionSupport.m` 声明了该选择器）。
    // [EN] Set once from `+load`, with the writer. [CN] 由 `+load` 与写入函数一起设置一次。
    private static var cylRefreshExceptionGuard: CYLRefreshExceptionGuard?

    @objc(cyl_installSideInsetWriter:reader:exceptionGuard:)
    static func cylInstallSideInsetWriter(_ writer: @escaping CYLRefreshSideInsetWriter,
                                           reader: @escaping CYLRefreshSideInsetWriteReader,
                                           exceptionGuard: @escaping CYLRefreshExceptionGuard) {
        cylSideInsetWriter = writer
        cylSideInsetWriteReader = reader
        cylRefreshExceptionGuard = exceptionGuard
    }

    // [EN] Runs `body`, then `cleanup` even when `body` throws an Objective-C exception (the header's own inset writes).
    // [CN] 执行 `body`，即使 `body` 抛出 Objective-C 异常也会执行 `cleanup`（刷新头自己写入 inset 时使用）。
    static func cylRefreshPerform(_ body: @escaping () -> Void, cleanup: @escaping () -> Void) {
        if let exceptionGuard = cylRefreshExceptionGuard {
            exceptionGuard(body, cleanup)
        } else {
            body()
            cleanup()
        }
    }

    // [EN] YES while `cylInsetB` / `cylInsetL` / `cylInsetR` write the inset: the header tells a footer's or trailer's
    //      write from a new top inset by it (issue MJRefresh#1483).
    // [CN] `cylInsetB` / `cylInsetL` / `cylInsetR` 写入 inset 期间为 YES：刷新头据此区分刷新尾或 trailer 的写入与新的顶部 inset
    //      （issue MJRefresh#1483）。
    static var cylIsWritingSideInset: Bool {
        cylSideInsetWriteReader?() ?? false
    }

    // [EN] Writes a bottom, left or right inset, so the header can tell it from a new top inset.
    // [CN] 写入下、左或右 inset，让刷新头能与新的顶部 inset 区分。
    private func cylWriteSideInset(_ inset: UIEdgeInsets) {
        if let writer = UIScrollView.cylSideInsetWriter {
            writer(self, inset)
        } else {
            contentInset = inset
        }
    }

    /**
     * [EN] The effective content inset: `adjustedContentInset` (iOS 11 and later), else `contentInset`.
     * [CN] 实际生效的内容 inset：iOS 11 及以后为 `adjustedContentInset`，否则为 `contentInset`。
     */
    @objc(cyl_inset) public dynamic var cylInset: UIEdgeInsets {
        // [EN] The library needs iOS 15, so `adjustedContentInset` always exists. [CN] 库最低 iOS 15，`adjustedContentInset` 总是存在。
        adjustedContentInset
    }

    /**
     * [EN] The top of `cylInset`; setting it changes `contentInset.top` so that the effective top inset becomes the
     *      value.
     * [CN] `cylInset` 的上边距；设置时修改 `contentInset.top`，使实际生效的上边距等于该值。
     */
    @objc(cyl_insetT) public dynamic var cylInsetT: CGFloat {
        get { cylInset.top }
        set {
            var inset = contentInset
            inset.top = newValue - (adjustedContentInset.top - contentInset.top)
            contentInset = inset
        }
    }

    /**
     * [EN] The bottom of `cylInset`; setting it changes `contentInset.bottom` so that the effective bottom inset becomes
     *      the value.
     * [CN] `cylInset` 的下边距；设置时修改 `contentInset.bottom`，使实际生效的下边距等于该值。
     */
    @objc(cyl_insetB) public dynamic var cylInsetB: CGFloat {
        get { cylInset.bottom }
        set {
            var inset = contentInset
            inset.bottom = newValue - (adjustedContentInset.bottom - contentInset.bottom)
            cylWriteSideInset(inset)
        }
    }

    /**
     * [EN] The left of `cylInset`; setting it changes `contentInset.left` so that the effective left inset becomes the
     *      value.
     * [CN] `cylInset` 的左边距；设置时修改 `contentInset.left`，使实际生效的左边距等于该值。
     */
    @objc(cyl_insetL) public dynamic var cylInsetL: CGFloat {
        get { cylInset.left }
        set {
            var inset = contentInset
            inset.left = newValue - (adjustedContentInset.left - contentInset.left)
            cylWriteSideInset(inset)
        }
    }

    /**
     * [EN] The right of `cylInset`; setting it changes `contentInset.right` so that the effective right inset becomes
     *      the value.
     * [CN] `cylInset` 的右边距；设置时修改 `contentInset.right`，使实际生效的右边距等于该值。
     */
    @objc(cyl_insetR) public dynamic var cylInsetR: CGFloat {
        get { cylInset.right }
        set {
            var inset = contentInset
            inset.right = newValue - (adjustedContentInset.right - contentInset.right)
            cylWriteSideInset(inset)
        }
    }

    /**
     * [EN] `contentOffset.x`, readable and writable on its own.
     * [CN] `contentOffset.x`，可单独读写。
     */
    @objc(cyl_offsetX) public dynamic var cylOffsetX: CGFloat {
        get { contentOffset.x }
        set {
            var offset = contentOffset
            offset.x = newValue
            contentOffset = offset
        }
    }

    /**
     * [EN] `contentOffset.y`, readable and writable on its own.
     * [CN] `contentOffset.y`，可单独读写。
     */
    @objc(cyl_offsetY) public dynamic var cylOffsetY: CGFloat {
        get { contentOffset.y }
        set {
            var offset = contentOffset
            offset.y = newValue
            contentOffset = offset
        }
    }

    /**
     * [EN] `contentSize.width`, readable and writable on its own.
     * [CN] `contentSize.width`，可单独读写。
     */
    @objc(cyl_contentW) public dynamic var cylContentW: CGFloat {
        get { contentSize.width }
        set {
            var size = contentSize
            size.width = newValue
            contentSize = size
        }
    }

    /**
     * [EN] `contentSize.height`, readable and writable on its own.
     * [CN] `contentSize.height`，可单独读写。
     */
    @objc(cyl_contentH) public dynamic var cylContentH: CGFloat {
        get { contentSize.height }
        set {
            var size = contentSize
            size.height = newValue
            contentSize = size
        }
    }

    /**
     * [EN] Call once before scrolling, then once per scroll event, to sample `contentOffset`. The first sample has zero
     *      distance and no direction. Subsequent samples report the signed change along the dominant axis, in points,
     *      until the next sample.
     * [CN] 滚动前调用一次，之后每次滚动事件调用一次，以采样 `contentOffset`。第一次采样距离为 0、没有方向；之后的采样给出
     *      主要轴上的有符号变化量（点），直到下一次采样。
     */
    @objc(cyl_updateScrollMetrics) public dynamic func cylUpdateScrollMetrics() {
        let offset = contentOffset
        if let metrics = cylScrollMetrics {
            let dx = offset.x - metrics.previousOffset.x
            let dy = offset.y - metrics.previousOffset.y
            if abs(dy) >= abs(dx) {
                metrics.distance = dy
                metrics.direction = dy > 0 ? .down : (dy < 0 ? .up : .none)
            } else {
                metrics.distance = dx
                metrics.direction = dx > 0 ? .right : .left
            }
            metrics.previousOffset = offset
        } else {
            let metrics = CYLScrollMetrics()
            metrics.previousOffset = offset
            objc_setAssociatedObject(self, CYLScrollExtensionKey.metrics, metrics, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /**
     * [EN] The signed change of the last `cylUpdateScrollMetrics` sample along its larger axis, in points; 0 before the
     *      second sample.
     * [CN] 最近一次 `cylUpdateScrollMetrics` 采样在变化较大的轴上的有符号变化量（点）；第二次采样前为 0。
     */
    @objc(cyl_scrollDistance) public dynamic var cylScrollDistance: CGFloat {
        cylScrollMetrics?.distance ?? 0
    }

    /**
     * [EN] The direction of the last `cylUpdateScrollMetrics` sample; `CYLScrollDirectionNone` before the second sample.
     * [CN] 最近一次 `cylUpdateScrollMetrics` 采样的方向；第二次采样前为 `CYLScrollDirectionNone`。
     */
    @objc(cyl_scrollDirection) public dynamic var cylScrollDirection: CYLScrollDirection {
        cylScrollMetrics?.direction ?? .none
    }

    private var cylScrollMetrics: CYLScrollMetrics? {
        objc_getAssociatedObject(self, CYLScrollExtensionKey.metrics) as? CYLScrollMetrics
    }
}
