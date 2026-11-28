//
//  CYLPlaceholderStatusView.swift
//  CYLTableViewPlaceHolder
//
//  [EN] Adapted from LCCKStatusView of CYLChatKit (https://github.com/ChenYilong/CYLChatKit, commit b730b8d,
//       ChatKit/Class/View/LCCKStatusView.m). Original header: "v2.1.1 Created by ElonChan on 16/3/11.
//       Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved." Repository license: MIT,
//       Copyright (c) 2016 LeanCloud (LICENSE.CYLChatKit in the resource bundle). The icon,
//       CYLPlaceholderStatusFail@2x/@3x.png, is ChatKit's MessageBubble.bundle/MessageSendFail, unmodified.
//       Swift since 2026-11-19 with the same Objective-C API; the delegate protocol, the height constants and the block
//       type stay in `CYLPlaceholderStatusView.h` / `CYLPlaceholderStatusViewSupport.m`.
//  [CN] 改编自 CYLChatKit 的 LCCKStatusView（MIT），保留原作者与版权信息；图标为 ChatKit 的 MessageSendFail，未修改。自 2026-11-19 起用
//       Swift 编写，Objective-C API 不变；代理协议、高度常量与回调类型保留在 `CYLPlaceholderStatusView.h` /
//       `CYLPlaceholderStatusViewSupport.m` 中。
//

import UIKit

// [EN] The icon is 28 points; ChatKit draws it at 20. [CN] 图标原始为 28 点；ChatKit 以 20 点绘制。
private let placeholderStatusIconInset: CGFloat = 4
// [EN] Space above and below the text when Dynamic Type makes it tall. [CN] 动态字体变大时文字上下的留白。
private let placeholderStatusVerticalPadding: CGFloat = 12

// [EN] ChatKit's pink, rgb(255, 199, 199); a dark red in Dark Mode. [CN] ChatKit 的粉红色；深色模式下为暗红色。
private func CYLPlaceholderStatusBackgroundColor() -> UIColor {
    let light = UIColor(red: 255 / 255.0, green: 199 / 255.0, blue: 199 / 255.0, alpha: 1)
    let dark = UIColor(red: 90 / 255.0, green: 30 / 255.0, blue: 30 / 255.0, alpha: 1)
    return UIColor { traits in traits.userInterfaceStyle == .dark ? dark : light }
}

// [EN] ChatKit used gray (about 3:1 on the pink); #555555 keeps the look and reaches 4.9:1 (WCAG AA). Light pink text in
//      Dark Mode. [CN] ChatKit 使用灰色（在粉红背景上约 3:1）；#555555 保持观感并达到 4.9:1（WCAG AA）。深色模式下为浅粉色文字。
private func CYLPlaceholderStatusTextColor() -> UIColor {
    let light = UIColor(white: 0x55 / 255.0, alpha: 1)
    let dark = UIColor(red: 242 / 255.0, green: 208 / 255.0, blue: 208 / 255.0, alpha: 1)
    return UIColor { traits in traits.userInterfaceStyle == .dark ? dark : light }
}

private func CYLStatusConfigurationError(_ description: String) -> NSError {
    NSError(domain: CYLPlaceholderConfigurationErrorDomain,
            code: CYLPlaceholderConfigurationError.Code.statusView.rawValue,
            userInfo: [NSLocalizedDescriptionKey: description])
}

/**
 * [EN] A one-line status bar on a red background (see `CYLPlaceholderStatusView.h`): the icon and the title are a
 *      horizontal CYLPlaceholderView on this view, which draws the red. Objective-C code imports the umbrella header.
 * [CN] 红色背景的单行状态提示条（见 `CYLPlaceholderStatusView.h`）：图标与标题是本视图上横向排列的 CYLPlaceholderView，红色由本视图
 *      绘制。Objective-C 代码请导入总头文件。
 */
@objc(CYLPlaceholderStatusView)
open class CYLPlaceholderStatusView: UIView {

    /**
     * [EN] Told about taps, as in CYLChatKit. [CN] 接收点击，与 CYLChatKit 相同。
     */
    @objc open weak var delegate: CYLPlaceholderStatusViewDelegate? {
        didSet { updateTapHandling() }
    }

    /**
     * [EN] The icon and the title, laid out horizontally; a subview filling the bar. [CN] 横向排列的图标与标题；铺满状态条的子视图。
     */
    @objc public let placeholderView: CYLPlaceholderView

