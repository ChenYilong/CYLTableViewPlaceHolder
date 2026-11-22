//
//  CYLRefreshCupertinoHeader.swift
//  CYLRefresh
//
//  The iOS-style refresh header (flutter_easy_refresh's CupertinoHeader): a system activity indicator that appears and
//  turns with the pull and spins while refreshing.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 9), with the same Objective-C API (`activityIndicator`)
//      and the same fade, turn, spinner and accessibility labels.
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 9 步），Objective-C API（`activityIndicator`）以及淡入、转动、
//      菊花与无障碍标签均不变。

import UIKit

/**
 * [EN] The iOS-style header: a system activity indicator that fades and turns in while pulled and spins while
 *      refreshing, with no text (flutter_easy_refresh's `CupertinoHeader`). `colorAccent` colors the indicator.
 * [CN] iOS 风格的刷新头：系统菊花在下拉时淡入并转动，刷新时旋转，没有文字（对应 flutter_easy_refresh 的 `CupertinoHeader`）。
 *      `colorAccent` 为菊花着色。
 */
@objc(CYLRefreshCupertinoHeader)
open class CYLRefreshCupertinoHeader: CYLRefreshHeader {

    /**
     * [EN] The activity indicator. [CN] 菊花视图。
     */
    @objc public let activityIndicator = UIActivityIndicatorView(style: .cylRefreshDefault)

    /**
     * [EN] Sets the height and adds the indicator, hidden until pulled. [CN] 设置高度并添加菊花，下拉前不可见。
     */
    open override func prepare() {
        super.prepare()
        cylH = 60
        activityIndicator.hidesWhenStopped = false
        activityIndicator.alpha = 0
        activityIndicator.isAccessibilityElement = true
        addSubview(activityIndicator)
    }

    /**
     * [EN] Centers the indicator. [CN] 居中放置菊花。
     */
    open override func placeSubviews() {
        super.placeSubviews()
        activityIndicator.center = CGPoint(x: cylW * 0.5, y: cylH * 0.5)
    }

    /**
     * [EN] Fades in and turns with the pull, like the system refresh control. [CN] 随下拉淡入并转动，与系统刷新控件相同。
     */
    open override var pullingPercent: CGFloat {
        get { super.pullingPercent }
        set {
            super.pullingPercent = newValue
            if isRefreshing { return }
            let percent = max(0, min(1, newValue))
            activityIndicator.alpha = percent
            activityIndicator.transform = CGAffineTransform(rotationAngle: .pi * percent)
        }
    }

    /**
     * [EN] Spins while refreshing (or about to); otherwise stops and follows the pull.
     * [CN] 刷新中（或即将刷新）时旋转；否则停止并随下拉显示。
     */
    open override var state: CYLRefreshState {
        get { super.state }
        set {
            // [EN] CYLRefreshCheckState. [CN] 即 CYLRefreshCheckState。
            let oldState = state
            if newValue == oldState { return }
            super.state = newValue
            if newValue == .refreshing || newValue == .willRefresh {
                activityIndicator.alpha = 1
                activityIndicator.transform = .identity
                activityIndicator.startAnimating()
                activityIndicator.accessibilityLabel = Bundle.cylLocalizedString(forKey: CYLRefreshHeaderRefreshingText)
            } else {
                activityIndicator.stopAnimating()
                activityIndicator.alpha = max(0, min(1, pullingPercent))
                activityIndicator.accessibilityLabel = Bundle.cylLocalizedString(
                    forKey: newValue == .pulling ? CYLRefreshHeaderPullingText : CYLRefreshHeaderIdleText)
            }
        }
    }
}
