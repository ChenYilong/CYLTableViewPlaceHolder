//
//  CYLRefreshDrivenLayout.swift
//  CYLRefresh
//

// [EN] The driven mode of the refresh kernel, as Android's `CYLRefreshDrivenLayout` (docs/Refresh-Library-Parity.md, native
//      bridge map): a view whose pull is fed from outside. A host that owns the scrolling and the touches (Flutter's
//      `ListView`, React Native) feeds it the pull distance with `drive(offset:dragging:startedAtEdge:)` and the lifted
//      finger with `release()`; the attached header runs the same phase machine as under a finger. It holds a scroll view
//      of its own, with no content, whose `isDragging` is the driven flag; the header reads that scroll view as it reads
//      any other. The footer is driven too, as on Android: a negative offset pulls it up from the bottom edge.
// [CN] 刷新内核的驱动模式，对应 Android 的 `CYLRefreshDrivenLayout`（docs/Refresh-Library-Parity.md，原生桥接表）：下拉由外部输入的视图。
//      自己掌管滚动与触摸的宿主（Flutter 的 `ListView`、React Native）通过 `drive(offset:dragging:startedAtEdge:)` 输入下拉距离，
//      通过 `release()` 输入手指抬起；挂上的刷新头运行与手指下拉时相同的阶段机。它持有一个没有内容的自有滚动视图，其 `isDragging`
//      就是驱动标志；刷新头读取它的方式与读取其他滚动视图相同。与 Android 一样也驱动刷新尾：负数偏移从底部边缘上拉刷新尾。

import UIKit

// [EN] A scroll view that reports the dragging the host feeds. [CN] 报告宿主输入的拖动状态的滚动视图。
private final class CYLRefreshDrivenScrollView: UIScrollView {
    var drivenDragging = false
    override var isDragging: Bool { drivenDragging }
}

/**
 * [EN] A view with no scrolling content whose refresh header and footer are driven from outside: the host calls
 *      `drive(offset:dragging:startedAtEdge:)` and `release()`, and they draw and report their phases as under a finger.
 * [CN] 没有滚动内容的视图，其刷新头与刷新尾由外部驱动：宿主调用 `drive(offset:dragging:startedAtEdge:)` 与 `release()`，
 *      它们像被手指拉动时一样绘制并报告阶段。
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

    // [EN] The scroll view has no content, so its content size never changes and the footer is never placed below the
    //      visible area (the footer places itself on a content size change): place it whenever the layout is sized, as a
    //      host that resizes the view (Flutter's footer slot grows with the pull) needs.
    // [CN] 滚动视图没有内容，内容尺寸从不变化，刷新尾因此从未被放到可见区域下方（刷新尾在内容尺寸变化时自行定位）：
    //      每次布局时重新定位，宿主会改变视图大小（Flutter 的刷新尾槽位随下拉变大）。
    open override func layoutSubviews() {
        super.layoutSubviews()
        footer?.scrollViewContentSizeDidChange(nil)
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
     * [EN] The attached refresh footer (`cyl_footer`); nil removes it. Android: `cyl_footer`.
     * [CN] 挂上的刷新尾（`cyl_footer`）；nil 表示移除。对应 Android 的 `cyl_footer`。
     */
    @objc open var footer: CYLRefreshFooter? {
        get { drivenScrollView.cyl_footer }
        set { drivenScrollView.cyl_footer = newValue }
    }

    // [EN] Whether the last fed offset pulled the footer (negative), for the release. [CN] 最近一次输入的偏移是否在上拉刷新尾（负数），供抬起时使用。
    private var footerPulled = false

    /**
     * [EN] Feeds the pull: `offset` points past the edge (positive pulls the header, negative pulls the footer from the
     *      bottom edge, 0 is rest); `dragging` says whether a finger holds the content; `startedAtEdge` whether the drag
     *      began at the edge, which a header or back footer with `CYLRefreshTriggerMode.onEdge` requires. With
     *      `loadsAfterNoMoreData` on, a pull up clears "no more data" first.
     * [CN] 输入拉动：`offset` 为越过边缘的点数（正数下拉刷新头，负数从底部边缘上拉刷新尾，0 为静止）；`dragging` 表示是否有手指按住内容；
     *      `startedAtEdge` 表示拖动是否从边缘开始，`CYLRefreshTriggerMode.onEdge` 的刷新头或回弹刷新尾要求为 true。
     *      `loadsAfterNoMoreData` 打开时，上拉先清除“无更多数据”。
     */
    @objc(driveWithOffset:dragging:startedAtEdge:)
    open func drive(offset: CGFloat, dragging: Bool, startedAtEdge: Bool = true) {
        if dragging && !drivenScrollView.drivenDragging {
            header?.dragStartedAtEdge = startedAtEdge
            (footer as? CYLRefreshBackFooter)?.dragStartedAtEdge = startedAtEdge
            (footer as? CYLRefreshAutoFooter)?.cyl_drivenDragBegan()
        }
        // [EN] As Android's `drive`: a pull up clears "no more data" when `loadsAfterNoMoreData` is on.
        // [CN] 与 Android 的 `drive` 相同：`loadsAfterNoMoreData` 打开时，上拉清除“无更多数据”。
        if dragging && offset < 0, let footer = footer, footer.loadsAfterNoMoreData, footer.isNoMoreData {
            footer.resetNoMoreData()
        }
        footerPulled = offset < 0
        drivenScrollView.drivenDragging = dragging
        drivenScrollView.contentOffset = CGPoint(x: 0, y: -offset)
    }

    /**
     * [EN] Feeds the lifted finger: an armed header or footer starts refreshing, a short pull is canceled; an automatic
     *      footer loads when the pull was at the bottom. Swift `release()` as on Android; the Objective-C selector is
     *      `releaseDrivenPull`, since `release` is NSObject's own selector.
     * [CN] 输入手指抬起：已就绪的刷新头或刷新尾开始刷新，拉动不足则取消；自动刷新尾在底部被上拉后加载。Swift 中为 `release()`，与
     *      Android 相同；Objective-C 的 selector 是 `releaseDrivenPull`，因为 `release` 是 NSObject 自己的 selector。
     */
    @objc(releaseDrivenPull)
    open func release() {
        drivenScrollView.drivenDragging = false
        header?.scrollViewContentOffsetDidChange(nil)
        footer?.scrollViewContentOffsetDidChange(nil)
        if footerPulled { (footer as? CYLRefreshAutoFooter)?.cyl_drivenReleased() }
    }
}
