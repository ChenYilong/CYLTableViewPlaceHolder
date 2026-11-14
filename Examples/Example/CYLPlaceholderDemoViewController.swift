//
//  CYLPlaceholderDemoViewController.swift
//  CYLTableViewPlaceHolder
//
//  [EN] Swift translation of CYLPlaceholderDemoViewController.h/.m.
//  - CYLPlaceholderDemoViewController: automatic placeholders for a table and a collection view (issue #11):
//    Clear shows the placeholder, + removes it, Disable/Enable turns the block API off and on.
//  - CYLPlaceholderStyleDemoViewController ("Styles"): every bundled style, a custom image, the FlatDesign item from
//    code and from CYLPlaceholderExample.bundle/CYLPlaceholderItemDemo.plist, and dot, number and text badges.
//  - CYLPlaceholderMessageDemoViewController: every bundled message, or custom text, for the chosen style.
//  [CN] CYLPlaceholderDemoViewController.h/.m 的 Swift 版本：表格与集合视图的自动占位图（#11）、样式、FlatDesign 项、
//  角标和文案预览。
//

import UIKit
import CYLTableViewPlaceHolder

private let placeholderStyleCount = CYLPlaceholderStyle.count.rawValue
private let placeholderMessageCount = CYLPlaceholderMessage.count.rawValue

private extension UIViewController {

    /// Pushes a plain screen that shows `placeholder` filling its view.
    func cyl_pushPreview(of placeholder: UIView, title: String) {
        let preview = UIViewController()
        preview.title = title
        preview.view.backgroundColor = .white
        placeholder.frame = preview.view.bounds
        placeholder.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        preview.view.addSubview(placeholder)
        navigationController?.pushViewController(preview, animated: true)
    }

