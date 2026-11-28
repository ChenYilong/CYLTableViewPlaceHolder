//
//  CYLRefreshNormalTrailer.swift
//  CYLRefresh
//
//  Created by kinarobin on 2020/5/3.
//  Copyright © 2020 小码哥. All rights reserved.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 9), with the same Objective-C API (`arrowView`) and the
//      same arrow rotation and the vertical state text right of the arrow.
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 9 步），Objective-C API（`arrowView`）以及箭头旋转、箭头右侧的竖排
//      状态文字均不变。

import UIKit

/**
 * [EN] The standard trailer: the state text with an arrow.
 * [CN] 标准 trailer：状态文字带箭头。
 */
@objc(CYLRefreshNormalTrailer)
open class CYLRefreshNormalTrailer: CYLRefreshStateTrailer {

    // [EN] Weak, as the Objective-C ivar was not retained: the trailer's subviews own the arrow.
    // [CN] 弱引用，与 Objective-C 未持有的实例变量相同：箭头由 trailer 的子视图持有。
    private weak var storedArrowView: UIImageView?

    /**
     * [EN] The arrow beside the text (the bundle's `CYLRefreshTrailArrow` image, template-rendered so it takes the tint
     *      color), created on first access.
     * [CN] 文字旁边的箭头（bundle 中的 `CYLRefreshTrailArrow` 图片，按模板渲染从而使用 tintColor），首次访问时创建。
     */
    @objc open var arrowView: UIImageView {
        if let arrowView = storedArrowView { return arrowView }
        // [EN] System image view: MJRefresh's original arrow, kept unchanged by the owner's decision (the arrow controls keep
        //      MJRefresh's arrow logic and rotation), so CYLPlaceholderView is not used here.
        // [CN] 系统图片视图：MJRefresh 原有的箭头，按维护者决定保持原样（箭头控件保留 MJRefresh 的箭头逻辑与旋转），因此这里不使用 CYLPlaceholderView。
        let arrowView = UIImageView(image: Bundle.cylTrailArrowImage())
        addSubview(arrowView)
        storedArrowView = arrowView
        return arrowView
    }

    /**
     * [EN] Puts the arrow on the left and the vertical state text right of it. [CN] 把箭头放在左侧，竖排状态文字放在它右侧。
     */
    open override func placeSubviews() {
        super.placeSubviews()

        let arrowSize = arrowView.image?.size ?? .zero
        // 箭头的中心点
        let selfCenter = CGPoint(x: cylW * 0.5, y: cylH * 0.5)
        let arrowCenter = CGPoint(x: arrowSize.width * 0.5 + 5, y: cylH * 0.5)
        let stateHidden = stateLabel?.isHidden ?? true

        if arrowView.constraints.isEmpty {
            arrowView.cylSize = arrowSize
            arrowView.center = stateHidden ? selfCenter : arrowCenter
        }
        arrowView.tintColor = stateLabel?.textColor

        if stateHidden { return }

        // [EN] The state text is a vertical column right of the arrow, readable in every language.
        // [CN] 状态文字是箭头右侧的竖列，任何语言都可读。
        let arrowHidden = arrowView.isHidden
        let stateCenterX = (cylW + arrowSize.width) * 0.5
        let width = placeStateLabel(centerX: arrowHidden ? selfCenter.x : stateCenterX)
        // [EN] A wrapped column is wider: keep its left edge right of the arrow. [CN] 换行后竖列更宽：保持其左边缘在箭头右侧。
        let minX = arrowView.frame.maxX + 2
        if !arrowHidden && stateCenterX - width * 0.5 < minX { placeStateLabel(centerX: minX + width * 0.5) }
    }

    /**
     * [EN] Turns the arrow when releasing will trigger. [CN] 松手即触发时转动箭头。
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
                    UIView.animate(withDuration: fastAnimationDuration, animations: {
                        self.arrowView.transform = CGAffineTransform(rotationAngle: .pi)
                    }, completion: { _ in
                        self.arrowView.transform = .identity
                    })
                } else {
                    UIView.animate(withDuration: fastAnimationDuration) {
                        self.arrowView.transform = .identity
                    }
                }
            } else if newValue == .pulling {
                UIView.animate(withDuration: fastAnimationDuration) {
                    self.arrowView.transform = CGAffineTransform(rotationAngle: .pi)
                }
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
