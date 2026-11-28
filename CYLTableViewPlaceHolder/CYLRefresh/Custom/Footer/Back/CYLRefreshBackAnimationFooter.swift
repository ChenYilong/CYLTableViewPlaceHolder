//
//  CYLRefreshBackAnimationFooter.swift
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24 (as MJRefresh's MJRefreshBackGifFooter; renamed and generalized for CYLRefresh).
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 9), with the same Objective-C API (`animationView`,
//      `setAnimationImages:duration:forState:`, `setAnimationImages:forState:`, the `CYLRefreshIconAnimating`
//      conformance) and the same layout. `CYLRefreshBackGifFooter` (the MJRefresh name) is its Swift subclass.
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 9 步），Objective-C API（`animationView`、
//      `setAnimationImages:duration:forState:`、`setAnimationImages:forState:`、`CYLRefreshIconAnimating` 协议）与布局均不变。
//      `CYLRefreshBackGifFooter`（MJRefresh 的名字）是它的 Swift 子类。

import UIKit

/**
 * [EN] Animated images (`setAnimationImages:forState:`), or an icon animation (GIF, Lottie, PAG or Rive) through
 *      `CYLRefreshIconAnimating`, which takes the animation view's place with the same layout.
 * [CN] 动画图片（`setAnimationImages:forState:`），或通过 `CYLRefreshIconAnimating` 设置的图标动画（GIF、Lottie、PAG、Rive），后者以相同布局替换动画视图。
 */
@objc(CYLRefreshBackAnimationFooter)
open class CYLRefreshBackAnimationFooter: CYLRefreshBackStateFooter, CYLRefreshIconAnimating {

    // [EN] Weak, as the Objective-C ivar was not retained: the footer's subviews own it.
    // [CN] 弱引用，与 Objective-C 未持有的实例变量相同：由刷新尾的子视图持有。
    private weak var storedAnimationView: UIImageView?

    // MARK: - CYLRefreshIconAnimating

    /**
     * [EN] The icon view (`refreshIconView`). [CN] 图标视图（`refreshIconView`）。
     */
    @objc open var iconView: CYLRefreshIconView {
        refreshIconView
    }

    /**
     * [EN] Whether an icon animation replaces the animation view (`usesRefreshIconView`).
     * [CN] 是否由图标动画代替动画视图（`usesRefreshIconView`）。
     */
    @objc open var usesIconView: Bool {
        usesRefreshIconView
    }

    /**
     * [EN] Sets the icon animation attributes of `state` and returns the footer. [CN] 设置 `state` 的图标动画属性，并返回刷新尾。
     */
    @discardableResult
    @objc(setIconAnimationAttributes:forState:)
    open func setIconAnimation(attributes: [String: Any]?, for state: CYLRefreshState) -> Self {
        applyIconAnimation(attributes: attributes, for: state)
        return self
    }

    /**
     * [EN] Plays the animation file at `filePath` in `state` and returns the footer. [CN] 在 `state` 播放 `filePath` 的动画文件，并返回刷新尾。
     */
    @discardableResult
    @objc(setIconAnimationFilePath:size:forState:)
    open func setIconAnimation(filePath: String, size: CGSize, for state: CYLRefreshState) -> Self {
        applyIconAnimation(filePath: filePath, size: size, for: state)
        return self
    }

    /**
     * [EN] Plays the bundled icon `fileName` in `state` and returns the footer. [CN] 在 `state` 播放内置图标 `fileName`，并返回刷新尾。
     */
    @discardableResult
    @objc(setBundledIconAnimation:size:forState:)
    open func setIconAnimation(bundled fileName: String, size: CGSize, for state: CYLRefreshState) -> Self {
        setBundledIconAnimation(fileName, size: size, for: state)
        return self
    }

    /**
     * [EN] The bundled icon animations (`CYLRefreshIconView.bundledAnimationFileNames`).
     * [CN] 内置的图标动画（`CYLRefreshIconView.bundledAnimationFileNames`）。
     */
    @objc open class var bundledIconAnimationFileNames: [String] {
        CYLRefreshIconView.bundledAnimationFileNames
    }

    // MARK: - Animation view, created on first access

    /**
     * [EN] The image view that plays the per-state images. [CN] 播放各状态动画图片的图片视图。
     */
    @objc open var animationView: UIImageView {
        if let animationView = storedAnimationView { return animationView }
        // [EN] System image view: public API (`animationView`, `gifView`) kept for source compatibility. It stays hidden; the
        //      images are drawn by the icon's CYLPlaceholderView (`-cyl_setIconImages:duration:forState:`).
        // [CN] 系统图片视图：为源码兼容保留的公开接口（`animationView`、`gifView`），始终隐藏；图片由图标的 CYLPlaceholderView 绘制
        //      （`-cyl_setIconImages:duration:forState:`）。
        let animationView = UIImageView()
        addSubview(animationView)
        storedAnimationView = animationView
        return animationView
    }

    // MARK: - Images

    /**
     * [EN] Sets the images of `state`, played in `duration` seconds; a single image is shown still. The control grows to
     *      the first image's height. [CN] 设置 `state` 状态的动画图片，在 `duration` 秒内播放一遍；只有一张时静止显示。控件高度随第一张图片增大。
     */
    @discardableResult
    @objc(setAnimationImages:duration:forState:)
    open func setAnimationImages(_ images: [UIImage], duration: TimeInterval, for state: CYLRefreshState) -> Self {
        // [EN] One implementation for the animation header and footers (CYLRefreshComponent): the images are drawn by the
        //      icon's CYLPlaceholderView; `animationView` stays for compatibility and is hidden.
        // [CN] 动画刷新头与尾部共用一个实现（CYLRefreshComponent）：图片由图标的 CYLPlaceholderView 绘制；`animationView` 为兼容保留并隐藏。
        applyAnimationImages(images, duration: duration, for: state)
        return self
    }

    /**
     * [EN] The same, 0.1 seconds per image. [CN] 同上，每张图片 0.1 秒。
     */
    @discardableResult
    @objc(setAnimationImages:forState:)
    open func setAnimationImages(_ images: [UIImage], for state: CYLRefreshState) -> Self {
        setAnimationImages(images, duration: Double(images.count) * 0.1, for: state)
    }

    // MARK: - Overrides

    /**
     * [EN] Sets the spacing between the images and the text. [CN] 设置图片与文字的间距。
     */
    open override func prepare() {
        super.prepare()

        // 初始化间距
        labelLeftInset = 20
    }

    /**
     * [EN] Shows the idle frame for the pull. [CN] 显示与上拉距离对应的空闲帧。
     */
    open override var pullingPercent: CGFloat {
        get { super.pullingPercent }
        set {
            super.pullingPercent = newValue
            showIdleAnimationFrame()
        }
    }

    /**
     * [EN] Puts the animation view (or the icon with the state text) beside the text; hidden without more data.
     * [CN] 把动画视图（或带状态文字的图标）放在文字旁边；没有更多数据时隐藏。
     */
    open override func placeSubviews() {
        super.placeSubviews()

        if !animationView.constraints.isEmpty { return }

        animationView.frame = bounds
        let stateHidden = stateLabel?.isHidden ?? true
        if stateHidden {
            animationView.contentMode = .center
        } else {
            animationView.contentMode = .right
            animationView.cylW = cylW * 0.5 - labelLeftInset - (stateLabel?.cylTextWidth() ?? 0) * 0.5
        }
        // [EN] An icon animation takes the animation view's place (centered or next to the text) and hides with it.
        // [CN] 图标动画替换 动画视图（居中或紧挨文字），并与其一同隐藏。
        // [EN] The state text goes into the icon's CYLPlaceholderView, so icon and text are one centered view.
        // [CN] 状态文字放进图标的 CYLPlaceholderView，图标与文字是一个整体并居中。
        placeIconView(title: stateHidden ? nil : stateLabel?.text, labels: [stateLabel].compactMap { $0 },
                          visible: state != .noMoreData, replacing: [animationView])
    }

    /**
     * [EN] Back to idle shows the frame for the current pull; the icon hides without more data.
     * [CN] 回到空闲时显示与当前上拉距离对应的帧；没有更多数据时隐藏图标。
     */
    open override var state: CYLRefreshState {
        get { super.state }
        set {
            // [EN] CYLRefreshCheckState. [CN] 即 CYLRefreshCheckState。
            let oldState = state
            if newValue == oldState { return }
            super.state = newValue

            if newValue == .idle {
                showIdleAnimationFrame()
            }
            setNeedsLayout()
            updateIconView(visible: newValue != .noMoreData, replacing: [animationView])
        }
    }

    /**
     * [EN] Also flips the animation view back. [CN] 同时把动画视图翻转回来。
     */
    open override var flipsHorizontallyInOppositeLayoutDirectionViews: [UIView] {
        super.flipsHorizontallyInOppositeLayoutDirectionViews + [animationView]
    }
}
