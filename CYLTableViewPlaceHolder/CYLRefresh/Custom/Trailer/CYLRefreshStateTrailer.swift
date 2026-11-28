//
//  CYLRefreshStateTrailer.swift
//  CYLRefresh
//
//  Created by kinarobin on 2020/5/3.
//  Copyright © 2020 小码哥. All rights reserved.
//

// [EN] Swift since 2026-11-20 (docs/Swift-Migration.md, step 10), with the same Objective-C API (`stateLabel`,
//      `setTitle:forState:`, `titleForState:`, `cyl_placeStateLabelAtCenterX:`, Swift `placeStateLabel(centerX:)`) and
//      the same texts and vertical text layout.
// [CN] 自 2026-11-20 起用 Swift 编写（docs/Swift-Migration.md 第 10 步），Objective-C API（`stateLabel`、`setTitle:forState:`、
//      `titleForState:`、`cyl_placeStateLabelAtCenterX:`，Swift 为 `placeStateLabel(centerX:)`）以及文字与竖排布局均不变。

import UIKit

/**
 * [EN] A trailer that shows a localized text for each state (`setTitle:forState:`).
 * [CN] 按状态显示本地化文字（`setTitle:forState:`）的 trailer。
 */
@objc(CYLRefreshStateTrailer)
open class CYLRefreshStateTrailer: CYLRefreshTrailer {

    // [EN] Weak, as the Objective-C ivar was not retained: the trailer's subviews own the label.
    // [CN] 弱引用，与 Objective-C 未持有的实例变量相同：label 由 trailer 的子视图持有。
    private weak var storedStateLabel: UILabel?

    // MARK: - State

    /**
     * [EN] The label that shows the state text (any number of lines), created on first access.
     * [CN] 显示刷新状态的 label（行数不限），首次访问时创建。
     */
    @objc open var stateLabel: UILabel! {
        if let label = storedStateLabel { return label }
        // [EN] `+[UILabel cyl_label]`, which Swift calls `cylLabel()`. [CN] 即 `+[UILabel cyl_label]`，Swift 中为 `cylLabel()`。
        let label = UILabel.cylLabel()
        label.numberOfLines = 0
        addSubview(label)
        storedStateLabel = label
        return label
    }

    /**
     * [EN] Sets the text shown in `state` (nil is ignored) and returns the trailer.
     * [CN] 设置 state 状态下的文字（nil 被忽略），并返回 trailer 本身。
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

    private func textConfiguration() {
        // 初始化文字
        setTitle(Bundle.cylLocalizedString(forKey: CYLRefreshTrailerIdleText), for: .idle)
        setTitle(Bundle.cylLocalizedString(forKey: CYLRefreshTrailerPullingText), for: .pulling)
        setTitle(Bundle.cylLocalizedString(forKey: CYLRefreshTrailerPullingText), for: .refreshing)
    }

    // MARK: - Overrides

    /**
     * [EN] Sets the localized texts. [CN] 设置本地化文字。
     */
    open override func prepare() {
        super.prepare()

        textConfiguration()
    }

    /**
     * [EN] Reloads the localized texts. [CN] 重新加载本地化文字。
     */
    open override func i18nDidChange() {
        textConfiguration()

        super.i18nDidChange()
    }

    /**
     * [EN] Shows the state's text. [CN] 显示该状态的文字。
     */
    open override var state: CYLRefreshState {
        get { super.state }
        set {
            // [EN] CYLRefreshCheckState. [CN] 即 CYLRefreshCheckState。
            let oldState = state
            if newValue == oldState { return }
            super.state = newValue
            // 设置状态文字
            stateLabel.text = stateTitle(for: newValue)
        }
    }

    /**
     * [EN] Centers the vertical state text. [CN] 把竖排状态文字居中。
     */
    open override func placeSubviews() {
        super.placeSubviews()

        if stateLabel.isHidden { return }
        placeStateLabel(centerX: cylW * 0.5)
    }

