//
//  UIScrollView+CYLPlaceholder.swift
//  CYLTableViewPlaceHolder
//
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//

// [EN] The automatic placeholder (`cyl_placeholderViewBlock:` for UITableView and UICollectionView), the keyboard tracker
//      that keeps placeholders above the keyboard, and `UIScrollView (CYLPlaceholderVisibility)`. Swift since 2026-11-19
//      with the same Objective-C API (selectors, the swizzled `cyl_ph_*` selectors). What Swift cannot express stays in
//      `UIScrollView+CYLPlaceholderSupport.m` (docs/Swift-Migration.md, rule 6): `+load`, which calls
//      `cylPlaceholderInstallAutomaticPlaceholder(exceptionGuard:)` below, and the `@try` / `@finally` that keeps the batch depth
//      right when a batch update throws an Objective-C exception. The block types stay in the public headers.
// [CN] 自动占位图（UITableView 与 UICollectionView 的 `cyl_placeholderViewBlock:`）、让占位图保持在键盘上方的键盘跟踪，以及
//      `UIScrollView (CYLPlaceholderVisibility)`。自 2026-11-19 起用 Swift 编写，Objective-C API 不变（选择器、被交换的 `cyl_ph_*` 选择器）。
//      Swift 无法表达的部分保留在 `UIScrollView+CYLPlaceholderSupport.m` 中（docs/Swift-Migration.md 第 6 条）：`+load`（调用下面的
//      `cylPlaceholderInstallAutomaticPlaceholder(exceptionGuard:)`），以及批量更新抛出 Objective-C 异常时保证批量深度正确的 `@try` / `@finally`。
//      block 类型保留在公开头文件中。

import UIKit
import ObjectiveC

// [EN] Runs the first block, then the second even when the first throws an Objective-C exception (`@try` / `@finally` in
//      `UIScrollView+CYLPlaceholderSupport.m`; Swift cannot catch Objective-C exceptions).
// [CN] 执行第一个 block，然后执行第二个，即使第一个抛出 Objective-C 异常（`UIScrollView+CYLPlaceholderSupport.m` 中的 `@try` /
//      `@finally`；Swift 无法捕获 Objective-C 异常）。
typealias CYLPlaceholderExceptionGuard =
    @convention(block) (@escaping @convention(block) () -> Void, @escaping @convention(block) () -> Void) -> Void

// [EN] The associated-object keys: stable addresses for the process's lifetime. [CN] 关联对象的 key：进程内地址固定。
private enum CYLPlaceholderKey {
    static let controller = UnsafeRawPointer(UnsafeMutablePointer<UInt8>.allocate(capacity: 1))
    static let hidden = UnsafeRawPointer(UnsafeMutablePointer<UInt8>.allocate(capacity: 1))
}

// MARK: - Visible area (top bar, home indicator, keyboard)

// [EN] The keyboard tracker, shared by both placeholder paths (`cyl_placeholderViewBlock:` and the legacy `cylReloadData`).
// [CN] 键盘跟踪，两条占位图路径（`cyl_placeholderViewBlock:` 与旧的 `cylReloadData`）共用。
enum CYLPlaceholderVisibleArea {

    // [EN] Posted after the keyboard's frame changes, so shown placeholders frame themselves above it again.
    // [CN] 键盘 frame 变化后发出，已显示的占位图据此重新放在键盘上方。
    static let didChangeNotification = Notification.Name("CYLPlaceholderVisibleAreaDidChangeNotification")

    // [EN] The keyboard's frame in screen coordinates, `.null` while it is hidden; read and written on the main thread.
    // [CN] 键盘在屏幕坐标中的 frame，隐藏时为 `.null`；在主线程读写。
    private static var keyboardScreenFrame = CGRect.null

