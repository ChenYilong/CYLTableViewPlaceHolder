//
//  CYLRefreshDrivenLayout.swift
//  CYLRefresh
//

// [EN] The driven mode of the refresh kernel, as Android's `CYLRefreshDrivenLayout` (docs/Refresh-Library-Parity.md, native
//      bridge map): a view whose pull is fed from outside. A host that owns the scrolling and the touches (Flutter's
//      `ListView`, React Native) feeds it the pull distance with `drive(offset:dragging:startedAtEdge:)` and the lifted
//      finger with `release()`; the attached header runs the same phase machine as under a finger. It holds a scroll view
//      of its own, with no content, whose `isDragging` is the driven flag; the header reads that scroll view as it reads
//      any other. Only the header is driven: a negative offset (the footer) is treated as rest.
// [CN] 刷新内核的驱动模式，对应 Android 的 `CYLRefreshDrivenLayout`（docs/Refresh-Library-Parity.md，原生桥接表）：下拉由外部输入的视图。
//      自己掌管滚动与触摸的宿主（Flutter 的 `ListView`、React Native）通过 `drive(offset:dragging:startedAtEdge:)` 输入下拉距离，
//      通过 `release()` 输入手指抬起；挂上的刷新头运行与手指下拉时相同的阶段机。它持有一个没有内容的自有滚动视图，其 `isDragging`
//      就是驱动标志；刷新头读取它的方式与读取其他滚动视图相同。只驱动刷新头：负数偏移（刷新尾）按静止处理。

import UIKit

// [EN] A scroll view that reports the dragging the host feeds. [CN] 报告宿主输入的拖动状态的滚动视图。
private final class CYLRefreshDrivenScrollView: UIScrollView {
    var drivenDragging = false
    override var isDragging: Bool { drivenDragging }
}

/**
 * [EN] A view with no scrolling content whose refresh header is driven from outside: the host calls
 *      `drive(offset:dragging:startedAtEdge:)` and `release()`, and the header draws and reports its phases as under a finger.
 * [CN] 没有滚动内容的视图，其刷新头由外部驱动：宿主调用 `drive(offset:dragging:startedAtEdge:)` 与 `release()`，
 *      刷新头像被手指下拉时一样绘制并报告阶段。
 */
@objc(CYLRefreshDrivenLayout)
open class CYLRefreshDrivenLayout: UIView {

    private let drivenScrollView = CYLRefreshDrivenScrollView()

    /**
     * [EN] A layout of this frame. [CN] 使用该 frame 的布局视图。
     */
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    /**
     * [EN] Made from a nib or storyboard. [CN] 从 nib 或 storyboard 创建。
     */
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    private func setUp() {
        drivenScrollView.frame = bounds
        drivenScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        drivenScrollView.alwaysBounceVertical = true
        drivenScrollView.isScrollEnabled = false
        drivenScrollView.contentInsetAdjustmentBehavior = .never
        addSubview(drivenScrollView)
    }

    /**
     * [EN] The attached refresh header (`cyl_header`); nil removes it. Android: `cyl_header`.
     * [CN] 挂上的刷新头（`cyl_header`）；nil 表示移除。对应 Android 的 `cyl_header`。
     */
    @objc open var header: CYLRefreshHeader? {
        get { drivenScrollView.cyl_header }
        set { drivenScrollView.cyl_header = newValue }
    }

    /**
     * [EN] Feeds the pull: `offset` points past the edge (positive pulls the header, 0 is rest, a negative offset is
     *      treated as rest); `dragging` says whether a finger holds the content; `startedAtEdge` whether the drag began at
     *      the edge, which a header with `CYLRefreshTriggerMode.onEdge` requires.
     * [CN] 输入下拉：`offset` 为越过边缘的点数（正数下拉刷新头，0 为静止，负数按静止处理）；`dragging` 表示是否有手指按住内容；
     *      `startedAtEdge` 表示拖动是否从边缘开始，`CYLRefreshTriggerMode.onEdge` 的刷新头要求为 true。
     */
    @objc(driveWithOffset:dragging:startedAtEdge:)
    open func drive(offset: CGFloat, dragging: Bool, startedAtEdge: Bool = true) {
        let pull = max(0, offset)
        if dragging && !drivenScrollView.drivenDragging { header?.dragStartedAtEdge = startedAtEdge }
        drivenScrollView.drivenDragging = dragging
        drivenScrollView.contentOffset = CGPoint(x: 0, y: -pull)
    }

    /**
     * [EN] Feeds the lifted finger: an armed header starts refreshing, a short pull is canceled.
     *      Swift `release()` as on Android; the Objective-C selector is `releaseDrivenPull`, since `release` is NSObject's own
     *      selector.
     * [CN] 输入手指抬起：已就绪的刷新头开始刷新，下拉不足则取消。Swift 中为 `release()`，与 Android 相同；Objective-C 的 selector 是
     *      `releaseDrivenPull`，因为 `release` 是 NSObject 自己的 selector。
     */
    @objc(releaseDrivenPull)
    open func release() {
        drivenScrollView.drivenDragging = false
        header?.scrollViewContentOffsetDidChange(nil)
    }
}
