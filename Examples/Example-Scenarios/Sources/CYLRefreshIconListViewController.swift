//
//  CYLRefreshIconListViewController.swift
//  Example-Scenarios
//
//  Every refresh icon animation of the core bundle (`CYLRefreshAnimationHeader.bundledIconAnimationFileNames`: the
//  `CYLRefresh*` files plus the two placeholder animations that also mean refresh), grouped by engine. Each row opens a
//  list whose CYLRefresh header and footer draw that file. A second section shows every API of the animated-image
//  controls (MJRefresh's "animated images", under general names):
//
//  - image sequence:     `setAnimationImages(_:for:)` / `(_:duration:for:)`, frames of a bundled refresh GIF
//  - bundled file name:  `setIconAnimation(bundled:size:for:)`, one icon per state
//  - back footer:        `CYLRefreshBackAnimationFooter`, icon per state including "no more data"
//  - file path:          `setIconAnimation(filePath:size:for:)` with a full path
//  - item attributes:    `setIconAnimation(attributes:for:)`, here a Rive artboard and its animations
//  - configuration file: CYLScenarioExample.bundle/RefreshIcons/refresh-icons.json names the file of every state
//  - MJRefresh names:    `CYLRefreshGifHeader` / `CYLRefreshAutoGifFooter` with `setImages(_:for:)` still work
//

import UIKit
import ImageIO
import CYLTableViewPlaceHolder

/// Builds the header and footer of a demo page; the page adds the refreshing actions.
private typealias CYLRefreshIconSetup = () -> (header: CYLRefreshHeader, footer: CYLRefreshFooter)

