//
//  CYLRefreshAutoNormalFooter.swift
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 9), with the same Objective-C API (`loadingView`,
//      `noMoreDataImage`, the deprecated `activityIndicatorViewStyle`) and the same spinner and layout. The class
//      factories (`+footerWithRefreshingBlock:`, ...) are inherited and still return a `CYLRefreshAutoNormalFooter`.
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 9 步），Objective-C API（`loadingView`、`noMoreDataImage`、已废弃的
//      `activityIndicatorViewStyle`）以及菊花与布局均不变。类工厂方法（`+footerWithRefreshingBlock:` 等）继承而来，仍返回
//      `CYLRefreshAutoNormalFooter`。

import UIKit

/**
 * [EN] The standard automatic footer: the state text with a spinner while loading.
 * [CN] 标准自动刷新尾：状态文字，加载时显示菊花。
 */
@objc(CYLRefreshAutoNormalFooter)
open class CYLRefreshAutoNormalFooter: CYLRefreshAutoStateFooter {

    // [EN] Weak, as in Objective-C: the footer's subviews own the spinner. [CN] 弱引用，与 Objective-C 相同：菊花由刷新尾的子视图持有。
    private weak var storedLoadingView: UIActivityIndicatorView?
    private var storedNoMoreDataImage: UIImage?
    private var storedIndicatorStyle: UIActivityIndicatorView.Style = .cyl_refreshDefault

    /**
     * [EN] The spinner shown while loading, created on first access and hidden when stopped; style it here.
     * [CN] 加载时显示的菊花，首次访问时创建，停止时隐藏；可在此设置样式。
     */
    @objc open var loadingView: UIActivityIndicatorView {
        if let loadingView = storedLoadingView { return loadingView }
        let loadingView = UIActivityIndicatorView(style: storedIndicatorStyle)
        loadingView.hidesWhenStopped = true
        addSubview(loadingView)
        storedLoadingView = loadingView
        return loadingView
    }

    /**
     * [EN] The spinner's style; setting it recreates the spinner. [CN] 菊花的样式；设置后重新创建菊花。
     */
    @available(*, deprecated, message: "first deprecated in 3.2.2 - Use `loadingView` property")
    @objc open var activityIndicatorViewStyle: UIActivityIndicatorView.Style {
        get { storedIndicatorStyle }
        set {
            storedIndicatorStyle = newValue
            storedLoadingView?.removeFromSuperview()
            storedLoadingView = nil
            setNeedsLayout()
        }
    }

    /**
     * [EN] Shown beside the text while there is no more data (flutter_easy_refresh's `ClassicFooter.noMoreIcon`).
     * [CN] 没有更多数据时显示在文字旁边（对应 flutter_easy_refresh 的 `ClassicFooter.noMoreIcon`）。
     */
    @objc open var noMoreDataImage: UIImage? {
        get { storedNoMoreDataImage }
        set {
            storedNoMoreDataImage = newValue
            updateNoMoreDataImage()
        }
    }

    // MARK: - Overrides

    /**
     * [EN] Picks the spinner style (medium from iOS 13, else gray). [CN] 选择菊花样式（iOS 13 起为 medium，否则为 gray）。
     */
    open override func prepare() {
        super.prepare()
        storedIndicatorStyle = .cyl_refreshDefault
    }

    /**
     * [EN] Puts the spinner beside the text and the no-more-data image. [CN] 把菊花放在文字旁边，并放置无更多数据图片。
     */
    open override func placeSubviews() {
        super.placeSubviews()
        placeNoMoreDataImage()

        if !loadingView.constraints.isEmpty { return }

        // 圈圈
        var loadingCenterX = cyl_w * 0.5
        if !isRefreshingTitleHidden {
            loadingCenterX -= (stateLabel?.cyl_textWidth() ?? 0) * 0.5 + labelLeftInset
        }
        let loadingCenterY = cyl_h * 0.5
        loadingView.center = CGPoint(x: loadingCenterX, y: loadingCenterY)
    }

    /**
     * [EN] Spins while loading. [CN] 加载时转动菊花。
     */
    open override var state: CYLRefreshState {
        get { super.state }
        set {
            // [EN] CYLRefreshCheckState. [CN] 即 CYLRefreshCheckState。
            let oldState = state
            if newValue == oldState { return }
            super.state = newValue
            updateNoMoreDataImage()

            // 根据状态做事情
            if newValue == .noMoreData || newValue == .idle {
                loadingView.stopAnimating()
            } else if newValue == .refreshing {
                loadingView.startAnimating()
            }
        }
    }

    // MARK: - No more data image

    // [EN] Shows noMoreDataImage beside the text only in the no-more-data state (one implementation in CYLRefreshFooter).
    // [CN] 仅在无更多数据状态时，在文字旁显示 noMoreDataImage（CYLRefreshFooter 中的统一实现）。
    private func updateNoMoreDataImage() {
        cyl_updateNoMoreDataImage(noMoreDataImage)
    }

    private func placeNoMoreDataImage() {
        cyl_placeNoMoreDataImage(besideLabel: stateLabel, inset: labelLeftInset, size: .zero)
    }
}
