//
//  CYLRefreshStateHeader.swift
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

// [EN] Swift since 2026-11-20 (docs/Swift-Migration.md, step 10), with the same Objective-C API (`stateLabel`,
//      `lastUpdatedTimeLabel`, `lastUpdatedTimeText`, `labelLeftInset`, `setTitle:forState:`, `titleForState:`, the
//      last-updated formatter, spacing, result images and `iconOnTrailingSide`, `cyl_modifyLastUpdatedTimeText:`) and the
//      same texts, time format and layout. The class factories (`+headerWithRefreshingBlock:`,
//      `+headerWithRefreshingTarget:refreshingAction:`) are inherited and still return the class they are sent to.
// [CN] 自 2026-11-20 起用 Swift 编写（docs/Swift-Migration.md 第 10 步），Objective-C API（`stateLabel`、`lastUpdatedTimeLabel`、
//      `lastUpdatedTimeText`、`labelLeftInset`、`setTitle:forState:`、`titleForState:`、上次更新时间的格式器、间距、结果图片与
//      `iconOnTrailingSide`、`cyl_modifyLastUpdatedTimeText:`）以及文字、时间格式与布局均不变。类工厂方法（`+headerWithRefreshingBlock:`、
//      `+headerWithRefreshingTarget:refreshingAction:`）继承而来，仍返回接收消息的类。

import UIKit

/**
 * [EN] A header that shows a localized text for each state and the time of the last refresh.
 * [CN] 按状态显示本地化文字以及上次刷新时间的刷新头。
 */
@objc(CYLRefreshStateHeader)
open class CYLRefreshStateHeader: CYLRefreshHeader {

    // [EN] Weak, as the Objective-C ivars were not retained: the header's subviews own the labels.
    // [CN] 弱引用，与 Objective-C 未持有的实例变量相同：label 由刷新头的子视图持有。
    private weak var storedLastUpdatedTimeLabel: UILabel?
    private weak var storedStateLabel: UILabel?
    private var storedLastUpdatedTimeText: ((Date?) -> String)?
    private var storedLastUpdatedTimeFormatter: DateFormatter?
    private var storedTitleTimeSpacing: CGFloat = 0
    private var storedIconOnTrailingSide = false
    // [EN] Shows succeededImage / failedImage during the finish hold. [CN] 结束停留期间显示 succeededImage / failedImage。
    private var resultImageView: UIImageView?

    // MARK: - Last updated time

    /**
     * [EN] Turns the last refresh time (nil when there is none) into the text the time label shows.
     * [CN] 利用这个 block 来决定显示的更新时间文字（没有记录时传入 nil）。
     */
    @objc open var lastUpdatedTimeText: ((Date?) -> String)? {
        get { storedLastUpdatedTimeText }
        set {
            storedLastUpdatedTimeText = newValue
            // 重新设置key（重新显示时间）
            reapplyLastUpdatedTimeKey()
        }
    }

    /**
     * [EN] The label that shows the time of the last refresh, created on first access.
     * [CN] 显示上一次刷新时间的 label，首次访问时创建。
     */
    @objc open var lastUpdatedTimeLabel: UILabel! {
        if let label = storedLastUpdatedTimeLabel { return label }
        // [EN] `+[UILabel cyl_label]`, which Swift calls `cylLabel()`. [CN] 即 `+[UILabel cyl_label]`，Swift 中为 `cylLabel()`。
        let label = UILabel.cylLabel()
        addSubview(label)
        storedLastUpdatedTimeLabel = label
        return label
    }

    // MARK: - State

    /**
     * [EN] Points between the texts and the spinner or arrow.
     * [CN] 文字距离圈圈、箭头的距离。
     */
    @objc open var labelLeftInset: CGFloat = 0

    /**
     * [EN] The label that shows the state text, created on first access.
     * [CN] 显示刷新状态的 label，首次访问时创建。
     */
    @objc open var stateLabel: UILabel! {
        if let label = storedStateLabel { return label }
        let label = UILabel.cylLabel()
        addSubview(label)
        storedStateLabel = label
        return label
    }