    // [EN] Created once (a `static let` runs its initializer once, as `dispatch_once` did).
    // [CN] 只创建一次（`static let` 的初始化只执行一次，与 `dispatch_once` 相同）。
    private static let keyboardObservers: Void = {
        let center = NotificationCenter.default
        center.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: nil) { note in
            let end = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
            keyboardScreenFrame = end?.cgRectValue ?? .null
            NotificationCenter.default.post(name: didChangeNotification, object: nil)
        }
        center.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { _ in
            keyboardScreenFrame = .null
            NotificationCenter.default.post(name: didChangeNotification, object: nil)
        }
    }()

    // [EN] Starts tracking the keyboard's frame once; also started from `+load`, so a placeholder that first appears while
    //      the keyboard is already up (a search with no results) knows where it is (CYLSearchViewController's report).
    // [CN] 开始跟踪键盘 frame，只执行一次；`+load` 中也会启动，使在键盘已显示时才首次出现的占位图（无结果的搜索）也知道键盘位置
    //      （CYLSearchViewController 报告）。
    static func startTrackingKeyboard() {
        _ = keyboardObservers
    }

    // [EN] How much of the scroll view a placeholder leaves free: at the bottom, the part the keyboard covers, so the
    //      placeholder is centered above the keyboard (reported by CYLSearchViewController: "No results found" sat under
    //      the keyboard). The top and the bottom inset keep the placement they always had.
    // [CN] 占位图在滚动视图中留出的距离：底部为键盘遮住的部分，使占位图在键盘上方居中（CYLSearchViewController 报告：“No results
    //      found” 被键盘遮住）。顶部与底部内边距保持原有的位置。
    static func insets(for scrollView: UIScrollView) -> UIEdgeInsets {
        let height = scrollView.bounds.height
        var bottom: CGFloat = 0
        if let window = scrollView.window, !keyboardScreenFrame.isNull, !keyboardScreenFrame.isEmpty {
            let keyboard = window.convert(keyboardScreenFrame, from: window.screen.coordinateSpace)
            let visible = scrollView.convert(scrollView.bounds, to: nil)
            if keyboard.minX < visible.maxX && keyboard.maxX > visible.minX {
                bottom = max(0, visible.maxY - keyboard.minY)
            }
        }
        // [EN] Never less than a third of the height for the placeholder. [CN] 至少给占位图留下三分之一的高度。
        bottom = min(bottom, height * 2 / 3)
        return UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
    }
}

// MARK: - Controller

// [EN] One per scroll view that uses the automatic placeholder: schedules the check on the main queue, counts batch
//      updates, and shows the provider's view pinned to the frame layout guide.
// [CN] 每个使用自动占位图的滚动视图一个：在主队列安排检查，统计批量更新，并把提供者的视图固定到 frame 布局参考上显示。
final class CYLPlaceholderController: NSObject {

    typealias Provider = (UIScrollView) -> UIView?
    typealias Restore = (UIScrollView) -> Void

    weak var scrollView: UIScrollView?
    var provider: Provider?
    var restore: Restore?
    var view: UIView?
    var constraints: [NSLayoutConstraint] = []
    var batchDepth = 0
    var batchCallDepth = 0
    var scheduled = false
    var generation = 0
    // [EN] The footers and trailers this controller hid while the placeholder shows (shown again when it goes).
    // [CN] 占位图显示期间由本控制器隐藏的刷新尾与 trailer（占位图移除时重新显示）。
    private let hiddenLoadMoreControls = NSHashTable<UIView>.weakObjects()

    // [EN] Set from `+load` (`UIScrollView+CYLPlaceholderSupport.m`). [CN] 由 `+load` 设置（`UIScrollView+CYLPlaceholderSupport.m`）。
    static var exceptionGuard: CYLPlaceholderExceptionGuard?

    override init() {
        super.init()
        CYLPlaceholderVisibleArea.startTrackingKeyboard()
        NotificationCenter.default.addObserver(forName: CYLPlaceholderVisibleArea.didChangeNotification, object: nil,
                                               queue: nil) { [weak self] _ in
            self?.updateVisibleArea()
        }
    }

    static func controller(for scrollView: UIScrollView) -> CYLPlaceholderController? {
        objc_getAssociatedObject(scrollView, CYLPlaceholderKey.controller) as? CYLPlaceholderController
    }

    // [EN] Whether the scroll view uses the automatic placeholder (the legacy `cylReloadData` then leaves it alone).
    // [CN] 滚动视图是否使用自动占位图（此时旧的 `cylReloadData` 不再处理它）。
    static func isEnabled(for scrollView: UIScrollView) -> Bool {
        controller(for: scrollView)?.provider != nil
    }

    // [EN] Runs `body`, then `cleanup` even when `body` throws an Objective-C exception (the guard from `+load`).
    // [CN] 执行 `body`，即使其抛出 Objective-C 异常也执行 `cleanup`（使用 `+load` 传入的 guard）。
    static func perform(_ body: @escaping () -> Void, finally cleanup: @escaping () -> Void) {
        if let exceptionGuard = exceptionGuard {
            let bodyBlock: @convention(block) () -> Void = body
            let cleanupBlock: @convention(block) () -> Void = cleanup
            exceptionGuard(bodyBlock, cleanupBlock)
        } else {
            body()
            cleanup()
        }
    }

    // [EN] Brings the placeholder to the front, then keeps refresh controls above it so a header, footer or trailer
    //      stays visible over an empty list (issue #8).
    // [CN] 把占位图移到最前，再让刷新控件位于其上，使空列表上方的 header、footer 或 trailer 仍然可见（issue #8）。
    static func bringPlaceholderToFront(_ placeholder: UIView, in scrollView: UIScrollView) {
        scrollView.bringSubviewToFront(placeholder)
        let refreshClasses = [NSClassFromString("CYLRefreshComponent"), NSClassFromString("MJRefreshComponent")]
            .compactMap { $0 }
        for subview in scrollView.subviews where subview !== placeholder {
            if refreshClasses.contains(where: { subview.isKind(of: $0) }) {
                scrollView.bringSubviewToFront(subview)
            }
        }
    }

