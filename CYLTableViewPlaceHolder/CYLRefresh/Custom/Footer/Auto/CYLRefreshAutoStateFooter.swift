//
//  CYLRefreshAutoStateFooter.swift
//  CYLRefresh
//
//  Created by MJ Lee on 15/6/13.
//  Copyright © 2015年 小码哥. All rights reserved.
//

// [EN] Swift since 2026-11-20 (docs/Swift-Migration.md, step 10), with the same Objective-C API (`stateLabel`,
//      `labelLeftInset`, `setTitle:forState:`, `titleForState:`, `refreshingTitleHidden` with its `isRefreshingTitleHidden`
//      getter), the same texts and the tap on the idle text that loads more. The class factories (`+footerWithRefreshingBlock:`,
//      `+footerWithRefreshingTarget:refreshingAction:`) are inherited and still return the class they are sent to.
// [CN] 自 2026-11-20 起用 Swift 编写（docs/Swift-Migration.md 第 10 步），Objective-C API（`stateLabel`、`labelLeftInset`、
//      `setTitle:forState:`、`titleForState:`、getter 为 `isRefreshingTitleHidden` 的 `refreshingTitleHidden`）、文字以及点击闲置文字加载
//      更多均不变。类工厂方法（`+footerWithRefreshingBlock:`、`+footerWithRefreshingTarget:refreshingAction:`）继承而来，仍返回接收消息的类。

import UIKit

/**
 * [EN] An automatic footer that shows a localized text for each state (`setTitle:forState:`).
 * [CN] 按状态显示本地化文字（`setTitle:forState:`）的自动刷新尾。
 */
@objc(CYLRefreshAutoStateFooter)
open class CYLRefreshAutoStateFooter: CYLRefreshAutoFooter {

    // [EN] Weak, as the Objective-C ivar was not retained: the footer's subviews own the label.
    // [CN] 弱引用，与 Objective-C 未持有的实例变量相同：label 由刷新尾的子视图持有。
    private weak var storedStateLabel: UILabel?
    private var storedRefreshingTitleHidden = false

    /**
     * [EN] Points between the text and the spinner or arrow.
     * [CN] 文字距离圈圈、箭头的距离。
     */
    @objc open var labelLeftInset: CGFloat = 0

    /**
     * [EN] The label that shows the state text, created on first access.
     * [CN] 显示刷新状态的 label，首次访问时创建。
     */
    @objc open var stateLabel: UILabel! {
        if let label = storedStateLabel { return label }
        // [EN] `+[UILabel cyl_label]`, which Swift calls `cylLabel()`. [CN] 即 `+[UILabel cyl_label]`，Swift 中为 `cylLabel()`。
        let label = UILabel.cylLabel()
        addSubview(label)
        storedStateLabel = label
        return label
    }

    /**
     * [EN] Sets the text shown in `state` (nil is ignored) and returns the footer.
     * [CN] 设置 state 状态下的文字（nil 被忽略），并返回刷新尾本身。
     */
    @objc(setTitle:forState:)
    @discardableResult
    open func setTitle(_ title: String?, for state: CYLRefreshState) -> Self {
        guard let title = title else { return self }
        setStateTitle(title, for: state)
        stateLabel.text = stateTitle(for: self.state)
        return self
    }

    /**
     * [EN] The text shown in `state`, or nil (the same getter as `CYLRefreshBackStateFooter`).
     * [CN] `state` 显示的文字，或 nil（与 `CYLRefreshBackStateFooter` 相同的读取方法）。
     */
    @objc(titleForState:)
    open func title(for state: CYLRefreshState) -> String? {
        stateTitle(for: state)
    }

    /**
     * [EN] Hides the state text while refreshing.
     * [CN] 隐藏刷新状态的文字。
     */
    @objc(refreshingTitleHidden)
    open var isRefreshingTitleHidden: Bool {
        @objc(isRefreshingTitleHidden) get { storedRefreshingTitleHidden }
        @objc(setRefreshingTitleHidden:) set { storedRefreshingTitleHidden = newValue }
    }

    // MARK: - Private

    @objc private func stateLabelClick() {
        if state == .idle {
            beginRefreshingWithoutValidation()
        }
    }

    private func textConfiguration() {
        // 初始化文字
        setTitle(Bundle.cylLocalizedString(forKey: CYLRefreshAutoFooterIdleText), for: .idle)
        setTitle(Bundle.cylLocalizedString(forKey: CYLRefreshAutoFooterRefreshingText), for: .refreshing)
        setTitle(Bundle.cylLocalizedString(forKey: CYLRefreshAutoFooterNoMoreDataText), for: .noMoreData)
    }

    // MARK: - Overrides

    /**
     * [EN] Sets the spacing and the localized texts, and makes the text tappable.
     * [CN] 设置间距与本地化文字，并让文字可点击。
     */
    open override func prepare() {
        super.prepare()

        // 初始化间距
        labelLeftInset = CYLRefreshLabelLeftInset

        textConfiguration()

        // 监听label
        stateLabel.isUserInteractionEnabled = true
        stateLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(stateLabelClick)))
    }

    /**
     * [EN] Reloads the localized texts. [CN] 重新加载本地化文字。
     */
    open override func i18nDidChange() {
        textConfiguration()

        super.i18nDidChange()
    }

    /**
     * [EN] The state text fills the footer. [CN] 状态文字铺满刷新尾。
     */
    open override func placeSubviews() {
        super.placeSubviews()

        if !stateLabel.constraints.isEmpty { return }

        // 状态标签
        stateLabel.frame = bounds
    }

    /**
     * [EN] Shows the state's text (none while refreshing with `refreshingTitleHidden`).
     * [CN] 显示该状态的文字（开启 `refreshingTitleHidden` 时刷新中不显示）。
     */
    open override var state: CYLRefreshState {
        get { super.state }
        set {
            // [EN] CYLRefreshCheckState. [CN] 即 CYLRefreshCheckState。
            let oldState = state
            if newValue == oldState { return }
            super.state = newValue

            if isRefreshingTitleHidden && newValue == .refreshing {
                stateLabel.text = nil
            } else {
                stateLabel.text = stateTitle(for: newValue)
            }
        }
    }

    /**
     * [EN] The state label. [CN] 状态 label。
     */
    open override var flipsHorizontallyInOppositeLayoutDirectionViews: [UIView] {
        [stateLabel]
    }

    /**
     * [EN] While the footer holds after loading (`finishDuration`), the state text shows the result.
     * [CN] 加载结束后停留期间（`finishDuration`），状态文字显示结果。
     */
    open override func refreshDidFinish(withSuccess success: Bool) {
        super.refreshDidFinish(withSuccess: success)
        if finishingDuration(withSuccess: success) <= 0 { return }
        stateLabel.text = Bundle.cylLocalizedString(forKey: success ? CYLRefreshFooterFinishedText : CYLRefreshFooterFailedText)
    }
}