    /**
     * [EN] Sets the text shown in `state` (nil is ignored) and returns the header.
     * [CN] 设置 state 状态下的文字（nil 被忽略），并返回刷新头本身。
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
     * [EN] Formats the last update time instead of the built-in, locale-aware format ("Last update: " stays in front).
     *      `lastUpdatedTimeText` still wins when set. [CN] 用它格式化上次更新时间，代替内置的按语言格式（前面保留 “最后更新：”）。
     *      设置了 `lastUpdatedTimeText` 时仍以它为准。
     */
    @objc open var lastUpdatedTimeFormatter: DateFormatter? {
        get { storedLastUpdatedTimeFormatter }
        set {
            storedLastUpdatedTimeFormatter = newValue
            reapplyLastUpdatedTimeKey()
        }
    }

    /**
     * [EN] The text the time label shows now. [CN] 时间文字当前显示的内容。
     */
    @objc open var lastUpdatedTimeString: String? {
        lastUpdatedTimeLabel.text
    }

    /**
     * [EN] Points between the state text and the time text; 0 (default) splits the height in halves as before.
     * [CN] 状态文字与时间文字之间的间距（点）；0（默认）表示照旧把高度一分为二。
     */
    @objc open var titleTimeSpacing: CGFloat {
        get { storedTitleTimeSpacing }
        set {
            storedTitleTimeSpacing = max(0, newValue)
            setNeedsLayout()
        }
    }

    /**
     * [EN] Shown in place of the icon while the header holds after a successful refresh (`finishDuration` > 0)
     *      (flutter_easy_refresh's `ClassicHeader.succeededIcon`). [CN] 刷新成功后停留期间（`finishDuration` > 0）代替图标显示
     *      （对应 flutter_easy_refresh 的 `ClassicHeader.succeededIcon`）。
     */
    @objc open var succeededImage: UIImage?

    /**
     * [EN] Shown in place of the icon while the header holds after a failed refresh (`failedIcon`).
     * [CN] 刷新失败后停留期间代替图标显示（对应 `failedIcon`）。
     */
    @objc open var failedImage: UIImage?

    /**
     * [EN] Puts the icon on the trailing side of the text instead of the leading side (flutter_easy_refresh's
     *      `ClassicHeader.reverse`). Default NO. [CN] 把图标放在文字后面而不是前面（对应 flutter_easy_refresh 的 `ClassicHeader.reverse`）。默认 NO。
     */
    @objc open var iconOnTrailingSide: Bool {
        get { storedIconOnTrailingSide }
        set {
            storedIconOnTrailingSide = newValue
            setNeedsLayout()
        }
    }

    // MARK: - Key

    /**
     * [EN] Also shows the time stored under the new key. [CN] 同时显示新 key 下保存的时间。
     */
    open override var lastUpdatedTimeKey: String {
        get { super.lastUpdatedTimeKey }
        set {
            super.lastUpdatedTimeKey = newValue
            showLastUpdatedTime(forKey: newValue)
        }
    }

    // [EN] `self.lastUpdatedTimeKey = self.lastUpdatedTimeKey`: goes through the setter (and its overrides) again.
    // [CN] 即 `self.lastUpdatedTimeKey = self.lastUpdatedTimeKey`：再次经过 setter（及其重写）。
    private func reapplyLastUpdatedTimeKey() {
        let key = lastUpdatedTimeKey
        lastUpdatedTimeKey = key
    }

