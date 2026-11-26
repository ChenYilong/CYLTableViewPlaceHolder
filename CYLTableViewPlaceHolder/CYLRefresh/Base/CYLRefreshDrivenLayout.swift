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
        // [EN] The content is as tall as the view, so an automatic footer (it follows the content) also rests at the bottom edge,
        //      as a back footer does, and a pull scrolls it into view instead of past the top.
        // [CN] 内容与视图等高，自动刷新尾（跟随内容）也和回弹刷新尾一样停在底部边缘，上拉时滚入视野，而不是滚到顶部之外。
        let contentSize = CGSize(width: bounds.width, height: bounds.height)
        if drivenScrollView.contentSize != contentSize { drivenScrollView.contentSize = contentSize }
        footer?.scrollViewContentSizeDidChange(nil)
        applyDrivenOffset()
    }

    /**
     * [EN] The attached refresh header (`cylHeader`); nil removes it. Android: `cylHeader`.
     * [CN] 挂上的刷新头（`cylHeader`）；nil 表示移除。对应 Android 的 `cylHeader`。
     */
    @objc open var header: CYLRefreshHeader? {
        get { drivenScrollView.cylHeader }
        set { drivenScrollView.cylHeader = newValue; forwardSecondaryBlocks() }
    }

    /**
     * [EN] The attached refresh footer (`cylFooter`); nil removes it. Android: `cylFooter`.
     * [CN] 挂上的刷新尾（`cylFooter`）；nil 表示移除。对应 Android 的 `cylFooter`。
     */
    @objc open var footer: CYLRefreshFooter? {
        get { drivenScrollView.cylFooter }
        set { drivenScrollView.cylFooter = newValue; forwardSecondaryBlocks() }
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
            (footer as? CYLRefreshAutoFooter)?.drivenDragBegan()
        }
        // [EN] As Android's `drive`: a pull up clears "no more data" when `loadsAfterNoMoreData` is on.
        // [CN] 与 Android 的 `drive` 相同：`loadsAfterNoMoreData` 打开时，上拉清除“无更多数据”。
        if dragging && offset < 0, let footer = footer, footer.loadsAfterNoMoreData, footer.isNoMoreData {
            footer.resetNoMoreData()
        }
        footerPulled = offset < 0
        drivenScrollView.drivenDragging = dragging
        drivenOffset = offset
        applyDrivenOffset()
    }

    // [EN] The last fed offset. [CN] 最近一次输入的偏移。
    private var drivenOffset: CGFloat = 0

    // [EN] Scrolls the content: the fed pull, but never less than the footer's own height while it shows "no more data",
    //      since a footer rests below the visible area and only a scrolled view shows it (a real scroll view at its end
    //      is scrolled that far by the content).
    // [CN] 滚动内容：输入的下拉量；刷新尾显示“无更多数据”时至少滚动刷新尾自身的高度，因为刷新尾停在可见区域之下，
    //      只有滚动后才看得到（真实滚动视图在底部时由内容滚到那里）。
    func applyDrivenOffset() {
        var pulled = -drivenOffset
        if let footer = footer, footer.isNoMoreData { pulled = max(pulled, footer.cylH) }
        // [EN] An open second floor holds the content scrolled by the floor's extent (a header floor above the content, a
        //      footer floor below it), whatever pull is fed: the floor's own opening animation ends there.
        // [CN] 打开的二楼让内容保持滚动二楼的高度（刷新头的二楼在内容上方，刷新尾的二楼在内容下方），无论输入的拉动是多少：
        //      二楼自己的打开动画也停在那里。
        if let side = secondaryHolder, side.open, side.phase != .secondaryClosing {
            pulled = side.header ? min(pulled, -secondaryExtent) : max(pulled, secondaryExtent)
        }
        drivenScrollView.contentOffset = CGPoint(x: 0, y: pulled)
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
        if footerPulled { (footer as? CYLRefreshAutoFooter)?.drivenReleased() }
    }

    // MARK: - Second floor

    // [EN] The component that holds the second floor: the header, else a back footer (the only footer with one). `header`
    //      says which. [CN] 持有二楼的组件：刷新头，否则是回弹刷新尾（唯一有二楼的刷新尾）；`header` 表示是哪一个。
    private var secondaryHolder: (open: Bool, phase: CYLRefreshPhase, header: Bool)? {
        if let header = header { return (header.isSecondaryOpen, header.phase, true) }
        if let footer = footer as? CYLRefreshBackFooter { return (footer.isSecondaryOpen, footer.phase, false) }
        return nil
    }

    // [EN] The open extent of the floor: its dimension, else this view's height (the host sizes the view to the floor). [CN] 二楼打开后的高度：
    //      其 dimension，否则为本视图高度（宿主把视图设为二楼大小）。
    private var secondaryExtent: CGFloat {
        let dimension = header?.secondaryDimension ?? (footer as? CYLRefreshBackFooter)?.secondaryDimension ?? 0
        return dimension > 0 ? dimension : bounds.height
    }

    /**
     * [EN] Turns the second floor on for the attached header (or back footer): pulling `triggerOffset` points (and releasing)
     *      opens it instead of refreshing; `triggerOffset` 0 turns it off. `dimension` is its open extent (0: this view's
     *      height) and `closeTriggerOffset` how far pushing back closes it (the native default stays when 0). Call it after
     *      setting `header` / `footer`. The floor's content is the host's (`secondaryView` of the header is not used here:
     *      Flutter draws it in Dart). Android: `secondaryTriggerOffset`, `secondaryDimension`, `secondaryCloseTriggerOffset`.
     * [CN] 为挂上的刷新头（或回弹刷新尾）开启二楼：拉动 `triggerOffset` 点后松手即打开二楼而不是刷新；`triggerOffset` 为 0 表示关闭。
     *      `dimension` 为打开后的高度（0：本视图高度），`closeTriggerOffset` 为推回多远即关闭（为 0 时保持原生默认值）。
     *      请在设置 `header` / `footer` 之后调用。二楼内容归宿主所有（此处不使用刷新头的 `secondaryView`：Flutter 在 Dart 里绘制）。
     *      对应 Android 的 `secondaryTriggerOffset`、`secondaryDimension`、`secondaryCloseTriggerOffset`。
     */
    @objc(configureSecondaryWithTriggerOffset:dimension:closeTriggerOffset:)
    open func configureSecondary(triggerOffset: CGFloat, dimension: CGFloat = 0, closeTriggerOffset: CGFloat = 0) {
        if let header = header {
            header.secondaryTriggerOffset = max(0, triggerOffset)
            header.secondaryDimension = max(0, dimension)
            if closeTriggerOffset > 0 { header.secondaryCloseTriggerOffset = closeTriggerOffset }
        } else if let footer = footer as? CYLRefreshBackFooter {
            footer.secondaryTriggerOffset = max(0, triggerOffset)
            footer.secondaryDimension = max(0, dimension)
            if closeTriggerOffset > 0 { footer.secondaryCloseTriggerOffset = closeTriggerOffset }
        }
    }

    /**
     * [EN] YES while the second floor is open. Android: `floor`. [CN] 二楼打开时为 YES。对应 Android 的 `floor`。
     */
    @objc open var isSecondaryOpen: Bool { secondaryHolder?.open == true }

    /**
     * [EN] Opens the second floor; nothing while it is open or the component is refreshing. [CN] 打开二楼；已打开或正在刷新时不做任何事。
     */
    @objc open func openSecondary() {
        if let header = header { header.openSecondary() } else { (footer as? CYLRefreshBackFooter)?.openSecondary() }
        applyDrivenOffset()
    }

    /**
     * [EN] Closes the second floor; nothing unless it is open. [CN] 关闭二楼；未打开时不做任何事。
     */
    @objc open func closeSecondary() {
        if let header = header { header.closeSecondary() } else { (footer as? CYLRefreshBackFooter)?.closeSecondary() }
    }

    /**
     * [EN] Called after the second floor opened. [CN] 二楼打开后调用。
     */
    @objc open var secondaryOpenedBlock: (() -> Void)? {
        didSet { forwardSecondaryBlocks() }
    }

    /**
     * [EN] Called after the second floor closed. [CN] 二楼关闭后调用。
     */
    @objc open var secondaryClosedBlock: (() -> Void)? {
        didSet { forwardSecondaryBlocks() }
    }

    // [EN] Hands the two blocks to the attached component; the blocks are read when the floor finishes, so the layout's
    //      current blocks are used. Set again after `header` / `footer` changes. [CN] 把两个 block 交给挂上的组件；
    //      二楼完成时才读取，所以使用布局当前的 block。`header` / `footer` 变化后需再次设置。
    private func forwardSecondaryBlocks() {
        let opened: CYLRefreshComponentAction = { [weak self] in self?.secondaryOpenedBlock?() }
        let closed: CYLRefreshComponentAction = { [weak self] in self?.secondaryClosedBlock?() }
        header?.secondaryOpenedBlock = opened
        header?.secondaryClosedBlock = closed
        (footer as? CYLRefreshBackFooter)?.secondaryOpenedBlock = opened
        (footer as? CYLRefreshBackFooter)?.secondaryClosedBlock = closed
    }
}