    // [EN] Installs, replaces or (with a nil provider) turns off the placeholder of a scroll view.
    // [CN] 为滚动视图安装、替换或（提供者为 nil 时）关闭占位图。
    static func install(on scrollView: UIScrollView, provider: Provider?, restore: Restore?) {
        assert(Thread.isMainThread, "Placeholder configuration must run on the main thread.")
        var existing = controller(for: scrollView)
        if existing == nil && provider == nil { return }
        if existing == nil {
            let created = CYLPlaceholderController()
            created.scrollView = scrollView
            objc_setAssociatedObject(scrollView, CYLPlaceholderKey.controller, created, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            existing = created
        }
        guard let controller = existing else { return }
        controller.generation += 1
        let generation = controller.generation
        controller.removeView()
        if controller.generation != generation { return }
        controller.provider = provider
        controller.restore = restore
        controller.scheduleUpdate()
    }

    // [EN] Keeps the placeholder above the keyboard. [CN] 让占位图保持在键盘上方。
    func updateVisibleArea() {
        guard view != nil, let scrollView = scrollView, constraints.count >= 4 else { return }
        let insets = CYLPlaceholderVisibleArea.insets(for: scrollView)
        constraints[2].constant = insets.top
        constraints[3].constant = -insets.bottom
    }

    // [EN] The load-more controls (footers and trailers of CYLRefresh or MJRefresh): an empty list has nothing more to
    //      load, and with a zero content size a footer would sit at the top, over the placeholder. Headers stay (issue #8).
    // [CN] 加载更多类控件（CYLRefresh 或 MJRefresh 的刷新尾与 trailer）：空列表没有更多可加载；内容高度为 0 时刷新尾会
    //      跑到顶部、压在占位图上。刷新头保留（issue #8）。
    private static let loadMoreClasses: [AnyClass] =
        ["CYLRefreshFooter", "CYLRefreshTrailer", "MJRefreshFooter", "MJRefreshTrailer"].compactMap { NSClassFromString($0) }

    static func isLoadMoreControl(_ view: UIView) -> Bool {
        loadMoreClasses.contains { view.isKind(of: $0) }
    }

    // [EN] Hides every visible load-more control of `scrollView` and records it in `hidden` (the legacy
    //      `cylReloadData` placeholder uses it too).
    // [CN] 隐藏 `scrollView` 中所有可见的加载更多控件并记入 `hidden`（旧的 `cylReloadData` 占位图也使用）。
    static func hideLoadMoreControls(of scrollView: UIScrollView, recordingIn hidden: NSHashTable<UIView>) {
        for subview in scrollView.subviews where !subview.isHidden && isLoadMoreControl(subview) {
            subview.isHidden = true
            hidden.add(subview)
        }
    }

    // [EN] Shows again the controls recorded in `hidden` that are still in `scrollView`, then forgets them.
    // [CN] 重新显示 `hidden` 中仍在 `scrollView` 里的控件，然后清空记录。
    static func restoreLoadMoreControls(of scrollView: UIScrollView?, recordedIn hidden: NSHashTable<UIView>) {
        for control in hidden.allObjects where control.superview === scrollView {
            control.isHidden = false
        }
        hidden.removeAllObjects()
    }

    func hideLoadMoreControls() {
        guard let scrollView = scrollView else { return }
        CYLPlaceholderController.hideLoadMoreControls(of: scrollView, recordingIn: hiddenLoadMoreControls)
    }

    func restoreLoadMoreControls() {
        CYLPlaceholderController.restoreLoadMoreControls(of: scrollView, recordedIn: hiddenLoadMoreControls)
    }

    func removeView() {
        guard let shown = view else { return }
        restoreLoadMoreControls()
        NSLayoutConstraint.deactivate(constraints)
        constraints = []
        shown.removeFromSuperview()
        view = nil
        if let restore = restore, let scrollView = scrollView { restore(scrollView) }
    }

    private func isEmpty() -> Bool {
        if let table = scrollView as? UITableView {
            guard let source = table.dataSource else { return false }
            let sections = source.numberOfSections?(in: table) ?? 1
            for section in 0..<max(sections, 0) where source.tableView(table, numberOfRowsInSection: section) > 0 {
                return false
            }
            return true
        }
        guard let collection = scrollView as? UICollectionView, let source = collection.dataSource else { return false }
        let sections = source.numberOfSections?(in: collection) ?? 1
        for section in 0..<max(sections, 0) where source.collectionView(collection, numberOfItemsInSection: section) > 0 {
            return false
        }
        return true
    }

    func scheduleUpdate() {
        if provider == nil || scheduled || batchDepth > 0 { return }
        scheduled = true
        DispatchQueue.main.async { [weak self] in
            guard let controller = self else { return }
            controller.scheduled = false
            guard let provider = controller.provider, let scrollView = controller.scrollView,
                  controller.batchDepth == 0 else { return }
            // [EN] `cylPlaceholderHidden` (set by `cylStatusDisplay`) keeps it away even for an empty list.
            // [CN] `cylPlaceholderHidden`（由 `cylStatusDisplay` 设置）使空列表也不显示占位图。
            if !controller.isEmpty() || scrollView.cylPlaceholderHidden {
                controller.removeView()
                return
            }
            let generation = controller.generation
            let made = provider(scrollView)
            if generation != controller.generation || controller.provider == nil { return }
            guard let view = made, view !== scrollView, !scrollView.isDescendant(of: view) else {
                NSLog("CYLTableViewPlaceHolder: placeholder block must return a valid view.")
                controller.removeView()
                return
            }
            if view !== controller.view {
                NSLayoutConstraint.deactivate(controller.constraints)
                controller.view?.removeFromSuperview()
                controller.view = view
                view.translatesAutoresizingMaskIntoConstraints = false
                scrollView.addSubview(view)
                let frame = scrollView.frameLayoutGuide
                controller.constraints = [
                    view.leadingAnchor.constraint(equalTo: frame.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: frame.trailingAnchor),
                    view.topAnchor.constraint(equalTo: frame.topAnchor),
                    view.bottomAnchor.constraint(equalTo: frame.bottomAnchor)
                ]
                NSLayoutConstraint.activate(controller.constraints)
            }
            controller.updateVisibleArea()
            CYLPlaceholderController.bringPlaceholderToFront(view, in: scrollView)
            controller.hideLoadMoreControls()
        }
    }
}

// MARK: - Installation (called from +load)

// [EN] Exchanges each original with its replacement; adds the replacement as the original when only a superclass had it.
// [CN] 交换原方法与替换方法；原方法只在父类中实现时，把替换实现添加为原方法。
private func cylPlaceholderSwizzle(_ cls: AnyClass, _ pairs: [(original: Selector, replacement: Selector)]) {
    for pair in pairs {
        guard let oldMethod = class_getInstanceMethod(cls, pair.original),
              let newMethod = class_getInstanceMethod(cls, pair.replacement) else { continue }
        if class_addMethod(cls, pair.original, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)) {
            class_replaceMethod(cls, pair.replacement, method_getImplementation(oldMethod), method_getTypeEncoding(oldMethod))
        } else {
            method_exchangeImplementations(oldMethod, newMethod)
        }
    }
}

