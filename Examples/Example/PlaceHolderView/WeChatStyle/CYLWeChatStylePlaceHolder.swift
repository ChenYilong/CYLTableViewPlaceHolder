//
//  CYLWeChatStylePlaceHolder.swift
//  CYLTableViewPlaceHolder
//
//  Swift translation of WeChatStylePlaceHolder.h/.m:
//  Created by 陈宜龙 on 15/12/23.
//  Copyright © 2015年 http://weibo.com/luohanchenyilong/ 微博@iOS程序犭袁. All rights reserved.
//
//  [EN] A "WeChat-style" empty view: an image and a line of text; touching anywhere reloads. Changes in the
//  translation: localized text (CYLPlaceholderExample.strings), Dynamic Type, and VoiceOver (the whole view is one
//  button whose activation runs the same action as a touch); the geometry at the default text size is unchanged.
//  [CN] 仿微信风格的空白页：图片加一行文字，轻触任意位置重新加载。
//

import UIKit

/// Receives touches on the WeChat-style empty view.
protocol CYLWeChatStylePlaceHolderDelegate: AnyObject {
    func emptyOverlayClicked(_ sender: Any?)
}

final class CYLWeChatStylePlaceHolder: UIView {

    private static let labelX: CGFloat = 0
    private static let labelHeight: CGFloat = 20

    weak var delegate: CYLWeChatStylePlaceHolderDelegate?

    private let emptyOverlayImageView: UIImageView
    private let emptyOverlayLabel: UILabel

    override init(frame: CGRect) {
        emptyOverlayImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        emptyOverlayLabel = UILabel()
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder: NSCoder) {
        emptyOverlayImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        emptyOverlayLabel = UILabel()
        super.init(coder: coder)
        sharedInit()
    }

    private func sharedInit() {
        backgroundColor = .white
        contentMode = .top
        addEmptyOverlayImageView()
        addEmptyOverlayLabel()
        setupEmptyOverlay()
        setupAccessibility()
    }

    private func addEmptyOverlayImageView() {
        emptyOverlayImageView.center = CGPoint(x: frame.width / 2, y: frame.height / 2 - 100)
        emptyOverlayImageView.image = UIImage(named: "WebView_LoadFail_Refresh_Icon")
        addSubview(emptyOverlayImageView)
    }

    private func addEmptyOverlayLabel() {
        emptyOverlayLabel.textAlignment = .center
        emptyOverlayLabel.numberOfLines = 0
        emptyOverlayLabel.backgroundColor = .clear
        emptyOverlayLabel.text = CYLPlaceholderExampleLocalizedString(.weChatEmptyMessage)
        emptyOverlayLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: .boldSystemFont(ofSize: 15))
        emptyOverlayLabel.adjustsFontForContentSizeCategory = true
        emptyOverlayLabel.textColor = .gray
        layoutEmptyOverlayLabel()
        addSubview(emptyOverlayLabel)
    }

    /// The original frame (full width, 20 points high, 10 points below the image), taller when the text wraps.
    private func layoutEmptyOverlayLabel() {
        let width = frame.width
        let fitting = emptyOverlayLabel.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        emptyOverlayLabel.frame = CGRect(x: Self.labelX,
                                         y: emptyOverlayImageView.frame.maxY + 10,
                                         width: width,
                                         height: max(Self.labelHeight, ceil(fitting.height)))
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            layoutEmptyOverlayLabel()
        }
    }

    private func setupEmptyOverlay() {
        isUserInteractionEnabled = true
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressEmptyOverlay(_:)))
        longPress.minimumPressDuration = 0.001
        addGestureRecognizer(longPress)
    }

    private func setupAccessibility() {
        // One button: the text is its label, the image is decoration, activating it reloads like a touch.
        isAccessibilityElement = true
        accessibilityLabel = emptyOverlayLabel.text
        accessibilityTraits = .button
        emptyOverlayImageView.isAccessibilityElement = false
        emptyOverlayImageView.accessibilityElementsHidden = true
    }

    override func accessibilityActivate() -> Bool {
        delegate?.emptyOverlayClicked(nil)
        return true
    }

    @objc private func longPressEmptyOverlay(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            emptyOverlayImageView.alpha = 0.4
        case .ended:
            emptyOverlayImageView.alpha = 1
            delegate?.emptyOverlayClicked(nil)
        case .cancelled, .failed:
            emptyOverlayImageView.alpha = 1
        default:
            break
        }
    }
}
