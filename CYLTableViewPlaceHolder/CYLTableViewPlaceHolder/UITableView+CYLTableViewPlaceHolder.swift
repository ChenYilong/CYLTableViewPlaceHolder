//
//  UITableView+CYLTableViewPlaceHolder.swift
//  CYLNoResultTableViewController
//
//  Created by 微博@iOS程序犭袁 ( http://weibo.com/luohanchenyilong/ ) on 15/12/23.
//  Copyright © 2015年 https://github.com/ChenYilong . All rights reserved.
//

// [EN] The legacy delegate API (`cylReloadData` with `CYLTableViewPlaceHolderDelegate`), in Swift since 2026-11-19 with
//      the same selectors: `cylReloadData`, and the internal `placeHolderView` (read through key-value coding by
//      `-[UIScrollView cylPlaceholderView]`) and `cylRemoveLegacyPlaceholder` (called by the automatic placeholder). The
//      keyboard tracker and the controller it calls are in `UIScrollView+CYLPlaceholder.swift`.
// [CN] 旧的委托接口（`cylReloadData` 与 `CYLTableViewPlaceHolderDelegate`），自 2026-11-19 起用 Swift 编写，选择器不变：`cylReloadData`，
//      以及内部的 `placeHolderView`（`-[UIScrollView cylPlaceholderView]` 通过键值编码读取）与 `cylRemoveLegacyPlaceholder`（自动占位图调用）。
//      其调用的键盘跟踪与控制器在 `UIScrollView+CYLPlaceholder.swift` 中。

import UIKit
import ObjectiveC

// [EN] The associated-object keys: stable addresses for the process's lifetime. [CN] 关联对象的 key：进程内地址固定。
private enum CYLLegacyPlaceholderKey {
    static let scrollWasEnabled = UnsafeRawPointer(UnsafeMutablePointer<UInt8>.allocate(capacity: 1))
    static let placeHolderView = UnsafeRawPointer(UnsafeMutablePointer<UInt8>.allocate(capacity: 1))
    static let visibleAreaObserver = UnsafeRawPointer(UnsafeMutablePointer<UInt8>.allocate(capacity: 1))
    static let hiddenLoadMoreControls = UnsafeRawPointer(UnsafeMutablePointer<UInt8>.allocate(capacity: 1))
}

extension UITableView {

    /**
     * Just use this method to replace `reloadData`, and it adds or removes the placeholder view automatically. It
     * already reloads the table view, so do not reload it again.
     */
    @objc(cyl_reloadData) public func cylReloadData() {
        reloadData()
        if !CYLPlaceholderController.isEnabled(for: self) { cylCheckEmpty() }
    }

    // MARK: Internal state (Objective-C selectors kept)