    func cyl_showConfigurationError(_ message: String) {
        let alert = UIAlertController(title: CYLPlaceholderExampleLocalizedString(.titleConfigurationError),
                                      message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: CYLPlaceholderExampleLocalizedString(.actionOK), style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Styles

final class CYLPlaceholderStyleDemoViewController: UITableViewController {

    private static let cellIdentifier = "style"
    /// Rows after the bundled styles, in order.
    private static let extras: [CYLPlaceholderExampleL10n] = [
        .styleCustomImage, .styleFlatDesignCode, .styleFlatDesignPlist,
        .styleBadgeDot, .styleBadgeNumber, .styleBadgeText,
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = CYLPlaceholderExampleLocalizedString(.titleStyles)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        placeholderStyleCount + Self.extras.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier)
            ?? UITableViewCell(style: .default, reuseIdentifier: Self.cellIdentifier)
        let row = indexPath.row
        if row < placeholderStyleCount, let style = CYLPlaceholderStyle(rawValue: row) {
            // The bundled image name is a technical identifier and stays as it is.
            cell.textLabel?.text = CYLPlaceholderView.imageName(for: style)
            cell.imageView?.image = CYLPlaceholderView.image(for: style)
        } else {
            cell.textLabel?.text = CYLPlaceholderExampleLocalizedString(Self.extras[row - placeholderStyleCount])
            cell.imageView?.image = nil
        }
        cell.textLabel?.numberOfLines = 0
        cell.imageView?.tintColor = .gray
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        if row >= placeholderStyleCount + 3 {
            showBadgePreview(badgeIndex: row - placeholderStyleCount - 3)
            return
        }
        if row > placeholderStyleCount {
            showFlatDesignItem(fromPropertyList: row != placeholderStyleCount + 1)
            return
        }
        let next = CYLPlaceholderMessageDemoViewController(style: .plain)
        next.customImage = row == placeholderStyleCount
        next.placeholderStyle = next.customImage ? .empty : (CYLPlaceholderStyle(rawValue: row) ?? .empty)
        navigationController?.pushViewController(next, animated: true)
    }

    private func showBadgePreview(badgeIndex: Int) {
        let placeholder = CYLPlaceholderView(style: .notificationsOff, message: .noNotifications)
        switch badgeIndex {
        case 0: _ = placeholder.showBadge(with: .dot, value: nil)
        case 1: _ = placeholder.showBadge(with: .number, value: "105")
        case 2: _ = placeholder.showBadge(with: .text, value: CYLPlaceholderExampleLocalizedString(.badgeNew))
        default: break
        }
        cyl_pushPreview(of: placeholder, title: CYLPlaceholderExampleLocalizedString(.titleBadgePreview))
    }

    private func showFlatDesignItem(fromPropertyList: Bool) {
        let placeholder: CYLPlaceholderView
        do {
            if fromPropertyList {
                // [EN] The demo's configuration lives in the example's own bundle, not in the library's core bundle.
                // [CN] 演示配置放在示例自己的 bundle 中，而不是本库的核心 bundle。
                let fileName = "CYLPlaceholderItemDemo.plist"
                guard let url = CYLPlaceholderExampleResourceURL(fileName) else {
                    cyl_showConfigurationError(CYLPlaceholderExampleLocalizedFormat(.formatMissingFile, fileName))
                    return
                }
                placeholder = try CYLPlaceholderView(itemContentsOf: url, imageBundle: nil)
            } else {
                let attributes: [String: Any] = [
                    CYLPlaceholderItemStyle: CYLPlaceholderStyle.warning.rawValue,
                    CYLPlaceholderItemMessage: CYLPlaceholderMessage.error.rawValue,
                    CYLPlaceholderItemImagePositionAdjustment: [8, -6],
                    CYLPlaceholderItemTitlePositionAdjustment: [0, 6],
                    CYLPlaceholderItemAnimationFilePath: "reserved-animation.json",
                ]
                placeholder = try CYLPlaceholderView(itemAttributes: attributes, imageBundle: nil)
            }
        } catch {
            cyl_showConfigurationError(error.localizedDescription)
            return
        }
        cyl_pushPreview(of: placeholder, title: CYLPlaceholderExampleLocalizedString(.titleFlatDesignItem))
    }
}

// MARK: - Messages

final class CYLPlaceholderMessageDemoViewController: UITableViewController {

    private static let cellIdentifier = "message"

    var placeholderStyle: CYLPlaceholderStyle = .empty
    var customImage = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = CYLPlaceholderExampleLocalizedString(.titleChooseMessage)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        placeholderMessageCount + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier)
            ?? UITableViewCell(style: .default, reuseIdentifier: Self.cellIdentifier)
        if indexPath.row == placeholderMessageCount {
            cell.textLabel?.text = CYLPlaceholderExampleLocalizedString(.customText)
        } else {
            cell.textLabel?.text = CYLPlaceholderMessage(rawValue: indexPath.row)
                .flatMap { CYLPlaceholderView.localizedText(for: $0) }
        }
        cell.textLabel?.numberOfLines = 0
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row != placeholderMessageCount else {
            askForCustomText()
            return
        }
        let message = CYLPlaceholderMessage(rawValue: indexPath.row) ?? .empty
        showPreview(text: CYLPlaceholderView.localizedText(for: message), message: message)
    }

    private func askForCustomText() {
        let alert = UIAlertController(title: CYLPlaceholderExampleLocalizedString(.customText),
                                      message: nil, preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = CYLPlaceholderExampleLocalizedString(.customTextPlaceholder)
        }
        alert.addAction(UIAlertAction(title: CYLPlaceholderExampleLocalizedString(.actionCancel), style: .cancel))
        alert.addAction(UIAlertAction(title: CYLPlaceholderExampleLocalizedString(.actionPreview),
                                      style: .default) { [weak self, weak alert] _ in
            self?.showPreview(text: alert?.textFields?.first?.text, message: .count)
        })
        present(alert, animated: true)
    }

    /// `message == .count` means custom text.
    private func showPreview(text: String?, message: CYLPlaceholderMessage) {
        let placeholder: CYLPlaceholderView
        if customImage {
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 80, height: 80))
            let image = renderer.image { _ in
                UIColor.blue.setFill()
                UIBezierPath(ovalIn: CGRect(x: 8, y: 8, width: 64, height: 64)).fill()
            }
            placeholder = CYLPlaceholderView(image: image, text: text)
        } else if message == .count {
            placeholder = CYLPlaceholderView(style: placeholderStyle, text: text)
        } else {
            placeholder = CYLPlaceholderView(style: placeholderStyle, message: message)
        }
        cyl_pushPreview(of: placeholder, title: CYLPlaceholderExampleLocalizedString(.actionPreview))
    }
}