    private func showLastUpdatedTime(forKey key: String) {
        // 如果label隐藏了，就不用再处理
        if lastUpdatedTimeLabel.isHidden { return }

        let lastUpdatedTime = UserDefaults.standard.object(forKey: key) as? Date
        let lastTimeText = Bundle.cylLocalizedString(forKey: CYLRefreshHeaderLastTimeText)

        // 如果有block
        if let lastUpdatedTimeText = lastUpdatedTimeText {
            lastUpdatedTimeLabel.text = lastUpdatedTimeText(lastUpdatedTime)
            return
        }

        if let formatter = lastUpdatedTimeFormatter {
            let time = lastUpdatedTime.map { formatter.string(from: $0) }
                ?? Bundle.cylLocalizedString(forKey: CYLRefreshHeaderNoneLastDateText)
            lastUpdatedTimeLabel.text = lastTimeText + time
            return
        }

        guard let lastUpdatedTime = lastUpdatedTime else {
            lastUpdatedTimeLabel.text = lastTimeText + Bundle.cylLocalizedString(forKey: CYLRefreshHeaderNoneLastDateText)
            return
        }
        // 1.判断今天、今年（比较完整日期，而不只是“日”）
        let calendar = Calendar(identifier: .gregorian)
        let isToday = calendar.isDateInToday(lastUpdatedTime)
        let isThisYear = calendar.component(.year, from: lastUpdatedTime) == calendar.component(.year, from: Date())

        // 2.按语言格式化日期：顺序、分隔符和 12/24 小时制随 locale 变化（j 为该 locale 偏好的小时格式）
        let locale = CYLRefreshConfig.default.languageCode.map { Locale(identifier: $0) } ?? Locale.current
        let formatTemplate = isToday ? "jmm" : (isThisYear ? "MMddjmm" : "yyyyMMddjmm")
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: formatTemplate, options: 0, locale: locale)
        var time = formatter.string(from: lastUpdatedTime)
        if isToday { time = " " + time }

