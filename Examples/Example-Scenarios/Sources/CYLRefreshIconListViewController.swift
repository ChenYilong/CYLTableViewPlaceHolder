//
//  CYLRefreshIconListViewController.swift
//  Example-Scenarios
//
//  Every refresh icon animation of the core bundle (`CYLRefreshAnimationHeader.bundledIconAnimationFileNames`: the
//  `CYLRefresh*` files plus the placeholder animations that suit a refresh control), grouped by engine. Each row opens a
//  list whose CYLRefresh header and footer draw that file. A second section shows the other ways to set an icon at init:
//
//  - bundled file name:  `setIconAnimation(bundled:size:for:)`, one page per file
//  - file path:          `setIconAnimation(filePath:size:for:)` with a full path
//  - item attributes:    `setIconAnimation(attributes:for:)`, here a Rive state machine and its trigger input
//  - configuration file: CYLScenarioExample.bundle/RefreshIcons/refresh-icons.json names the file of every state
//

import UIKit
import CYLTableViewPlaceHolder

/// How a demo page sets the icons of its header and footer.
private typealias CYLRefreshIconSetup = (_ header: CYLRefreshAnimationHeader, _ footer: CYLRefreshAutoAnimationFooter) -> Void

final class CYLRefreshIconListViewController: UITableViewController {

    private struct Row {
        let title: String
        let subtitle: String
        let setup: CYLRefreshIconSetup
    }

    private struct Section {
        let title: String
        let rows: [Row]
    }

    private static let engines: [(fileExtension: String, title: String)] = [
        ("gif", "GIF · Core"),
        ("json", "Lottie · CYLTableViewPlaceHolder/LottieSwift"),
        ("pag", "PAG · CYLTableViewPlaceHolder/PAG"),
        ("riv", "Rive · CYLTableViewPlaceHolder/Rive"),
    ]

    /// The size of an icon: line icons and spinners read well at about the arrow's height, wide loaders need room.
    private static func iconSize(for fileName: String) -> CGSize {
        switch fileName {
        case "CYLPlaceholderLoadingInfinity.json", "CYLRefreshDots.json", "CYLRefreshDotsPulse.json",
             "CYLRefreshStepLoader.json":
            return CGSize(width: 48, height: 28)
        case "CYLPlaceholderPullHint.pag", "CYLPlaceholderLoading.riv", "CYLPlaceholderPullToRefresh.riv":
            return CGSize(width: 40, height: 40)
        default:
            return CGSize(width: 32, height: 32)
        }
    }

    private let sections: [Section] = {
        let names = CYLRefreshAnimationHeader.bundledIconAnimationFileNames
        var sections: [Section] = engines.compactMap { engine in
            let rows = names.filter { ($0 as NSString).pathExtension == engine.fileExtension }.map { name in
                Row(title: name, subtitle: "setIconAnimation(bundled:size:for:)") { header, footer in
                    let size = CYLRefreshIconListViewController.iconSize(for: name)
                    // One call per control: the idle icon is used by every state without its own.
                    header.setIconAnimation(bundled: name, size: size, for: .idle)
                    footer.setIconAnimation(bundled: name, size: size, for: .idle)
                }
            }
            return rows.isEmpty ? nil : Section(title: engine.title, rows: rows)
        }
        sections.append(Section(title: CYLScenarioLocalizedString(.sectionRefreshInit), rows: [
            Row(title: CYLScenarioLocalizedString(.refreshByFilePath), subtitle: "setIconAnimation(filePath:size:for:)") {
                header, footer in
                // Any file on disk: here the full paths of two bundled files, one for pulling and one for refreshing.
                if let arrow = CYLPlaceholderView.path(forBundledAnimation: "CYLRefreshArrows.gif"),
                   let spinner = CYLPlaceholderView.path(forBundledAnimation: "CYLRefreshGradientSpinner.json") {
                    header.setIconAnimation(filePath: arrow, size: CGSize(width: 32, height: 32), for: .idle)
                    header.setIconAnimation(filePath: spinner, size: CGSize(width: 36, height: 36), for: .refreshing)
                    footer.setIconAnimation(filePath: spinner, size: CGSize(width: 32, height: 32), for: .refreshing)
                }
            },
            Row(title: CYLScenarioLocalizedString(.refreshByAttributes), subtitle: "setIconAnimation(attributes:for:)") {
                header, footer in
                guard let check = CYLPlaceholderView.path(forBundledAnimation: "CYLRefreshCheck.riv") else { return }
                // Raw item attributes: the circle fills while pulling and refreshing ("Loading" animation); released,
                // the header plays the "Check" trigger of the file's state machine.
                let loading: [String: Any] = [
                    CYLPlaceholderItemAnimationFilePath: check,
                    CYLPlaceholderItemAnimationSize: [36, 36],
                    CYLPlaceholderItemAnimationOptions: ["legacy": "1", "animation": "Loading"],
                ]
                var done = loading
                done[CYLPlaceholderItemAnimationOptions] = ["stateMachine": "State Machine 1", "triggerInput": "Check"]
                header.setIconAnimation(attributes: loading, for: .idle)
                header.setIconAnimation(attributes: done, for: .refreshing)
                footer.setIconAnimation(attributes: loading, for: .refreshing)
            },
            Row(title: CYLScenarioLocalizedString(.refreshByConfiguration), subtitle: "RefreshIcons/refresh-icons.json") {
                header, footer in
                CYLRefreshIconConfiguration.apply(fileNamed: "refresh-icons.json", header: header, footer: footer)
            },
        ]))
        return sections
    }()