// MARK: - Automatic placeholder (issue #11)

final class CYLPlaceholderDemoViewController: UIViewController, UITableViewDataSource, UICollectionViewDataSource {

    private static let cellIdentifier = "cell"

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        return tableView
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: CYLPlaceholderDemoViewController.cellIdentifier)
        return collectionView
    }()

    private var count = 0
    private var placeholderEnabled = true

    override func viewDidLoad() {
        super.viewDidLoad()
        title = CYLPlaceholderExampleLocalizedString(.titleAutomatic)
        view.backgroundColor = .white

        let mode = UISegmentedControl(items: [CYLPlaceholderExampleLocalizedString(.modeTable),
                                              CYLPlaceholderExampleLocalizedString(.modeCollection)])
        mode.selectedSegmentIndex = 0
        mode.accessibilityLabel = CYLPlaceholderExampleLocalizedString(.modeLabel)
        mode.addTarget(self, action: #selector(changeMode(_:)), for: .valueChanged)
        navigationItem.titleView = mode
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: CYLPlaceholderExampleLocalizedString(.actionStyles),
                                                           style: .plain, target: self, action: #selector(showStyles))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem)),
            UIBarButtonItem(title: CYLPlaceholderExampleLocalizedString(.actionClear), style: .plain,
                            target: self, action: #selector(clearItems)),
            UIBarButtonItem(title: CYLPlaceholderExampleLocalizedString(.actionDisable), style: .plain,
                            target: self, action: #selector(togglePlaceholder(_:))),
        ]

        view.addSubview(tableView)
        collectionView.isHidden = true
        view.addSubview(collectionView)

        placeholderEnabled = true
        enablePlaceholder()
        tableView.reloadData()
        collectionView.reloadData()
    }

    @objc private func showStyles() {
        let styles = CYLPlaceholderStyleDemoViewController(style: .plain)
        navigationController?.pushViewController(styles, animated: true)
    }

    private func enablePlaceholder() {
        tableView.cyl_placeholderViewBlock({ _ in
            CYLPlaceholderView()
        })
        collectionView.cyl_placeholderViewBlock({ _ in
            CYLPlaceholderView()
        })
    }

    @objc private func togglePlaceholder(_ sender: UIBarButtonItem) {
        placeholderEnabled.toggle()
        sender.title = CYLPlaceholderExampleLocalizedString(placeholderEnabled ? .actionDisable : .actionEnable)
        if placeholderEnabled {
            enablePlaceholder()
        } else {
            tableView.cyl_placeholderViewBlock(nil)
            collectionView.cyl_placeholderViewBlock(nil)
        }
    }

    @objc private func changeMode(_ sender: UISegmentedControl) {
        tableView.isHidden = sender.selectedSegmentIndex != 0
        collectionView.isHidden = sender.selectedSegmentIndex == 0
    }

    @objc private func addItem() {
        let index = count
        count += 1
        tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        collectionView.insertItems(at: [IndexPath(item: index, section: 0)])
    }

    @objc private func clearItems() {
        count = 0
        tableView.reloadData()
        collectionView.reloadData()
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier)
            ?? UITableViewCell(style: .default, reuseIdentifier: Self.cellIdentifier)
        cell.textLabel?.text = CYLPlaceholderExampleLocalizedFormat(.formatItem, indexPath.row + 1)
        return cell
    }

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.cellIdentifier, for: indexPath)
        cell.backgroundColor = .lightGray
        // Each square is one element that reads its item number, like the table rows.
        cell.isAccessibilityElement = true
        cell.accessibilityLabel = CYLPlaceholderExampleLocalizedFormat(.formatItem, indexPath.row + 1)
        return cell
    }
}