    /**
     * [EN] Runs on a tap, after the delegate. With neither a handler nor a delegate, the bar is plain text for VoiceOver;
     *      with one, it is a button. [CN] 点击时在代理之后执行。没有处理也没有代理时，状态条对 VoiceOver 是普通文字；有其一时是按钮。
     */
    @objc open var tapHandler: ((CYLPlaceholderStatusView) -> Void)? {
        didSet { updateTapHandling() }
    }

    /**
     * [EN] The item attributes of the network bar, to start a custom one from. [CN] 网络提示条的 item 属性，可在此基础上自定义。
     */
    @objc open class var networkUnavailableItemAttributes: [String: Any] {
        var attributes = [String: Any]()
        attributes[CYLPlaceholderItemTitle] = CYLPlaceholderLocalizedStringForKey("CYLPlaceholderStatusNetworkUnavailable",
                                                                                  "Network unavailable, Check network")
        if let icon = UIImage(named: "CYLPlaceholderStatusFail", in: CYLPlaceholderResourceBundle(), compatibleWith: nil) {
            attributes[CYLPlaceholderItemImage] = icon
        }
        let inset = placeholderStatusIconInset
        attributes[CYLPlaceholderItemImageInsets] = NSValue(uiEdgeInsets: UIEdgeInsets(top: inset, left: inset,
                                                                                      bottom: inset, right: inset))
        attributes[CYLPlaceholderItemTitleColor] = CYLPlaceholderStatusTextColor()
        attributes[CYLPlaceholderItemTitleFont] = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 15))
        attributes[CYLPlaceholderItemBackgroundColor] = CYLPlaceholderStatusBackgroundColor()
        attributes[CYLPlaceholderItemContentAxis] = "horizontal"
        attributes[CYLPlaceholderItemAccessibilityIdentifier] = "CYLPlaceholderStatusView"
        return attributes
    }

    /**
     * [EN] The network bar of CYLChatKit: the failure icon and the localized "Network unavailable, Check network".
     * [CN] CYLChatKit 的网络提示条：失败图标与本地化的“当前网络不可用，请检查你的网络设置”。
     */
    public override convenience init(frame: CGRect) {
        // [EN] The network bar's attributes are valid. [CN] 网络提示条的属性总是有效。
        try! self.init(frame: frame, itemAttributes: CYLPlaceholderStatusView.networkUnavailableItemAttributes)
    }

    /**
     * [EN] A bar with its own icon and title: CYLPlaceholderView item attributes; missing keys take the network bar's
     *      values, and the layout is always horizontal. Throws when they are invalid.
     * [CN] 自定义图标与标题的状态条：CYLPlaceholderView 的 item 属性；缺少的键使用网络提示条的值，布局总是横向。属性无效时抛出错误。
     */
    @objc(initWithItemAttributes:error:)
    public convenience init(itemAttributes attributes: [String: Any]) throws {
        var merged = CYLPlaceholderStatusView.networkUnavailableItemAttributes
        merged.merge(attributes) { _, new in new }
        // [EN] A custom image or style replaces the failure icon and its insets. [CN] 自定义图片或样式替换失败图标及其内边距。
        if attributes[CYLPlaceholderItemImage] != nil || attributes[CYLPlaceholderItemStyle] != nil {
            if attributes[CYLPlaceholderItemImage] == nil { merged.removeValue(forKey: CYLPlaceholderItemImage) }
            if attributes[CYLPlaceholderItemImageInsets] == nil { merged.removeValue(forKey: CYLPlaceholderItemImageInsets) }
        }
        merged[CYLPlaceholderItemContentAxis] = "horizontal"
        try self.init(frame: CGRect(x: 0, y: 0, width: 0, height: CYLPlaceholderStatusViewHight), itemAttributes: merged)
    }

    /**
     * [EN] A bar from a configuration dictionary (JSON or property list): "text", "textKey", "image", "titleColor",
     *      "backgroundColor", "accessibilityIdentifier"; missing keys keep the network bar's values. Throws when a value
     *      is invalid. See docs/Status-Bar.md.
     * [CN] 根据配置字典（JSON 或属性列表）创建状态条；缺少的键使用网络提示条的值。值无效时抛出错误。见 docs/Status-Bar.md。
     */
    @nonobjc
    public convenience init(configuration: [String: Any]) throws {
        let keys = [
            "image": CYLPlaceholderItemImage, "titleColor": CYLPlaceholderItemTitleColor,
            "backgroundColor": CYLPlaceholderItemBackgroundColor,
            "accessibilityIdentifier": CYLPlaceholderItemAccessibilityIdentifier,
        ]
        var attributes = [String: Any]()
        for key in ["text", "textKey", "image", "titleColor", "backgroundColor", "accessibilityIdentifier"] {
            guard let value = configuration[key] else { continue }
            guard value is String else { throw CYLStatusConfigurationError("\"\(key)\" must be a string.") }
            if let attribute = keys[key] { attributes[attribute] = value }
        }
        var text = configuration["text"] as? String
        if let textKey = configuration["textKey"] as? String { text = CYLPlaceholderLocalizedStringForKey(textKey, text) }
        if let text = text { attributes[CYLPlaceholderItemTitle] = text }
        try self.init(itemAttributes: attributes)
    }

    /**
     * [EN] Objective-C: `-initWithConfiguration:error:`. It takes any object, as the Objective-C initializer did, so that
     *      a configuration that is not a dictionary returns the configuration error instead of failing in the Swift bridge.
     * [CN] Objective-C：`-initWithConfiguration:error:`。与原 Objective-C 初始化方法一样接受任意对象，配置不是字典时返回配置错误，
     *      而不是在 Swift 桥接时崩溃。
     */
    @objc(initWithConfiguration:error:)
    @available(swift, obsoleted: 1, message: "Use init(configuration:)")
    public convenience init(objcConfiguration configuration: Any) throws {
        guard let dictionary = configuration as? [String: Any] else {
            throw CYLStatusConfigurationError("The status bar configuration must be a dictionary.")
        }
        try self.init(configuration: dictionary)
    }

    /**
     * [EN] Not available: the bar is made in code. [CN] 不可用：状态条只在代码中创建。
     */
    @available(*, unavailable)
    public required convenience init?(coder: NSCoder) {
        self.init(frame: CGRect(x: 0, y: 0, width: 0, height: CYLPlaceholderStatusViewHight))
    }

    // [EN] The shared initializer. [CN] 共用的初始化方法。
    private init(frame: CGRect, itemAttributes attributes: [String: Any]) throws {
        var content = attributes
        // [EN] The red belongs to this view (the parent); the component on it is transparent.
        // [CN] 红色属于本视图（父视图）；其上的组件是透明的。
        let background = content[CYLPlaceholderItemBackgroundColor]
        content[CYLPlaceholderItemBackgroundColor] = UIColor.clear
        placeholderView = try CYLPlaceholderView(itemAttributes: content, imageBundle: nil)
        super.init(frame: frame)
        // [EN] As LCCKStatusView: the bar stretches with its superview's width. [CN] 与 LCCKStatusView 相同：随父视图宽度拉伸。
        autoresizingMask = .flexibleWidth
        backgroundColor = (background as? UIColor) ?? CYLPlaceholderStatusBackgroundColor()
        placeholderView.backgroundColor = .clear
        placeholderView.reportsContentSize = true
        placeholderView.frame = bounds
        placeholderView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        placeholderView.textLabel.adjustsFontForContentSizeCategory = true
        addSubview(placeholderView)
        updateTapHandling()
    }

    // MARK: - Text

    /**
     * [EN] The title shown; setting it updates the bar. [CN] 显示的文字；设置后更新状态条。
     */
    @objc open var text: String? {
        get { placeholderView.textLabel.text }
        set {
            placeholderView.textLabel.text = newValue
            placeholderView.invalidateIntrinsicContentSize()
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    // MARK: - Taps

    // [EN] Tappable only when someone listens, so VoiceOver does not offer a button that does nothing.
    // [CN] 只有在有人接收点击时才可点击，避免 VoiceOver 提供一个无效的按钮。
    private func updateTapHandling() {
        let selector = #selector(CYLPlaceholderStatusViewDelegate.statusViewClicked(_:))
        let listens = tapHandler != nil || (delegate?.responds(to: selector) ?? false)
        if !listens {
            placeholderView.tapHandler = nil
            return
        }
        placeholderView.tapHandler = { [weak self] _ in
            self?.handleTap()
        }
    }

    private func handleTap() {
        delegate?.statusViewClicked?(self)
        tapHandler?(self)
    }

    // MARK: - Layout

    open override var intrinsicContentSize: CGSize {
        var height = CYLPlaceholderStatusViewHight
        let content = placeholderView.intrinsicContentSize
        if content.height > 0 { height = max(height, ceil(content.height) + placeholderStatusVerticalPadding) }
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        CGSize(width: size.width, height: intrinsicContentSize.height)
    }

    open override func layoutSubviews() {
        let width = bounds.width
        if width > 0 && placeholderView.preferredMaxLayoutWidth != width {
            placeholderView.preferredMaxLayoutWidth = width
            invalidateIntrinsicContentSize()
        }
        super.layoutSubviews()
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            placeholderView.invalidateIntrinsicContentSize()
            invalidateIntrinsicContentSize()
        }
    }
}