    // [EN] `isScrollEnabled` before the placeholder appeared. [CN] 占位图出现之前的 `isScrollEnabled`。
    @objc(scrollWasEnabled) var cylScrollWasEnabled: Bool {
        get { (objc_getAssociatedObject(self, CYLLegacyPlaceholderKey.scrollWasEnabled) as? NSNumber)?.boolValue ?? false }
        set {
            objc_setAssociatedObject(self, CYLLegacyPlaceholderKey.scrollWasEnabled, NSNumber(value: newValue),
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    // [EN] The placeholder view shown by this API; key-value coding reads it as `placeHolderView`.
    // [CN] 本接口显示的占位视图；键值编码以 `placeHolderView` 读取。
    @objc(placeHolderView) var cylLegacyPlaceHolderView: UIView? {
        get { objc_getAssociatedObject(self, CYLLegacyPlaceholderKey.placeHolderView) as? UIView }
        set {
            objc_setAssociatedObject(self, CYLLegacyPlaceholderKey.placeHolderView, newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    // [EN] Called by the automatic placeholder when it takes over the table. [CN] 自动占位图接管表格时调用。
    @objc func cylRemoveLegacyPlaceholder() {
        guard let view = cylLegacyPlaceHolderView else { return }
        isScrollEnabled = cylScrollWasEnabled
        view.removeFromSuperview()
        cylLegacyPlaceHolderView = nil
        cylRestoreLegacyLoadMoreControls()
    }

    // [EN] The footers and trailers hidden while this placeholder shows (see `CYLPlaceholderController.isLoadMoreControl`).
    // [CN] 本占位图显示期间隐藏的刷新尾与 trailer（见 `CYLPlaceholderController.isLoadMoreControl`）。
    private var cylLegacyHiddenLoadMoreControls: NSHashTable<UIView> {
        if let table = objc_getAssociatedObject(self, CYLLegacyPlaceholderKey.hiddenLoadMoreControls) as? NSHashTable<UIView> {
            return table
        }
        let table = NSHashTable<UIView>.weakObjects()
        objc_setAssociatedObject(self, CYLLegacyPlaceholderKey.hiddenLoadMoreControls, table, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return table
    }

    private func cylRestoreLegacyLoadMoreControls() {
        CYLPlaceholderController.restoreLoadMoreControls(of: self, recordedIn: cylLegacyHiddenLoadMoreControls)
    }

    // MARK: Private

    private func cylFramePlaceholderInVisibleArea(_ view: UIView) {
        let insets = CYLPlaceholderVisibleArea.insets(for: self)
        let fullHeight = bounds.size.height
        var height = fullHeight
        if insets.bottom > 0 {
            // [EN] With the keyboard up the placeholder must end at the keyboard: in content coordinates y = 0 is below the
            //      top bar (`adjustedContentInset.top`), so that height comes off too. Without the keyboard it keeps the
            //      table's full height, as before.
            // [CN] 键盘显示时占位图必须止于键盘：内容坐标中 y = 0 在顶部栏（`adjustedContentInset.top`）下方，因此也要减去这段高度。
            //      没有键盘时保持表格的完整高度，与之前相同。
            height -= max(0, adjustedContentInset.top) + insets.bottom
        }
        // [EN] At least a third of the table stays for the placeholder. [CN] 至少给占位图留下表格三分之一的高度。
        view.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: max(fullHeight / 3, height))
    }

    private func cylObserveVisibleArea() {
        if objc_getAssociatedObject(self, CYLLegacyPlaceholderKey.visibleAreaObserver) != nil { return }
        CYLPlaceholderVisibleArea.startTrackingKeyboard()
        let token = NotificationCenter.default.addObserver(forName: CYLPlaceholderVisibleArea.didChangeNotification,
                                                           object: nil, queue: nil) { [weak self] _ in
            guard let table = self, let view = table.cylLegacyPlaceHolderView, view.superview === table else { return }
            table.cylFramePlaceholderInVisibleArea(view)
        }
        objc_setAssociatedObject(self, CYLLegacyPlaceholderKey.visibleAreaObserver, token,
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    // [EN] The first of the table, its delegate and its data source that responds to the selector. As in Objective-C,
    //      responding is enough: an object that implements the methods without declaring the protocol keeps working, so
    //      the object is reinterpreted as the protocol instead of cast with `as?` (an Objective-C protocol existential is
    //      the object pointer itself).
    // [CN] 表格、其 delegate、其 dataSource 中第一个响应该选择器的对象。与 Objective-C 相同，只要求能响应：实现了方法但未声明遵循协议的对象
    //      仍然可用，因此按协议类型重新解释该对象，而不是用 `as?` 转换（Objective-C 协议的存在类型就是对象指针本身）。
    private func cylPlaceholderProvider(responding selector: Selector) -> CYLTableViewPlaceHolderDelegate? {
        let candidates: [NSObjectProtocol?] = [self, delegate, dataSource]
        for case let candidate? in candidates where candidate.responds(to: selector) {
            return unsafeBitCast(candidate, to: CYLTableViewPlaceHolderDelegate.self)
        }
        return nil
    }

    private func cylCheckEmpty() {
        var isEmpty = true
        let source = dataSource
        var sections = 1
        if let source = source, source.responds(to: #selector(UITableViewDataSource.numberOfSections(in:))) {
            sections = source.numberOfSections?(in: self) ?? 1
        }
        var section = 0
        while section < sections {
            let rows = source?.tableView(self, numberOfRowsInSection: section) ?? 0
            if rows > 0 {
                isEmpty = false
                break
            }
            section += 1
        }

        if !isEmpty {
            if let shown = cylLegacyPlaceHolderView {
                isScrollEnabled = cylScrollWasEnabled
                shown.removeFromSuperview()
                cylLegacyPlaceHolderView = nil
                cylRestoreLegacyLoadMoreControls()
            }
            return
        }

        let provider = cylPlaceholderProvider(responding: #selector(CYLTableViewPlaceHolderDelegate.makePlaceHolderView))
        let made: UIView? = provider?.makePlaceHolderView()
        guard let view = made else {
            NSLog("CYLTableViewPlaceHolder: makePlaceHolderView must return a view when the table is empty.")
            if let shown = cylLegacyPlaceHolderView {
                isScrollEnabled = cylScrollWasEnabled
                shown.removeFromSuperview()
                cylLegacyPlaceHolderView = nil
                cylRestoreLegacyLoadMoreControls()
            }
            return
        }

        if let shown = cylLegacyPlaceHolderView {
            if shown !== view { shown.removeFromSuperview() }
        } else {
            cylScrollWasEnabled = isScrollEnabled
            let scrollProvider = cylPlaceholderProvider(
                responding: #selector(CYLTableViewPlaceHolderDelegate.enableScrollWhenPlaceHolderViewShowing))
            isScrollEnabled = scrollProvider?.enableScrollWhenPlaceHolderViewShowing?() ?? false
        }
        cylLegacyPlaceHolderView = view
        if let provider = provider,
           provider.responds(to: #selector(CYLTableViewPlaceHolderDelegate.frameForPlaceHolderView(in:))) {
            // [EN] Lay out first so header and section rects include final geometry, such as iOS 15 section header
            //      padding, when the provider reads them (issue #16).
            // [CN] 先布局，使提供者读取的 header 与 section 区域包含最终几何（例如 iOS 15 的 section header 间距，issue #16）。
            layoutIfNeeded()
            if let frame = provider.frameForPlaceHolderView?(in: self) { view.frame = frame }
        } else {
            // [EN] The table's size, minus the part the keyboard covers; it follows the keyboard while shown (no custom frame
            //      from the provider).
            // [CN] 表格的尺寸减去键盘遮住的部分；显示期间跟随键盘（提供者未给出自定义 frame 时）。
            cylFramePlaceholderInVisibleArea(view)
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            cylObserveVisibleArea()
        }
        if view.superview !== self {
            addSubview(view)
        }
        CYLPlaceholderController.bringPlaceholderToFront(view, in: self)
        CYLPlaceholderController.hideLoadMoreControls(of: self, recordingIn: cylLegacyHiddenLoadMoreControls)
    }
}