extension UIScrollView {

    // [EN] Swizzles both classes once (a `static let` runs its initializer once, as `dispatch_once` did).
    // [CN] 两个类只交换一次（`static let` 的初始化只执行一次，与 `dispatch_once` 相同）。
    private static let cylPlaceholderInstallation: Void = {
        cylPlaceholderSwizzle(UITableView.self, [
            (#selector(UITableView.reloadData), #selector(UITableView.cylPlaceholderReloadData)),
            (#selector(setter: UITableView.dataSource), #selector(UITableView.cylPlaceholderSetDataSource(_:))),
            (#selector(UITableView.beginUpdates), #selector(UITableView.cylPlaceholderBeginUpdates)),
            (#selector(UITableView.endUpdates), #selector(UITableView.cylPlaceholderEndUpdates)),
            (#selector(UITableView.insertSections(_:with:)), #selector(UITableView.cylPlaceholderInsertSections(_:with:))),
            (#selector(UITableView.deleteSections(_:with:)), #selector(UITableView.cylPlaceholderDeleteSections(_:with:))),
            (#selector(UITableView.reloadSections(_:with:)), #selector(UITableView.cylPlaceholderReloadSections(_:with:))),
            (#selector(UITableView.moveSection(_:toSection:)), #selector(UITableView.cylPlaceholderMoveSection(_:toSection:))),
            (#selector(UITableView.insertRows(at:with:)), #selector(UITableView.cylPlaceholderInsertRows(at:with:))),
            (#selector(UITableView.deleteRows(at:with:)), #selector(UITableView.cylPlaceholderDeleteRows(at:with:))),
            (#selector(UITableView.reloadRows(at:with:)), #selector(UITableView.cylPlaceholderReloadRows(at:with:))),
            (#selector(UITableView.moveRow(at:to:)), #selector(UITableView.cylPlaceholderMoveRow(at:to:))),
            (#selector(UITableView.performBatchUpdates(_:completion:)),
             #selector(UITableView.cylPlaceholderPerformBatchUpdates(_:completion:))),
            (NSSelectorFromString("reconfigureRowsAtIndexPaths:"), #selector(UITableView.cylPlaceholderReconfigureRows(at:)))
        ])
        cylPlaceholderSwizzle(UICollectionView.self, [
            (#selector(UICollectionView.reloadData), #selector(UICollectionView.cylPlaceholderReloadData)),
            (#selector(setter: UICollectionView.dataSource), #selector(UICollectionView.cylPlaceholderSetDataSource(_:))),
            (#selector(UICollectionView.insertSections(_:)), #selector(UICollectionView.cylPlaceholderInsertSections(_:))),
            (#selector(UICollectionView.deleteSections(_:)), #selector(UICollectionView.cylPlaceholderDeleteSections(_:))),
            (#selector(UICollectionView.reloadSections(_:)), #selector(UICollectionView.cylPlaceholderReloadSections(_:))),
            (#selector(UICollectionView.moveSection(_:toSection:)),
             #selector(UICollectionView.cylPlaceholderMoveSection(_:toSection:))),
            (#selector(UICollectionView.insertItems(at:)), #selector(UICollectionView.cylPlaceholderInsertItems(at:))),
            (#selector(UICollectionView.deleteItems(at:)), #selector(UICollectionView.cylPlaceholderDeleteItems(at:))),
            (#selector(UICollectionView.reloadItems(at:)), #selector(UICollectionView.cylPlaceholderReloadItems(at:))),
            (#selector(UICollectionView.moveItem(at:to:)), #selector(UICollectionView.cylPlaceholderMoveItem(at:to:))),
            (#selector(UICollectionView.performBatchUpdates(_:completion:)),
             #selector(UICollectionView.cylPlaceholderPerformBatchUpdates(_:completion:))),
            (NSSelectorFromString("reconfigureItemsAtIndexPaths:"),
             #selector(UICollectionView.cylPlaceholderReconfigureItems(at:)))
        ])
    }()

    // [EN] The one entry point of `+load` (`UIScrollView+CYLPlaceholderSupport.m`, which declares this selector): keeps the
    //      exception guard, starts tracking the keyboard, and swizzles UITableView and UICollectionView once.
    // [CN] `+load` 的唯一入口（`UIScrollView+CYLPlaceholderSupport.m` 声明了该选择器）：保存异常 guard，开始跟踪键盘，并只交换一次
    //      UITableView 与 UICollectionView 的方法。
    @objc(cyl_ph_installAutomaticPlaceholderWithExceptionGuard:)
    static func cylPlaceholderInstallAutomaticPlaceholder(exceptionGuard: @escaping CYLPlaceholderExceptionGuard) {
        CYLPlaceholderController.exceptionGuard = exceptionGuard
        CYLPlaceholderVisibleArea.startTrackingKeyboard()
        _ = cylPlaceholderInstallation
    }

    var cylPlaceholderController: CYLPlaceholderController? {
        CYLPlaceholderController.controller(for: self)
    }
}

// MARK: - UITableView

extension UITableView {

    /**
     * [EN] Shows the block's view whenever a reload or update leaves the table view with no rows, and removes it when
     *      content comes back. Pass nil to turn the automatic placeholder off and restore the normal state. The block
     *      should not retain the table view or its owner strongly.
     * [CN] 每当刷新或更新使表格视图没有行时显示 block 返回的视图，有内容后移除。传 nil 关闭自动占位图并恢复正常状态。block 不应强引用
     *      表格视图或其持有者。
     */
    @objc(cyl_placeholderViewBlock:)
    public func cylPlaceholderViewBlock(_ placeholderViewBlock: CYLTablePlaceholderViewBlock?) {
        cylPlaceholderViewBlock(placeholderViewBlock, backToNormalBlock: nil)
    }

    /**
     * [EN] Like `cylPlaceholderViewBlock(_:)`, and also sets the block called when the placeholder is removed (the table
     *      view has content again); nil for both turns the automatic placeholder off.
     * [CN] 与 `cylPlaceholderViewBlock(_:)` 相同，并设置占位图被移除（表格视图重新有内容）时调用的 block；两者都为 nil 时关闭自动占位图。
     */
    @objc(cyl_placeholderViewBlock:backToNormalBlock:)
    public func cylPlaceholderViewBlock(_ placeholderViewBlock: CYLTablePlaceholderViewBlock?,
                                         backToNormalBlock: CYLTablePlaceholderNormalBlock?) {
        if placeholderViewBlock != nil { cylRemoveLegacyPlaceholder() }
        let provider = placeholderViewBlock.map { block in
            { (view: UIScrollView) -> UIView? in block(unsafeDowncast(view, to: UITableView.self)) }
        }
        let restore = backToNormalBlock.map { block in
            { (view: UIScrollView) in block(unsafeDowncast(view, to: UITableView.self)) }
        }
        CYLPlaceholderController.install(on: self, provider: provider, restore: restore)
    }

    // MARK: Replacements (swizzled with the originals; calling one calls the original)

    // [EN] Index sets and index path arrays stay Objective-C objects (`NSIndexSet?`, `NSArray?`), so the original receives
    //      exactly what the caller passed, nil included. [CN] 索引集合与索引路径数组保持为 Objective-C 对象（`NSIndexSet?`、
    //      `NSArray?`），原方法收到的正是调用方传入的值，包括 nil。

    @objc fileprivate dynamic func cylPlaceholderReloadData() {
        cylPlaceholderReloadData()
        cylPlaceholderController?.scheduleUpdate()
    }

    @objc(cyl_ph_setDataSource:)
    fileprivate dynamic func cylPlaceholderSetDataSource(_ source: UITableViewDataSource?) {
        cylPlaceholderSetDataSource(source)
        cylPlaceholderController?.scheduleUpdate()
    }

    @objc fileprivate dynamic func cylPlaceholderBeginUpdates() {
        cylPlaceholderBeginUpdates()
        if let controller = cylPlaceholderController, controller.batchCallDepth == 0 { controller.batchDepth += 1 }
    }

    @objc fileprivate dynamic func cylPlaceholderEndUpdates() {
        cylPlaceholderEndUpdates()
        let controller = cylPlaceholderController
        if let controller = controller, controller.batchCallDepth == 0, controller.batchDepth > 0 {
            controller.batchDepth -= 1
        }
        controller?.scheduleUpdate()
    }

    @objc(cyl_ph_insertSections:withRowAnimation:)
    fileprivate dynamic func cylPlaceholderInsertSections(_ sections: NSIndexSet?, with animation: UITableView.RowAnimation) {
        cylPlaceholderInsertSections(sections, with: animation)
        cylPlaceholderController?.scheduleUpdate()
    }

    @objc(cyl_ph_deleteSections:withRowAnimation:)
    fileprivate dynamic func cylPlaceholderDeleteSections(_ sections: NSIndexSet?, with animation: UITableView.RowAnimation) {
        cylPlaceholderDeleteSections(sections, with: animation)
        cylPlaceholderController?.scheduleUpdate()
    }

    @objc(cyl_ph_reloadSections:withRowAnimation:)
    fileprivate dynamic func cylPlaceholderReloadSections(_ sections: NSIndexSet?, with animation: UITableView.RowAnimation) {
        cylPlaceholderReloadSections(sections, with: animation)
        cylPlaceholderController?.scheduleUpdate()
    }

    @objc(cyl_ph_moveSection:toSection:)
    fileprivate dynamic func cylPlaceholderMoveSection(_ section: Int, toSection newSection: Int) {
        cylPlaceholderMoveSection(section, toSection: newSection)
        cylPlaceholderController?.scheduleUpdate()
    }

    @objc(cyl_ph_insertRowsAtIndexPaths:withRowAnimation:)
    fileprivate dynamic func cylPlaceholderInsertRows(at indexPaths: NSArray?, with animation: UITableView.RowAnimation) {
        cylPlaceholderInsertRows(at: indexPaths, with: animation)
        cylPlaceholderController?.scheduleUpdate()
    }

    @objc(cyl_ph_deleteRowsAtIndexPaths:withRowAnimation:)
    fileprivate dynamic func cylPlaceholderDeleteRows(at indexPaths: NSArray?, with animation: UITableView.RowAnimation) {
        cylPlaceholderDeleteRows(at: indexPaths, with: animation)
        cylPlaceholderController?.scheduleUpdate()
    }

    @objc(cyl_ph_reloadRowsAtIndexPaths:withRowAnimation:)
    fileprivate dynamic func cylPlaceholderReloadRows(at indexPaths: NSArray?, with animation: UITableView.RowAnimation) {
        cylPlaceholderReloadRows(at: indexPaths, with: animation)
        cylPlaceholderController?.scheduleUpdate()
    }

    @objc(cyl_ph_moveRowAtIndexPath:toIndexPath:)
    fileprivate dynamic func cylPlaceholderMoveRow(at indexPath: NSIndexPath?, to newIndexPath: NSIndexPath?) {
        cylPlaceholderMoveRow(at: indexPath, to: newIndexPath)
        cylPlaceholderController?.scheduleUpdate()
    }

    @objc(cyl_ph_reconfigureRowsAtIndexPaths:)
    fileprivate dynamic func cylPlaceholderReconfigureRows(at indexPaths: NSArray?) {
        cylPlaceholderReconfigureRows(at: indexPaths)
        cylPlaceholderController?.scheduleUpdate()
    }

    @objc(cyl_ph_performBatchUpdates:completion:)
    fileprivate dynamic func cylPlaceholderPerformBatchUpdates(_ updates: (@convention(block) () -> Void)?,
                                                        completion: (@convention(block) (Bool) -> Void)?) {
        guard let controller = cylPlaceholderController, controller.provider != nil else {
            cylPlaceholderPerformBatchUpdates(updates, completion: completion)
            return
        }
        var wrappedUpdates: (@convention(block) () -> Void)?
        if let updates = updates {
            wrappedUpdates = { [weak self] in
                let current = self?.cylPlaceholderController
                current?.batchDepth += 1
                CYLPlaceholderController.perform(updates) {
                    if let current = current, current.batchDepth > 0 { current.batchDepth -= 1 }
                    current?.scheduleUpdate()
                }
            }
        }
        let wrappedCompletion: @convention(block) (Bool) -> Void = { [weak self] finished in
            completion?(finished)
            self?.cylPlaceholderController?.scheduleUpdate()
        }
        controller.batchCallDepth += 1
        CYLPlaceholderController.perform({
            self.cylPlaceholderPerformBatchUpdates(wrappedUpdates, completion: wrappedCompletion)
        }, finally: {
            controller.batchCallDepth -= 1
        })
        controller.scheduleUpdate()
    }
}

// MARK: - UICollectionView

extension UICollectionView {

    /**
     * [EN] Shows the block's view whenever a reload or update leaves the collection view with no items, and removes it
     *      when content comes back. Pass nil to turn the automatic placeholder off and restore the normal state. The
     *      block should not retain the collection view or its owner strongly.
     * [CN] 每当刷新或更新使集合视图没有 item 时显示 block 返回的视图，有内容后移除。传 nil 关闭自动占位图并恢复正常状态。block 不应
     *      强引用集合视图或其持有者。
     */
    @objc(cyl_placeholderViewBlock:)
    public func cylPlaceholderViewBlock(_ placeholderViewBlock: CYLCollectionPlaceholderViewBlock?) {
        cylPlaceholderViewBlock(placeholderViewBlock, backToNormalBlock: nil)
    }

    /**
     * [EN] Like `cylPlaceholderViewBlock(_:)`, and also sets the block called when the placeholder is removed (the
     *      collection view has content again); nil for both turns the automatic placeholder off.
     * [CN] 与 `cylPlaceholderViewBlock(_:)` 相同，并设置占位图被移除（集合视图重新有内容）时调用的 block；两者都为 nil 时关闭自动占位图。
     */
    @objc(cyl_placeholderViewBlock:backToNormalBlock:)
    public func cylPlaceholderViewBlock(_ placeholderViewBlock: CYLCollectionPlaceholderViewBlock?,
                                         backToNormalBlock: CYLCollectionPlaceholderNormalBlock?) {
        let provider = placeholderViewBlock.map { block in
            { (view: UIScrollView) -> UIView? in block(unsafeDowncast(view, to: UICollectionView.self)) }
        }
        let restore = backToNormalBlock.map { block in
            { (view: UIScrollView) in block(unsafeDowncast(view, to: UICollectionView.self)) }
        }
        CYLPlaceholderController.install(on: self, provider: provider, restore: restore)
    }

    // MARK: Replacements (swizzled with the originals; calling one calls the original)

    @objc fileprivate dynamic func cylPlaceholderReloadData() {
        cylPlaceholderReloadData()
        cylPlaceholderController?.scheduleUpdate()
    }

    @objc(cyl_ph_setDataSource:)
    fileprivate dynamic func cylPlaceholderSetDataSource(_ source: UICollectionViewDataSource?) {
        cylPlaceholderSetDataSource(source)
        cylPlaceholderController?.scheduleUpdate()
    }

    @objc(cyl_ph_insertSections:)
    fileprivate dynamic func cylPlaceholderInsertSections(_ sections: NSIndexSet?) {
        cylPlaceholderInsertSections(sections)
        cylPlaceholderController?.scheduleUpdate()
    }

    @objc(cyl_ph_deleteSections:)
    fileprivate dynamic func cylPlaceholderDeleteSections(_ sections: NSIndexSet?) {
        cylPlaceholderDeleteSections(sections)
        cylPlaceholderController?.scheduleUpdate()
    }

    @objc(cyl_ph_reloadSections:)
    fileprivate dynamic func cylPlaceholderReloadSections(_ sections: NSIndexSet?) {
        cylPlaceholderReloadSections(sections)
        cylPlaceholderController?.scheduleUpdate()
    }

    @objc(cyl_ph_moveSection:toSection:)
    fileprivate dynamic func cylPlaceholderMoveSection(_ section: Int, toSection newSection: Int) {
        cylPlaceholderMoveSection(section, toSection: newSection)
        cylPlaceholderController?.scheduleUpdate()
    }

    @objc(cyl_ph_insertItemsAtIndexPaths:)
    fileprivate dynamic func cylPlaceholderInsertItems(at indexPaths: NSArray?) {
        cylPlaceholderInsertItems(at: indexPaths)
        cylPlaceholderController?.scheduleUpdate()
    }

    @objc(cyl_ph_deleteItemsAtIndexPaths:)
    fileprivate dynamic func cylPlaceholderDeleteItems(at indexPaths: NSArray?) {
        cylPlaceholderDeleteItems(at: indexPaths)
        cylPlaceholderController?.scheduleUpdate()
    }

    @objc(cyl_ph_reloadItemsAtIndexPaths:)
    fileprivate dynamic func cylPlaceholderReloadItems(at indexPaths: NSArray?) {
        cylPlaceholderReloadItems(at: indexPaths)
        cylPlaceholderController?.scheduleUpdate()
    }

    @objc(cyl_ph_moveItemAtIndexPath:toIndexPath:)
    fileprivate dynamic func cylPlaceholderMoveItem(at indexPath: NSIndexPath?, to newIndexPath: NSIndexPath?) {
        cylPlaceholderMoveItem(at: indexPath, to: newIndexPath)
        cylPlaceholderController?.scheduleUpdate()
    }

    @objc(cyl_ph_reconfigureItemsAtIndexPaths:)
    fileprivate dynamic func cylPlaceholderReconfigureItems(at indexPaths: NSArray?) {
        cylPlaceholderReconfigureItems(at: indexPaths)
        cylPlaceholderController?.scheduleUpdate()
    }

    @objc(cyl_ph_performBatchUpdates:completion:)
    fileprivate dynamic func cylPlaceholderPerformBatchUpdates(_ updates: (@convention(block) () -> Void)?,
                                                        completion: (@convention(block) (Bool) -> Void)?) {
        guard let controller = cylPlaceholderController, controller.provider != nil else {
            cylPlaceholderPerformBatchUpdates(updates, completion: completion)
            return
        }
        var wrappedUpdates: (@convention(block) () -> Void)?
        if let updates = updates {
            wrappedUpdates = { [weak self] in
                let current = self?.cylPlaceholderController
                current?.batchDepth += 1
                CYLPlaceholderController.perform(updates) {
                    if let current = current, current.batchDepth > 0 { current.batchDepth -= 1 }
                    current?.scheduleUpdate()
                }
            }
        }
        cylPlaceholderPerformBatchUpdates(wrappedUpdates) { [weak self] finished in
            completion?(finished)
            self?.cylPlaceholderController?.scheduleUpdate()
        }
        controller.scheduleUpdate()
    }
}

// MARK: - UIScrollView (CYLPlaceholderVisibility)

extension UIScrollView {

    /**
     * [EN] YES keeps the placeholder from showing even when the list is empty; NO (the default) shows it as before.
     *      `cylStatusDisplay` sets it. [CN] YES 时即使列表为空也不显示占位图；NO（默认）与以前相同。由 `cylStatusDisplay` 设置。
     */
    @objc(cyl_placeholderHidden) public var cylPlaceholderHidden: Bool {
        get { (objc_getAssociatedObject(self, CYLPlaceholderKey.hidden) as? NSNumber)?.boolValue ?? false }
        set {
            if newValue == cylPlaceholderHidden { return }
            objc_setAssociatedObject(self, CYLPlaceholderKey.hidden, newValue ? NSNumber(value: true) : nil,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            cylPlaceholderController?.scheduleUpdate()
        }
    }

    /**
     * [EN] The placeholder shown for this list now, or nil: the view of `cylPlaceholderViewBlock(_:)` (or of the delegate
     *      API, `cylReloadData`) while the list is empty. Updates are applied on the next run loop turn, so read it after
     *      the reload has been laid out. The same as Android's `RecyclerView.cylPlaceholderView`.
     * [CN] 当前为该列表显示的占位图，没有则为 nil：列表为空时 `cylPlaceholderViewBlock(_:)`（或委托接口 `cylReloadData`）提供的视图。
     *      更新在下一次 run loop 应用，请在刷新布局后读取。与 Android 的 `RecyclerView.cylPlaceholderView` 相同。
     */
    @objc(cyl_placeholderView) public var cylPlaceholderView: UIView? {
        if let view = cylPlaceholderController?.view { return view }
        // [EN] The delegate API (UITableView+CYLTableViewPlaceHolder) keeps its view under its own key, read by name as
        //      before. [CN] 委托接口（UITableView+CYLTableViewPlaceHolder）以自己的 key 保存视图，与以前一样按名称读取。
        let legacy = NSSelectorFromString("placeHolderView")
        if responds(to: legacy), let legacyView = value(forKey: NSStringFromSelector(legacy)) as? UIView {
            return legacyView
        }
        return nil
    }
}