    // MARK: - Vertical text

    // [EN] Text that reads well stacked upright: only CJK characters, punctuation and spaces.
    // [CN] 适合逐字竖排的文字：只含中日韩文字、标点与空格。
    private func stacksUpright(_ text: String?) -> Bool {
        guard let text = text, !text.isEmpty else { return true }
        let pattern = "^[\\p{Han}\\p{Hiragana}\\p{Katakana}\\p{Hangul}\\p{P}\\p{Z}\\x{30FC}]+$"
        return (text as NSString).range(of: pattern, options: .regularExpression).location != NSNotFound
    }

    // [EN] YES when the collection view flips this control (see `layoutSubviews` of CYLRefreshComponent).
    // [CN] collection view 会翻转本控件时为 YES（见 CYLRefreshComponent 的 `layoutSubviews`）。
    private var flipsHorizontally: Bool {
        guard let collectionView = scrollView as? UICollectionView else { return false }
        return collectionView.collectionViewLayout.flipsHorizontallyInOppositeLayoutDirection
    }

    /**
     * [EN] Lays the state label out as a vertical column centered at `centerX`, so the whole text stays readable in every
     *      language: CJK text stands upright one character per line (as in MJRefresh) when it fits the height; any other
     *      text (English, Russian, …) or CJK text that does not fit is rotated 90° clockwise to read top to bottom, and
     *      wraps to more lines instead of being cut off. Returns the column's width. Does nothing to a label with
     *      constraints. Subclasses call it from `placeSubviews`.
     * [CN] 把状态文字排成以 `centerX` 为中心的竖列，使任何语言的文字都能完整、可读地显示：中日韩文字放得下时逐字竖排、保持正立（与
     *      MJRefresh 相同）；其他文字（英文、俄文等）或放不下的中日韩文字顺时针旋转 90°，从上往下读，过长时换行而不是截断。返回竖列宽度。
     *      带约束的 label 不处理。子类在 `placeSubviews` 中调用。
     */
    @objc(cyl_placeStateLabelAtCenterX:)
    @discardableResult
    open func placeStateLabel(centerX: CGFloat) -> CGFloat {
        let label: UILabel = stateLabel
        if !label.constraints.isEmpty { return label.frame.width }
        label.transform = .identity
        let height = cylH
        let column = ceil(label.font.pointSize)
        let center = CGPoint(x: centerX, y: height * 0.5)
        let flip = flipsHorizontally ? CGAffineTransform(scaleX: -1, y: 1) : .identity
        // [EN] Upright: one character per line in a column as wide as one character, as in MJRefresh.
        // [CN] 正立：宽度为一个字的竖列，每行一个字，与 MJRefresh 相同。
        let upright = label.sizeThatFits(CGSize(width: column, height: .greatestFiniteMagnitude))
        if stacksUpright(label.text) && upright.height <= height {
            label.bounds = CGRect(x: 0, y: 0, width: column, height: height)
            label.center = center
            label.transform = flip
            return column
        }
        // [EN] Rotated: the text runs along the control's height and wraps to more lines when it is longer.
        // [CN] 旋转：文字沿控件高度排列，更长时换行。
        let length = max(height - 8, column)
        let size = label.sizeThatFits(CGSize(width: length, height: .greatestFiniteMagnitude))
        label.bounds = CGRect(x: 0, y: 0, width: length, height: ceil(size.height))
        label.center = center
        label.transform = CGAffineTransform(rotationAngle: .pi / 2).concatenating(flip)
        return ceil(size.height)
    }

    /**
     * [EN] None: the state label is flipped together with its rotation in `placeStateLabel(centerX:)`; flipping it
     *      here would drop the rotation. [CN] 无：状态文字的翻转与旋转一起在 `placeStateLabel(centerX:)` 中设置；在这里翻转会丢掉旋转。
     */
    open override var flipsHorizontallyInOppositeLayoutDirectionViews: [UIView] {
        []
    }
}