        // 3.显示日期
        let todayText = isToday ? Bundle.cylLocalizedString(forKey: CYLRefreshHeaderDateTodayText) : ""
        lastUpdatedTimeLabel.text = lastTimeText + todayText + time
    }

    private func textConfiguration() {
        // 初始化文字
        setTitle(Bundle.cylLocalizedString(forKey: CYLRefreshHeaderIdleText), for: .idle)
        setTitle(Bundle.cylLocalizedString(forKey: CYLRefreshHeaderPullingText), for: .pulling)
        setTitle(Bundle.cylLocalizedString(forKey: CYLRefreshHeaderRefreshingText), for: .refreshing)
        lastUpdatedTimeKey = CYLRefreshHeaderLastUpdatedTimeKey
    }

    // MARK: - Overrides

    /**
     * [EN] Sets the spacing and the localized texts. [CN] 设置间距与本地化文字。
     */
    open override func prepare() {
        super.prepare()

        // 初始化间距
        labelLeftInset = CYLRefreshLabelLeftInset
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
     * [EN] Lays out the state text and the time text, and the result image beside them.
     * [CN] 布局状态文字与时间文字，以及它们旁边的结果图片。
     */
    open override func placeSubviews() {
        super.placeSubviews()

        if let resultImageView = resultImageView, !resultImageView.isHidden {
            resultImageView.cylSize = resultImageView.image?.size ?? .zero
            resultImageView.center = iconCenterBesideText()
        }
        if stateLabel.isHidden { return }

        let noConstrainsOnStatusLabel = stateLabel.constraints.isEmpty

        if lastUpdatedTimeLabel.isHidden {
            // 状态
            if noConstrainsOnStatusLabel { stateLabel.frame = bounds }
            return
        }
        var stateLabelH = cylH * 0.5
        var stateLabelY: CGFloat = 0
        if titleTimeSpacing > 0 {
            // [EN] Both lines centered as a block, `titleTimeSpacing` apart. [CN] 两行作为一个整体居中，间距 `titleTimeSpacing`。
            let stateH = ceil(stateLabel.font.lineHeight)
            let timeH = ceil(lastUpdatedTimeLabel.font.lineHeight)
            stateLabelY = max(0, (cylH - stateH - titleTimeSpacing - timeH) * 0.5)
            stateLabelH = stateH
        }
        // 状态
        if noConstrainsOnStatusLabel {
            stateLabel.cylX = 0
            stateLabel.cylY = stateLabelY
            stateLabel.cylW = cylW
            stateLabel.cylH = stateLabelH
        }

        // 更新时间
        if lastUpdatedTimeLabel.constraints.isEmpty {
            lastUpdatedTimeLabel.cylX = 0
            lastUpdatedTimeLabel.cylY = titleTimeSpacing > 0 ? stateLabelY + stateLabelH + titleTimeSpacing : stateLabelH
            lastUpdatedTimeLabel.cylW = cylW
            lastUpdatedTimeLabel.cylH = titleTimeSpacing > 0 ? ceil(lastUpdatedTimeLabel.font.lineHeight)
                                                              : cylH - lastUpdatedTimeLabel.cylY
        }
    }

    /**
     * [EN] Shows the state's text and the last updated time again. [CN] 显示该状态的文字，并重新显示上次更新时间。
     */
    open override var state: CYLRefreshState {
        get { super.state }
        set {
            // [EN] CYLRefreshCheckState. [CN] 即 CYLRefreshCheckState。
            let oldState = state
            if newValue == oldState { return }
            super.state = newValue
            if newValue != .refreshing { hideResultImage() }

            // 设置状态文字
            stateLabel.text = stateTitle(for: newValue)

            // 重新设置key（重新显示时间）
            reapplyLastUpdatedTimeKey()
        }
    }

    /**
     * [EN] The state and time labels. [CN] 状态与时间 label。
     */
    open override var flipsHorizontallyInOppositeLayoutDirectionViews: [UIView] {
        [stateLabel, lastUpdatedTimeLabel]
    }

    /**
     * [EN] While the control holds after the refresh (`finishDuration`), the state text shows the result.
     * [CN] 刷新结束后停留期间（`finishDuration`），状态文字显示结果。
     */
    open override func refreshDidFinish(withSuccess success: Bool) {
        super.refreshDidFinish(withSuccess: success)
        if finishingDuration(withSuccess: success) <= 0 { return }
        stateLabel.text = Bundle.cylLocalizedString(forKey: success ? CYLRefreshHeaderFinishedText : CYLRefreshHeaderFailedText)
        showResultImage(success ? succeededImage : failedImage)
        setNeedsLayout()
    }

    // MARK: - Result image

    // [EN] The result image takes the icon's place: the spinner and arrow hide while it shows.
    // [CN] 结果图片代替图标：显示期间隐藏菊花与箭头。
    private func showResultImage(_ image: UIImage?) {
        guard let image = image else { return }
        let imageView: UIImageView
        if let resultImageView = resultImageView {
            imageView = resultImageView
        } else {
            // [EN] A system UIImageView, not CYLPlaceholderView: it takes the place of arrowView / loadingView, which are
            //      system views laid out by the same code, and shows one small image with no title.
            // [CN] 用系统 UIImageView 而不是 CYLPlaceholderView：它代替的 arrowView / loadingView 本身就是系统视图、由同一段代码布局，
            //      且只显示一张小图、没有标题。
            imageView = UIImageView()
            imageView.contentMode = .center
            resultImageView = imageView
            addSubview(imageView)
        }
        imageView.image = image
        imageView.isHidden = false
        for view in subviews where view !== imageView && (view is UIActivityIndicatorView || view is UIImageView) {
            view.alpha = 0
        }
    }

    private func hideResultImage() {
        guard let resultImageView = resultImageView, !resultImageView.isHidden else { return }
        resultImageView.isHidden = true
        for view in subviews where view !== resultImageView {
            view.alpha = 1
        }
    }

    // [EN] The icon's center beside the text, on the leading or trailing side. [CN] 图标在文字旁边的中心点（前面或后面）。
    private func iconCenterBesideText() -> CGPoint {
        var centerX = cylW * 0.5
        if !stateLabel.isHidden {
            var textWidth = stateLabel.cylTextWidth()
            if !lastUpdatedTimeLabel.isHidden { textWidth = max(textWidth, lastUpdatedTimeLabel.cylTextWidth()) }
            let shift = textWidth / 2 + labelLeftInset
            centerX += iconOnTrailingSide ? shift : -shift
        }
        return CGPoint(x: centerX, y: cylH * 0.5)
    }
}

// MARK: - <<< 为 Swift 扩展链式语法 >>> -

extension CYLRefreshStateHeader {

    /**
     * [EN] Sets `lastUpdatedTimeText`, the block that turns the last refresh time (nil when there is none) into the text
     *      shown, and returns the header.
     * [CN] 设置 `lastUpdatedTimeText`（把上次刷新时间转换为显示文字的 block，没有记录时传入 nil），并返回刷新头本身。
     */
    @objc(cyl_modifyLastUpdatedTimeText:)
    @discardableResult
    public func modifyLastUpdatedTimeText(_ handler: @escaping (Date?) -> String) -> Self {
        lastUpdatedTimeText = handler
        return self
    }
}