    init() {
        super.init(style: .insetGrouped)
        title = CYLScenarioLocalizedString(.refreshIcons)
        hidesBottomBarWhenPushed = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "refreshIcon")
        tableView.accessibilityIdentifier = "refreshIconList"
        // The empty state of this list, should the bundle be missing.
        tableView.cyl_placeholderViewBlock({ _ in
            CYLPlaceholderView(style: .folderOff, text: CYLScenarioLocalizedString(.textNoAnimations))
        })
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].rows.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "refreshIcon", for: indexPath)
        let row = sections[indexPath.section].rows[indexPath.row]
        var content = UIListContentConfiguration.subtitleCell()
        content.text = row.title
        content.secondaryText = row.subtitle
        content.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = sections[indexPath.section].rows[indexPath.row]
        navigationController?.pushViewController(CYLRefreshIconDemoViewController(title: row.title, setup: row.setup),
                                                 animated: true)
    }
}

/// Reads CYLScenarioExample.bundle/RefreshIcons/<file>: for "header" and "footer", a state name ("idle", "pulling",
/// "refreshing", "willRefresh", "noMoreData") maps to `{"file": <bundled name>, "size": [w, h]}`, or to
/// `{"file": …, "size": …, "options": {…}}` to add engine options such as a Rive state machine.
enum CYLRefreshIconConfiguration {

    private static let states: [String: CYLRefreshState] = [
        "idle": .idle, "pulling": .pulling, "refreshing": .refreshing, "willRefresh": .willRefresh,
        "noMoreData": .noMoreData,
    ]

    static func apply(fileNamed name: String, header: CYLRefreshIconAnimating, footer: CYLRefreshIconAnimating) {
        guard let url = CYLScenarioExampleResourceURL("RefreshIcons/\(name)"),
              let data = try? Data(contentsOf: url),
              let root = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
            NSLog("Example-Scenarios: refresh icon configuration %@ is missing or invalid.", name)
            return
        }
        for (key, control) in [("header", header), ("footer", footer)] {
            guard let entries = root[key] as? [String: [String: Any]] else { continue }
            for (stateName, entry) in entries {
                guard let state = states[stateName], let file = entry["file"] as? String else {
                    NSLog("Example-Scenarios: skipped %@.%@ in %@.", key, stateName, name)
                    continue
                }
                let numbers = (entry["size"] as? [NSNumber]) ?? [32, 32]
                let size = CGSize(width: numbers.first?.doubleValue ?? 32, height: numbers.last?.doubleValue ?? 32)
                if let options = entry["options"] as? [String: String],
                   let path = CYLPlaceholderView.path(forBundledAnimation: file) {
                    control.setIconAnimation(attributes: [
                        CYLPlaceholderItemAnimationFilePath: path,
                        CYLPlaceholderItemAnimationSize: [size.width, size.height],
                        CYLPlaceholderItemAnimationOptions: options,
                    ], for: state)
                } else {
                    control.setIconAnimation(bundled: file, size: size, for: state)
                }
            }
        }
    }
}

/// A list with a CYLRefresh header and footer whose icons the row set up; "Refresh" starts the header by code.
final class CYLRefreshIconDemoViewController: UITableViewController {

    private let setup: CYLRefreshIconSetup
    private var rows = 15

    fileprivate init(title: String, setup: @escaping CYLRefreshIconSetup) {
        self.setup = setup
        super.init(style: .plain)
        self.title = title
        hidesBottomBarWhenPushed = true
        navigationItem.largeTitleDisplayMode = .never
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "row")
        tableView.accessibilityIdentifier = "refreshIconDemo"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self,
                                                            action: #selector(beginRefreshing))
        let header = CYLRefreshAnimationHeader { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                guard let self = self else { return }
                self.rows = 15
                self.tableView.reloadData()
                self.tableView.cyl_header?.endRefreshing()
                self.tableView.cyl_footer?.resetNoMoreData()
            }
        }
        let footer = CYLRefreshAutoAnimationFooter { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                guard let self = self else { return }
                if self.rows >= 45 {
                    self.tableView.cyl_footer?.endRefreshingWithNoMoreData()
                    return
                }
                self.rows += 15
                self.tableView.reloadData()
                self.tableView.cyl_footer?.endRefreshing()
            }
        }
        // Only the icon changes: the texts, layout and show/hide timing stay CYLRefresh's own.
        setup(header, footer)
        tableView.cyl_header = header
        tableView.cyl_footer = footer
    }

    @objc private func beginRefreshing() {
        tableView.cyl_header?.beginRefreshing()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "row", for: indexPath)
        var content = UIListContentConfiguration.subtitleCell()
        content.text = CYLScenarioLocalizedFormat(.formatItem, indexPath.row + 1)
        content.secondaryText = CYLScenarioLocalizedString(.textRefreshHint)
        content.image = UIImage(systemName: "arrow.up.arrow.down")
        cell.contentConfiguration = content
        return cell
    }
}
