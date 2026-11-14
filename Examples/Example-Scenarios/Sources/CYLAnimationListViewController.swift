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
        /// nil: the core bundle (`CYLPlaceholderView.path(forBundledAnimation:)`); otherwise the folder of the files.
        var folder: URL?
    }

    private static let engines: [(fileExtension: String, title: String)] = [
        ("json", "Lottie · CYLTableViewPlaceHolder/LottieSwift"),
        ("pag", "PAG · CYLTableViewPlaceHolder/PAG"),
        ("riv", "Rive · CYLTableViewPlaceHolder/Rive"),
        ("gif", "GIF · Core"),
    ]

    private let sections: [Section] = {
        let names = CYLPlaceholderView.bundledAnimationFileNames()
        var sections: [Section] = engines.compactMap { engine in
            let files = names.filter { ($0 as NSString).pathExtension == engine.fileExtension }
            return files.isEmpty ? nil : Section(title: engine.title, fileNames: files, folder: nil)
        }
        // The example's own animations: no placeholder meaning (a mascot, a scene, widget demos), so they live in the
        // example bundle, not in the core bundle (CYLScenarioExample.bundle/Animations/NOTICE.animations).
        if let folder = CYLScenarioExampleResourceURL("Animations") {
            let files = ((try? FileManager.default.contentsOfDirectory(atPath: folder.path)) ?? [])
                .filter { ["json", "pag", "riv", "gif"].contains(($0 as NSString).pathExtension) }
                .sorted()
            if !files.isEmpty {
                sections.append(Section(title: "CYLScenarioExample.bundle/Animations", fileNames: files, folder: folder))
            }
        }
        return sections
    }()

    private func path(at indexPath: IndexPath) -> String? {
        let section = sections[indexPath.section]
        let name = section.fileNames[indexPath.row]
        guard let folder = section.folder else { return CYLPlaceholderView.path(forBundledAnimation: name) }
        return folder.appendingPathComponent(name).path
    }

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
        let path = self.path(at: indexPath)
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
        let section = sections[indexPath.section]
        let name = section.fileNames[indexPath.row]
        let examplePath = section.folder == nil ? nil : path(at: indexPath)
        navigationController?.pushViewController(CYLAnimationDetailViewController(fileName: name, examplePath: examplePath),
                                                 animated: true)
    }
}

/// One bundled animation as the reserved component; it replays every 4 seconds and on "Replay".
final class CYLAnimationDetailViewController: UIViewController {

    private let fileName: String
    /// The full path of an example-bundle animation; nil for a core one.
    private let examplePath: String?
    private var placeholder: CYLPlaceholderStackView?
    private var replayTimer: Timer?

    init(fileName: String, examplePath: String? = nil) {
        self.fileName = fileName
        self.examplePath = examplePath
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
        let title = (fileName as NSString).deletingPathExtension
            .replacingOccurrences(of: "CYLPlaceholder", with: "").replacingOccurrences(of: "CYLScenarioExample", with: "")
        let component: CYLPlaceholderComponent
        if let examplePath = examplePath {
            // A file outside the core bundle: the item attributes name its path; the old Rive files need `legacy`.
            var attributes: [String: Any] = [
                CYLPlaceholderItemTitle: title,
                CYLPlaceholderItemStyle: CYLPlaceholderStyle.image.rawValue,
                CYLPlaceholderItemAnimationFilePath: examplePath,
                CYLPlaceholderItemAnimationSize: [180, 180],
                CYLPlaceholderItemAnimationRepeatCount: 0,
            ]
            if (fileName as NSString).pathExtension == "riv" {
                attributes[CYLPlaceholderItemAnimationOptions] = ["legacy": "1"]
            }
            component = CYLPlaceholderComponent(attributes: attributes, action: nil)
        } else {
            // The component builder adds the options a bundled Rive file needs.
            component = CYLPlaceholderComponent(bundledAnimation: fileName, fallbackStyle: .image, title: title,
                                                size: CGSize(width: 180, height: 180), action: nil)
        }
        let placeholder = CYLPlaceholderStackView(components: [component], actions: nil)
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
