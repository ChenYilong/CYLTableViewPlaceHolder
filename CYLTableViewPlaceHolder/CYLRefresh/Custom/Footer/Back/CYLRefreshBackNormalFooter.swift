//
//  CYLRefreshBackNormalFooter.swift
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 9), with the same Objective-C API (`arrowView`,
//      `loadingView`, `noMoreDataImage`, `iconSize`, the deprecated `activityIndicatorViewStyle`) and the same arrow
//      rotation, spinner and layout. The class factories (`+footerWithRefreshingBlock:`, ...) are inherited and still
//      return a `CYLRefreshBackNormalFooter`.
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 9 步），Objective-C API（`arrowView`、`loadingView`、
//      `noMoreDataImage`、`iconSize`、已废弃的 `activityIndicatorViewStyle`）以及箭头旋转、菊花与布局均不变。类工厂方法
//      （`+footerWithRefreshingBlock:` 等）继承而来，仍返回 `CYLRefreshBackNormalFooter`。

import UIKit

/**
 * [EN] The standard back footer: the state text with an arrow that turns when releasing will load, and a spinner
 *      while loading.
 * [CN] 标准回弹刷新尾：状态文字，带有松手即加载时会转向的箭头，加载时显示菊花。
 */
@objc(CYLRefreshBackNormalFooter)
open class CYLRefreshBackNormalFooter: CYLRefreshBackStateFooter {

    // [EN] Weak, as the Objective-C ivars were not retained: the footer's subviews own the arrow and the spinner.
    // [CN] 弱引用，与 Objective-C 未持有的实例变量相同：箭头与菊花由刷新尾的子视图持有。
    private weak var storedArrowView: UIImageView?
    private weak var storedLoadingView: UIActivityIndicatorView?
    private var storedNoMoreDataImage: UIImage?
    private var storedIconSize: CGSize = .zero
    private var storedIndicatorStyle: UIActivityIndicatorView.Style = .cyl_refreshDefault

    // MARK: - Subviews, created on first access

    /**
     * [EN] The arrow beside the text (the bundle's `CYLRefreshArrow` image, template-rendered so it takes the tint
     *      color), created on first access.
     * [CN] 文字旁边的箭头（bundle 中的 `CYLRefreshArrow` 图片，按模板渲染从而使用 tintColor），首次访问时创建。
     */
    @objc open var arrowView: UIImageView {
        if let arrowView = storedArrowView { return arrowView }
        // [EN] System image view: MJRefresh's original arrow, kept unchanged by the owner's decision (the arrow controls keep
        //      MJRefresh's arrow logic and rotation), so CYLPlaceholderView is not used here.
        // [CN] 系统图片视图：MJRefresh 原有的箭头，按维护者决定保持原样（箭头控件保留 MJRefresh 的箭头逻辑与旋转），因此这里不使用 CYLPlaceholderView。
        let arrowView = UIImageView(image: Bundle.cyl_arrowImage())
        addSubview(arrowView)
        storedArrowView = arrowView
        return arrowView
    }

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

    /**
     * [EN] Size of the icon (the arrow and noMoreDataImage); CGSizeZero (default) uses the image's own size
     *      (flutter_easy_refresh's `iconDimension`). [CN] 图标（箭头与 noMoreDataImage）的尺寸；CGSizeZero（默认）表示使用图片自身尺寸
     *      （对应 flutter_easy_refresh 的 `iconDimension`）。
     */
    @objc open var iconSize: CGSize {
        get { storedIconSize }
        set {
            storedIconSize = newValue
            setNeedsLayout()
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
     * [EN] Puts the arrow and the spinner beside the text, and the no-more-data image. [CN] 把箭头与菊花放在文字旁边，并放置无更多数据图片。
     */
    open override func placeSubviews() {
        super.placeSubviews()
        placeNoMoreDataImage()

        // 箭头的中心点
        var arrowCenterX = cyl_w * 0.5
        if let stateLabel = stateLabel, !stateLabel.isHidden {
            arrowCenterX -= labelLeftInset + stateLabel.cyl_textWidth() * 0.5
        }
        let arrowCenterY = cyl_h * 0.5
        let arrowCenter = CGPoint(x: arrowCenterX, y: arrowCenterY)

        // 箭头
        if arrowView.constraints.isEmpty {
            let customSize = iconSize.width > 0 && iconSize.height > 0
            arrowView.cyl_size = customSize ? iconSize : (arrowView.image?.size ?? .zero)
            arrowView.center = arrowCenter
        }

        // 圈圈
        if loadingView.constraints.isEmpty {
            loadingView.center = arrowCenter
        }

        arrowView.tintColor = stateLabel?.textColor
    }

    /**
     * [EN] Turns the arrow when releasing will load and spins while loading.
     * [CN] 松手即加载时转动箭头，加载时转动菊花。
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
            if newValue == .idle {
                if oldState == .refreshing {
                    arrowView.transform = CGAffineTransform(rotationAngle: 0.000001 - .pi)
                    UIView.animate(withDuration: slowAnimationDuration, animations: {
                        self.loadingView.alpha = 0.0
                    }, completion: { _ in
                        // 防止动画结束后，状态已经不是CYLRefreshStateIdle
                        if self.state != .idle { return }

                        self.loadingView.alpha = 1.0
                        self.loadingView.stopAnimating()

                        self.arrowView.isHidden = false
                    })
                } else {
                    arrowView.isHidden = false
                    loadingView.stopAnimating()
                    UIView.animate(withDuration: fastAnimationDuration) {
                        self.arrowView.transform = CGAffineTransform(rotationAngle: 0.000001 - .pi)
                    }
                }
            } else if newValue == .pulling {
                arrowView.isHidden = false
                loadingView.stopAnimating()
                UIView.animate(withDuration: fastAnimationDuration) {
                    self.arrowView.transform = .identity
                }
            } else if newValue == .refreshing {
                arrowView.isHidden = true
                loadingView.startAnimating()
            } else if newValue == .noMoreData {
                arrowView.isHidden = true
                loadingView.stopAnimating()
            }
        }
    }

    /**
     * [EN] Also flips the arrow back. [CN] 同时把箭头翻转回来。
     */
    open override var flipsHorizontallyInOppositeLayoutDirectionViews: [UIView] {
        super.flipsHorizontallyInOppositeLayoutDirectionViews + [arrowView]
    }

    // MARK: - No more data image

    // [EN] Shows noMoreDataImage beside the text only in the no-more-data state (one implementation in CYLRefreshFooter).
    // [CN] 仅在无更多数据状态时，在文字旁显示 noMoreDataImage（CYLRefreshFooter 中的统一实现）。
    private func updateNoMoreDataImage() {
        cyl_updateNoMoreDataImage(noMoreDataImage)
    }

    private func placeNoMoreDataImage() {
        cyl_placeNoMoreDataImage(besideLabel: stateLabel, inset: labelLeftInset, size: iconSize)
    }
}
