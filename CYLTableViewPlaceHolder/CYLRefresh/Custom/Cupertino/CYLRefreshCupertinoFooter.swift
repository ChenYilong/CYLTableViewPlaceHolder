//
//  CYLRefreshCupertinoFooter.swift
//  CYLRefresh
//
//  The iOS-style load-more footer (flutter_easy_refresh's CupertinoFooter): a system activity indicator while loading.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 9), with the same Objective-C API (`activityIndicator`)
//      and the same spinner and accessibility label.
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 9 步），Objective-C API（`activityIndicator`）以及菊花与无障碍标签均不变。

import UIKit

/**
 * [EN] The iOS-style footer: an automatic footer that shows a system activity indicator while loading and nothing
 *      otherwise (flutter_easy_refresh's `CupertinoFooter`). `colorAccent` colors the indicator.
 * [CN] iOS 风格的加载尾：自动加载尾，加载时显示系统菊花，其他时候不显示内容（对应 flutter_easy_refresh 的 `CupertinoFooter`）。
 *      `colorAccent` 为菊花着色。
 */
@objc(CYLRefreshCupertinoFooter)
open class CYLRefreshCupertinoFooter: CYLRefreshAutoFooter {

    /**
     * [EN] The activity indicator. [CN] 菊花视图。
     */
    @objc public let activityIndicator = UIActivityIndicatorView(style: .cylRefreshDefault)

    /**
     * [EN] Adds the indicator, shown only while loading. [CN] 添加菊花，只在加载时显示。
     */
    open override func prepare() {
        super.prepare()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isAccessibilityElement = true
        activityIndicator.accessibilityLabel = Bundle.cylLocalizedString(forKey: CYLRefreshAutoFooterRefreshingText)
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
     * [EN] Spins while loading. [CN] 加载时旋转。
     */
    open override var state: CYLRefreshState {
        get { super.state }
        set {
            // [EN] CYLRefreshCheckState. [CN] 即 CYLRefreshCheckState。
            let oldState = state
            if newValue == oldState { return }
            super.state = newValue
            if newValue == .refreshing {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
    }
}