/// The frames of a bundled refresh GIF, for the image-sequence API (`setAnimationImages`).
enum CYLRefreshFrames {
    static func images(ofBundledGIF name: String) -> [UIImage] {
        guard let path = CYLPlaceholderView.path(forBundledAnimation: name),
              let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil) else { return [] }
        return (0..<CGImageSourceGetCount(source)).compactMap { index in
            CGImageSourceCreateImageAtIndex(source, index, nil).map { UIImage(cgImage: $0) }
        }
    }
}

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

    /// The size of an icon: line icons and spinners read well at about the arrow's height, dots need width.
    private static func iconSize(for fileName: String) -> CGSize {
        switch fileName {
        case "CYLRefreshDots.json", "CYLRefreshDotsPulse.json", "CYLRefreshMoreDots.json":
            return CGSize(width: 40, height: 24)
        case "CYLRefreshThrobber.gif":
            return CGSize(width: 20, height: 20)
        case "CYLRefreshMaterialSpinner.json", "CYLRefreshDonePop.json", "CYLPlaceholderProgress.pag":
            return CGSize(width: 36, height: 36)
        default:
            return CGSize(width: 32, height: 32)
        }
    }

    private let sections: [Section] = {
        let names = CYLRefreshAnimationHeader.bundledIconAnimationFileNames
        var sections: [Section] = engines.compactMap { engine in
            let rows = names.filter { ($0 as NSString).pathExtension == engine.fileExtension }.map { name in
                Row(title: name, subtitle: "setIconAnimation(bundled:size:for:)") {
                    let size = CYLRefreshIconListViewController.iconSize(for: name)
                    let header = CYLRefreshAnimationHeader()
                    let footer = CYLRefreshAutoAnimationFooter()
                    // One call per control: the idle icon is used by every state without its own.
                    header.setIconAnimation(bundled: name, size: size, for: .idle)
                    footer.setIconAnimation(bundled: name, size: size, for: .idle)
                    return (header, footer)
                }
            }
            return rows.isEmpty ? nil : Section(title: engine.title, rows: rows)
        }
        sections.append(Section(title: CYLScenarioLocalizedString(.sectionRefreshInit), rows: [
            Row(title: CYLScenarioLocalizedString(.refreshByImages), subtitle: "setAnimationImages(_:duration:for:)") {
                // MJRefresh's "animated images", general names: an image sequence per state. The frames come from
                // bundled refresh GIFs; the controls grow to the first image's height.
                let arrows = CYLRefreshFrames.images(ofBundledGIF: "CYLRefreshArrows.gif")
                let ring = CYLRefreshFrames.images(ofBundledGIF: "CYLRefreshRing.gif")
                let header = CYLRefreshAnimationHeader()
                header.setAnimationImages(arrows, for: .idle)
                header.setAnimationImages(arrows, duration: 0.6, for: .pulling)
                header.setAnimationImages(ring, duration: 0.8, for: .refreshing)
                let footer = CYLRefreshAutoAnimationFooter()
                footer.setAnimationImages(ring, for: .refreshing)
                return (header, footer)
            },
            Row(title: CYLScenarioLocalizedString(.refreshByStates), subtitle: "setIconAnimation(bundled:size:for:)") {
                // A different bundled icon for each state, one engine per state.
                let header = CYLRefreshAnimationHeader()
                header.setIconAnimation(bundled: "CYLRefreshPullCircle.json", size: CGSize(width: 28, height: 28), for: .idle)
                header.setIconAnimation(bundled: "CYLRefreshCounterClockwise.json", size: CGSize(width: 28, height: 28),
                                        for: .pulling)
                header.setIconAnimation(bundled: "CYLPlaceholderProgress.pag", size: CGSize(width: 32, height: 32),
                                        for: .refreshing)
                let footer = CYLRefreshAutoAnimationFooter()
                footer.setIconAnimation(bundled: "CYLRefreshActivity.gif", size: CGSize(width: 28, height: 28),
                                        for: .refreshing)
                return (header, footer)
            },
            Row(title: CYLScenarioLocalizedString(.refreshBackFooter), subtitle: "CYLRefreshBackAnimationFooter") {
                // The back footer shows its icon while idle and pulling too; "no more data" shows the text only.
                let header = CYLRefreshAnimationHeader()
                header.setIconAnimation(bundled: "CYLRefreshCycle.json", size: CGSize(width: 28, height: 28), for: .idle)
                let footer = CYLRefreshBackAnimationFooter()
                footer.setIconAnimation(bundled: "CYLRefreshLoadMore.json", size: CGSize(width: 28, height: 28), for: .idle)
                footer.setIconAnimation(bundled: "CYLRefreshClockwise.json", size: CGSize(width: 28, height: 28),
                                        for: .pulling)
                footer.setIconAnimation(bundled: "CYLRefreshPetals.gif", size: CGSize(width: 28, height: 28),
                                        for: .refreshing)
                return (header, footer)
            },
            Row(title: CYLScenarioLocalizedString(.refreshByFilePath), subtitle: "setIconAnimation(filePath:size:for:)") {
                // Any file on disk: here the full paths of two bundled files, one for pulling and one for refreshing.
                let header = CYLRefreshAnimationHeader()
                let footer = CYLRefreshAutoAnimationFooter()
                if let arrow = CYLPlaceholderView.path(forBundledAnimation: "CYLRefreshArrows.gif"),
                   let spinner = CYLPlaceholderView.path(forBundledAnimation: "CYLRefreshGradientSpinner.json") {
                    header.setIconAnimation(filePath: arrow, size: CGSize(width: 32, height: 32), for: .idle)
                    header.setIconAnimation(filePath: spinner, size: CGSize(width: 36, height: 36), for: .refreshing)
                    footer.setIconAnimation(filePath: spinner, size: CGSize(width: 32, height: 32), for: .refreshing)
                }
                return (header, footer)
            },
            Row(title: CYLScenarioLocalizedString(.refreshByAttributes), subtitle: "setIconAnimation(attributes:for:)") {
                let header = CYLRefreshAnimationHeader()
                let footer = CYLRefreshAutoAnimationFooter()
                guard let icon = CYLPlaceholderView.path(forBundledAnimation: "CYLRefreshIcon.riv") else {
                    return (header, footer)
                }
                // Raw item attributes: the "refresh" artboard of the Rive file rests on its "idle" animation and
                // turns with its "active" animation while refreshing.
                let resting: [String: Any] = [
                    CYLPlaceholderItemAnimationFilePath: icon,
                    CYLPlaceholderItemAnimationSize: [32, 32],
                    CYLPlaceholderItemAnimationOptions: ["legacy": "1", "artboard": "refresh", "animation": "idle"],
                ]
                var turning = resting
                turning[CYLPlaceholderItemAnimationOptions] = ["legacy": "1", "artboard": "refresh", "animation": "active"]
                header.setIconAnimation(attributes: resting, for: .idle)
                header.setIconAnimation(attributes: turning, for: .refreshing)
                footer.setIconAnimation(attributes: turning, for: .refreshing)
                return (header, footer)
            },
            Row(title: CYLScenarioLocalizedString(.refreshByConfiguration), subtitle: "RefreshIcons/refresh-icons.json") {
                let header = CYLRefreshAnimationHeader()
                let footer = CYLRefreshAutoAnimationFooter()
                CYLRefreshIconConfiguration.apply(fileNamed: "refresh-icons.json", header: header, footer: footer)
                return (header, footer)
            },
            Row(title: CYLScenarioLocalizedString(.refreshGifNames), subtitle: "CYLRefreshGifHeader · setImages(_:for:)") {
                // Code written for MJRefresh's names keeps working: the Gif classes are subclasses whose gifView and
                // setImages call animationView and setAnimationImages.
                let arrows = CYLRefreshFrames.images(ofBundledGIF: "CYLRefreshArrows.gif")
                let header = CYLRefreshGifHeader()
                header.setImages(arrows, for: .idle)
                header.setImages(arrows, duration: 0.6, for: .refreshing)
                let footer = CYLRefreshAutoGifFooter()
                footer.setIconAnimation(bundled: "CYLRefreshThrobber.gif", size: CGSize(width: 20, height: 20),
                                        for: .refreshing)
                return (header, footer)
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
        // Only the icon changes: the texts, layout and show/hide timing stay CYLRefresh's own.
        let (header, footer) = setup()
        header.refreshingBlock = { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                guard let self = self else { return }
                self.rows = 15
                self.tableView.reloadData()
                self.tableView.cyl_header?.endRefreshing()
                self.tableView.cyl_footer?.resetNoMoreData()
            }
        }
        footer.refreshingBlock = { [weak self] in
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
