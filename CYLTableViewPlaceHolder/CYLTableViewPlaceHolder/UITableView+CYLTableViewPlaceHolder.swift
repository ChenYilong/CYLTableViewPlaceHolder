//
//  UITableView+CYLTableViewPlaceHolder.swift
//  CYLNoResultTableViewController
//
//  Created by 微博@iOS程序犭袁 ( http://weibo.com/luohanchenyilong/ ) on 15/12/23.
//  Copyright © 2015年 https://github.com/ChenYilong . All rights reserved.
//

// [EN] The legacy delegate API (`cyl_reloadData` with `CYLTableViewPlaceHolderDelegate`), in Swift since 2026-11-19 with
//      the same selectors: `cyl_reloadData`, and the internal `placeHolderView` (read through key-value coding by
//      `-[UIScrollView cyl_placeholderView]`) and `cyl_removeLegacyPlaceholder` (called by the automatic placeholder). The
//      C functions it calls stay in `UIScrollView+CYLPlaceholder.m`, declared for Swift in `CYLPlaceholderVisibleArea.h`.
// [CN] 旧的委托接口（`cyl_reloadData` 与 `CYLTableViewPlaceHolderDelegate`），自 2026-11-19 起用 Swift 编写，选择器不变：`cyl_reloadData`，
//      以及内部的 `placeHolderView`（`-[UIScrollView cyl_placeholderView]` 通过键值编码读取）与 `cyl_removeLegacyPlaceholder`（自动占位图调用）。
//      其调用的 C 函数保留在 `UIScrollView+CYLPlaceholder.m` 中，通过 `CYLPlaceholderVisibleArea.h` 向 Swift 声明。

import UIKit
import ObjectiveC

// [EN] The associated-object keys: stable addresses for the process's lifetime. [CN] 关联对象的 key：进程内地址固定。
private enum CYLLegacyPlaceholderKey {
    static let scrollWasEnabled = UnsafeRawPointer(UnsafeMutablePointer<UInt8>.allocate(capacity: 1))
    static let placeHolderView = UnsafeRawPointer(UnsafeMutablePointer<UInt8>.allocate(capacity: 1))
    static let visibleAreaObserver = UnsafeRawPointer(UnsafeMutablePointer<UInt8>.allocate(capacity: 1))
}

extension UITableView {

    /**
     * Just use this method to replace `reloadData`, and it adds or removes the placeholder view automatically. It
     * already reloads the table view, so do not reload it again.
     */
    @objc public func cyl_reloadData() {
        reloadData()
        if !__CYLAutomaticPlaceholderEnabled(self) { cyl_checkEmpty() }
    }

    // MARK: Internal state (Objective-C selectors kept)

    // [EN] `isScrollEnabled` before the placeholder appeared. [CN] 占位图出现之前的 `isScrollEnabled`。
    @objc(scrollWasEnabled) var cyl_scrollWasEnabled: Bool {
        get { (objc_getAssociatedObject(self, CYLLegacyPlaceholderKey.scrollWasEnabled) as? NSNumber)?.boolValue ?? false }
        set {
            objc_setAssociatedObject(self, CYLLegacyPlaceholderKey.scrollWasEnabled, NSNumber(value: newValue),
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    // [EN] The placeholder view shown by this API; key-value coding reads it as `placeHolderView`.
    // [CN] 本接口显示的占位视图；键值编码以 `placeHolderView` 读取。
    @objc(placeHolderView) var cyl_legacyPlaceHolderView: UIView? {
        get { objc_getAssociatedObject(self, CYLLegacyPlaceholderKey.placeHolderView) as? UIView }
        set {
            objc_setAssociatedObject(self, CYLLegacyPlaceholderKey.placeHolderView, newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    // [EN] Called by the automatic placeholder when it takes over the table. [CN] 自动占位图接管表格时调用。
    @objc func cyl_removeLegacyPlaceholder() {
        guard let view = cyl_legacyPlaceHolderView else { return }
        isScrollEnabled = cyl_scrollWasEnabled
        view.removeFromSuperview()
        cyl_legacyPlaceHolderView = nil
    }

    // MARK: Private

    private func cyl_framePlaceholderInVisibleArea(_ view: UIView) {
        let insets = __CYLPlaceholderVisibleInsets(self)
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

    private func cyl_observeVisibleArea() {
        if objc_getAssociatedObject(self, CYLLegacyPlaceholderKey.visibleAreaObserver) != nil { return }
        __CYLPlaceholderStartTrackingKeyboard()
        let token = NotificationCenter.default.addObserver(forName: .__CYLPlaceholderVisibleAreaDidChange, object: nil,
                                                           queue: nil) { [weak self] _ in
            guard let table = self, let view = table.cyl_legacyPlaceHolderView, view.superview === table else { return }
            table.cyl_framePlaceholderInVisibleArea(view)
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
    private func cyl_placeholderProvider(responding selector: Selector) -> CYLTableViewPlaceHolderDelegate? {
        let candidates: [NSObjectProtocol?] = [self, delegate, dataSource]
        for case let candidate? in candidates where candidate.responds(to: selector) {
            return unsafeBitCast(candidate, to: CYLTableViewPlaceHolderDelegate.self)
        }
        return nil
    }

    private func cyl_checkEmpty() {
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
            if let shown = cyl_legacyPlaceHolderView {
                isScrollEnabled = cyl_scrollWasEnabled
                shown.removeFromSuperview()
                cyl_legacyPlaceHolderView = nil
            }
            return
        }

        let provider = cyl_placeholderProvider(responding: #selector(CYLTableViewPlaceHolderDelegate.makePlaceHolderView))
        let made: UIView? = provider?.makePlaceHolderView()
        guard let view = made else {
            NSLog("CYLTableViewPlaceHolder: makePlaceHolderView must return a view when the table is empty.")
            if let shown = cyl_legacyPlaceHolderView {
                isScrollEnabled = cyl_scrollWasEnabled
                shown.removeFromSuperview()
                cyl_legacyPlaceHolderView = nil
            }
            return
        }

        if let shown = cyl_legacyPlaceHolderView {
            if shown !== view { shown.removeFromSuperview() }
        } else {
            cyl_scrollWasEnabled = isScrollEnabled
            let scrollProvider = cyl_placeholderProvider(
                responding: #selector(CYLTableViewPlaceHolderDelegate.enableScrollWhenPlaceHolderViewShowing))
            isScrollEnabled = scrollProvider?.enableScrollWhenPlaceHolderViewShowing?() ?? false
        }
        cyl_legacyPlaceHolderView = view
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
            cyl_framePlaceholderInVisibleArea(view)
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            cyl_observeVisibleArea()
        }
        if view.superview !== self {
            addSubview(view)
        }
        __CYLBringPlaceholderToFront(self, view)
    }
}
