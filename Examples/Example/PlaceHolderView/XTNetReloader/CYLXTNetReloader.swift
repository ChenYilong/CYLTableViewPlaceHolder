//
//  CYLXTNetReloader.swift
//  CYLTableViewPlaceHolder
//
//  Swift translation of XTNetReloader.h/.m:
//  Created by TuTu on 15/12/8.
//  Copyright © 2015年 teason. All rights reserved.
//
//  [EN] Credit: XTNetReloader is TuTu's (teason) "Taobao-style" network reload view; the original copyright above stays
//  with its author. The type carries the CYL prefix only to follow this repository's naming rules. Changes in the
//  translation: localized text (CYLPlaceholderExample.strings), Dynamic Type, VoiceOver and leading/trailing-neutral
//  centered layout; the geometry at the default text size is unchanged.
//  [CN] 致谢：XTNetReloader 由 TuTu（teason）编写，版权归原作者所有；类名加 CYL 前缀仅为遵循本仓库命名规则。
//

import UIKit

/// A "network is unstable" view with a reload button, shown as the Taobao-style placeholder.
final class CYLXTNetReloader: UIView {

    typealias ReloadButtonClickBlock = () -> Void

    private static let noWifiViewSize = CGSize(width: 200, height: 150)
    private static let labelSize = CGSize(width: 300, height: 35)
    private static let labelFontSize: CGFloat = 17
    private static let labelButtonSpacing: CGFloat = 10
    private static let buttonSize = CGSize(width: 100, height: 30)
    private static let buttonFontSize: CGFloat = 15

    private let noWifiImageView: UIImageView
    private let messageLabel: UILabel
    private let reloadButton: UIButton
    private let reloadButtonClickBlock: ReloadButtonClickBlock

    init(frame: CGRect, reloadBlock: @escaping ReloadButtonClickBlock) {
        reloadButtonClickBlock = reloadBlock
        noWifiImageView = UIImageView(image: UIImage(named: "no-wifi"))
        messageLabel = UILabel()
        reloadButton = UIButton(type: .custom)
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable, message: "Use init(frame:reloadBlock:)")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; use init(frame:reloadBlock:)")
    }

    func show(in viewWillShow: UIView) {
        viewWillShow.addSubview(self)
    }

    func dismiss() {
        removeFromSuperview()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let width = bounds.width
        // At the default text size these are the original fixed sizes; larger Dynamic Type sizes grow them.
        let labelHeight = max(Self.labelSize.height,
                              ceil(messageLabel.sizeThatFits(CGSize(width: Self.labelSize.width,
                                                                    height: .greatestFiniteMagnitude)).height))
        let buttonFit = reloadButton.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        let buttonSize = CGSize(width: max(Self.buttonSize.width, ceil(buttonFit.width) + 16),
                                height: max(Self.buttonSize.height, ceil(buttonFit.height)))

        var wifiRect = CGRect(origin: .zero, size: Self.noWifiViewSize)
        wifiRect.origin.x = (width - Self.noWifiViewSize.width) / 2
        wifiRect.origin.y = (bounds.height - Self.noWifiViewSize.height - labelHeight
                             - Self.labelButtonSpacing - buttonSize.height) / 2
        noWifiImageView.frame = wifiRect

        let labelRect = CGRect(x: (width - Self.labelSize.width) / 2, y: wifiRect.maxY,
                               width: Self.labelSize.width, height: labelHeight)
        messageLabel.frame = labelRect

        reloadButton.frame = CGRect(x: (width - buttonSize.width) / 2,
                                    y: labelRect.maxY + Self.labelButtonSpacing,
                                    width: buttonSize.width, height: buttonSize.height)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            setNeedsLayout()
        }
    }

    private func setup() {
        backgroundColor = .white
        shouldGroupAccessibilityChildren = true

        noWifiImageView.contentMode = .scaleAspectFit
        // Decoration: the label below says what happened.
        noWifiImageView.isAccessibilityElement = false
        noWifiImageView.accessibilityElementsHidden = true
        addSubview(noWifiImageView)

        messageLabel.text = CYLPlaceholderExampleLocalizedString(.netReloaderMessage)
        messageLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: .boldSystemFont(ofSize: Self.labelFontSize))
        messageLabel.adjustsFontForContentSizeCategory = true
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.textColor = .darkGray
        addSubview(messageLabel)

        reloadButton.setTitle(CYLPlaceholderExampleLocalizedString(.netReloaderReload), for: .normal)
        reloadButton.setTitleColor(.darkGray, for: .normal)
        reloadButton.titleLabel?.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: Self.buttonFontSize))
        reloadButton.titleLabel?.adjustsFontForContentSizeCategory = true
        reloadButton.layer.cornerRadius = 5
        reloadButton.layer.borderWidth = 1
        reloadButton.layer.borderColor = UIColor.darkGray.cgColor
        reloadButton.addTarget(self, action: #selector(reloadButtonClicked), for: .touchUpInside)
        addSubview(reloadButton)
    }

    @objc private func reloadButtonClicked() {
        reloadButtonClickBlock()
    }
}
