//
//  CYLRefreshNormalHeader.swift
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 9), with the same Objective-C API (`arrowView`, `iconSize`,
//      `loadingView`, the deprecated `activityIndicatorViewStyle`) and the same arrow rotation, spinner and layout. The
//      class factories (`+headerWithRefreshingBlock:`, `+headerWithRefreshingTarget:refreshingAction:`) are inherited
//      and still return a `CYLRefreshNormalHeader`.
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 9 步），Objective-C API（`arrowView`、`iconSize`、`loadingView`、
//      已废弃的 `activityIndicatorViewStyle`）以及箭头旋转、菊花与布局均不变。类工厂方法（`+headerWithRefreshingBlock:`、
//      `+headerWithRefreshingTarget:refreshingAction:`）继承而来，仍返回 `CYLRefreshNormalHeader`。

import UIKit

extension UIActivityIndicatorView.Style {

    // [EN] The spinner style of the refresh controls: medium. [CN] 刷新控件的菊花样式：medium。
    static var cyl_refreshDefault: UIActivityIndicatorView.Style {
        return .medium
    }
}

/**
 * [EN] The standard header: the state and last-updated texts with an arrow that turns when releasing will refresh,
 *      and a spinner while refreshing.
 * [CN] 标准刷新头：状态文字与最后更新时间，带有松手即刷新时会转向的箭头，刷新时显示菊花。
 */
@objc(CYLRefreshNormalHeader)
open class CYLRefreshNormalHeader: CYLRefreshStateHeader {

    // [EN] Weak, as the Objective-C ivar was not retained: the header's subviews own the arrow and the spinner.
    // [CN] 弱引用，与 Objective-C 未持有的实例变量相同：箭头与菊花由刷新头的子视图持有。
    private weak var storedArrowView: UIImageView?
    private weak var storedLoadingView: UIActivityIndicatorView?
    private var storedIconSize: CGSize = .zero
    private var storedIndicatorStyle: UIActivityIndicatorView.Style = .cyl_refreshDefault

    // MARK: - Subviews, created on first access

    /**
     * [EN] The arrow beside the texts (the bundle's `CYLRefreshArrow` image, template-rendered so it takes the tint
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
     * [EN] The spinner shown while refreshing, created on first access and hidden when stopped; style it here.
     * [CN] 刷新时显示的菊花，首次访问时创建，停止时隐藏；可在此设置样式。
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
     * [EN] Size of the icon (the arrow); CGSizeZero (default) uses the image's own size
     *      (flutter_easy_refresh's `iconDimension`). [CN] 图标（箭头）的尺寸；CGSizeZero（默认）表示使用图片自身尺寸
     *      （对应 flutter_easy_refresh 的 `iconDimension`）。
     */
    @objc open var iconSize: CGSize {
        get { storedIconSize }
        set {
            storedIconSize = newValue
            setNeedsLayout()
        }
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

    // MARK: - Overrides

    /**
     * [EN] Picks the spinner style (medium). [CN] 选择菊花样式（medium）。
     */
    open override func prepare() {
        super.prepare()
        storedIndicatorStyle = .cyl_refreshDefault
    }

    /**
     * [EN] Puts the arrow and the spinner beside the texts. [CN] 把箭头与菊花放在文字旁边。
     */
    open override func placeSubviews() {
        super.placeSubviews()

        // 箭头的中心点
        var arrowCenterX = cyl_w * 0.5
        if let stateLabel = stateLabel, !stateLabel.isHidden {
            let stateWidth = stateLabel.cyl_textWidth()
            var timeWidth: CGFloat = 0.0
            if let timeLabel = lastUpdatedTimeLabel, !timeLabel.isHidden {
                timeWidth = timeLabel.cyl_textWidth()
            }
            let textWidth = max(stateWidth, timeWidth)
            // [EN] iconOnTrailingSide (default NO) puts the arrow after the text. [CN] iconOnTrailingSide（默认 NO）把箭头放到文字后面。
            if iconOnTrailingSide {
                arrowCenterX += textWidth / 2 + labelLeftInset
            } else {
                arrowCenterX -= textWidth / 2 + labelLeftInset
            }
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
     * [EN] Turns the arrow when releasing will refresh and spins while refreshing.
     * [CN] 松手即刷新时转动箭头，刷新时转动菊花。
     */
    open override var state: CYLRefreshState {
        get { super.state }
        set {
            // [EN] CYLRefreshCheckState. [CN] 即 CYLRefreshCheckState。
            let oldState = state
            if newValue == oldState { return }
            super.state = newValue

            // 根据状态做事情
            if newValue == .idle {
                if oldState == .refreshing {
                    arrowView.transform = .identity

                    UIView.animate(withDuration: slowAnimationDuration, animations: {
                        self.loadingView.alpha = 0.0
                    }, completion: { _ in
                        // 如果执行完动画发现不是idle状态，就直接返回，进入其他状态
                        if self.state != .idle { return }

                        self.loadingView.alpha = 1.0
                        self.loadingView.stopAnimating()
                        self.arrowView.isHidden = false
                    })
                } else {
                    loadingView.stopAnimating()
                    arrowView.isHidden = false
                    UIView.animate(withDuration: fastAnimationDuration) {
                        self.arrowView.transform = .identity
                    }
                }
            } else if newValue == .pulling {
                loadingView.stopAnimating()
                arrowView.isHidden = false
                UIView.animate(withDuration: fastAnimationDuration) {
                    self.arrowView.transform = CGAffineTransform(rotationAngle: 0.000001 - .pi)
                }
            } else if newValue == .refreshing {
                // 防止refreshing -> idle的动画完毕动作没有被执行
                loadingView.alpha = 1.0
                loadingView.startAnimating()
                arrowView.isHidden = true
            }
        }
    }

    /**
     * [EN] Also flips the arrow back. [CN] 同时把箭头翻转回来。
     */
    open override var flipsHorizontallyInOppositeLayoutDirectionViews: [UIView] {
        super.flipsHorizontallyInOppositeLayoutDirectionViews + [arrowView]
    }
}
