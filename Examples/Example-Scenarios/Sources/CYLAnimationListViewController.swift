//
//  CYLAnimationListViewController.swift
//  Example-Scenarios
//
//  Every animation bundled in CYLTableViewPlaceHolder.bundle/Animations, grouped by engine, read with
//  `CYLPlaceholderView.bundledAnimationFileNames()`. Each row shows one file as the reserved component of a
//  `CYLPlaceholderStackView`; "Sources" shows NOTICE.animations (source, commit, license, SHA-256 of each file).
//

import UIKit
import CYLTableViewPlaceHolder

final class CYLAnimationListViewController: UITableViewController {

    private struct Section {
        let title: String
        let fileNames: [String]
    }

    private static let engines: [(fileExtension: String, title: String)] = [
        ("json", "Lottie · CYLTableViewPlaceHolder/LottieSwift"),
        ("pag", "PAG · CYLTableViewPlaceHolder/PAG"),
        ("riv", "Rive · CYLTableViewPlaceHolder/Rive"),
        ("gif", "GIF · Core"),
    ]

    private let sections: [Section] = {
        let names = CYLPlaceholderView.bundledAnimationFileNames()
        return engines.compactMap { engine in
            let files = names.filter { ($0 as NSString).pathExtension == engine.fileExtension }
            return files.isEmpty ? nil : Section(title: engine.title, fileNames: files)
        }
    }()

    init() {
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "animation")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: CYLScenarioLocalizedString(.actionSources),
                                                            style: .plain, target: self, action: #selector(showNotice))
        // The empty state of this list, should the bundle be missing.
        tableView.cyl_placeholderViewBlock({ _ in
            CYLPlaceholderView(style: .folderOff, text: CYLScenarioLocalizedString(.textNoAnimations))
        })
    }

    @objc private func showNotice() {
        let notice = CYLPlaceholderView.bundledAnimationFileNames().first
            .flatMap { CYLPlaceholderView.path(forBundledAnimation: $0) }
            .map { (($0 as NSString).deletingLastPathComponent as NSString).appendingPathComponent("NOTICE.animations") }
            .flatMap { try? String(contentsOfFile: $0, encoding: .utf8) }
        let controller = UIViewController()
        controller.title = "NOTICE.animations"
        let textView = UITextView()
        textView.isEditable = false
        textView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.text = notice ?? CYLScenarioLocalizedString(.textNoticeMissing)
        controller.view = textView
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].fileNames.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "animation", for: indexPath)
        let name = sections[indexPath.section].fileNames[indexPath.row]
        let path = CYLPlaceholderView.path(forBundledAnimation: name)
        let bytes = path.flatMap { try? FileManager.default.attributesOfItem(atPath: $0)[.size] as? NSNumber }
        var content = UIListContentConfiguration.subtitleCell()
        content.text = name
        content.secondaryText = ByteCountFormatter.string(fromByteCount: bytes?.int64Value ?? 0, countStyle: .file)
        content.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let name = sections[indexPath.section].fileNames[indexPath.row]
        navigationController?.pushViewController(CYLAnimationDetailViewController(fileName: name), animated: true)
    }
}

/// One bundled animation as the reserved component; it replays every 4 seconds and on "Replay".
final class CYLAnimationDetailViewController: UIViewController {

    private let fileName: String
    private var placeholder: CYLPlaceholderStackView?
    private var replayTimer: Timer?

    init(fileName: String) {
        self.fileName = fileName
        super.init(nibName: nil, bundle: nil)
        title = fileName
        hidesBottomBarWhenPushed = true
        navigationItem.largeTitleDisplayMode = .never
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: CYLScenarioLocalizedString(.actionReplay),
                                                            style: .plain, target: self, action: #selector(replay))
        // The component builder adds the options a bundled Rive file needs.
        let title = (fileName as NSString).deletingPathExtension.replacingOccurrences(of: "CYLPlaceholder", with: "")
        let placeholder = CYLPlaceholderStackView(components: [
            CYLPlaceholderComponent(bundledAnimation: fileName, fallbackStyle: .image, title: title,
                                    size: CGSize(width: 180, height: 180), action: nil),
        ], actions: nil)
        placeholder.frame = view.bounds
        placeholder.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(placeholder)
        self.placeholder = placeholder
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Placeholder animations play once when they appear; replay them so the demo keeps moving.
        replayTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { [weak self] _ in
            self?.replay()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        replayTimer?.invalidate()
        replayTimer = nil
    }

    @objc private func replay() {
        placeholder?.placeholderView.playPlaceholderAnimation()
    }
}
