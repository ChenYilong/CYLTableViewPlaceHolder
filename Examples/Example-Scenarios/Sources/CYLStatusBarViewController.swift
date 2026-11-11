//
//  CYLStatusBarViewController.swift
//  Example-Scenarios
//
//  The status bar ported from CYLChatKit (`CYLPlaceholderStatusView`, "Network unavailable, Check network") and the
//  placeholder as two independent components of this view controller. The bar is added to the controller's view, right
//  below the navigation bar; the placeholder stays the table's (`cyl_placeholderViewBlock`). One parameter,
//  `cyl_statusDisplay`, chooses what shows (the toolbar):
//
//  - bar + placeholder:  `.all`
//  - bar only:           `.statusBar` (the empty table shows no placeholder)
//  - placeholder only:   `.placeholder` (the default)
//  - bar + list:         `.statusBar` with rows
//
//  "Network" turns on `cyl_showsStatusViewWhenOffline`: `CYLPlaceholderNetworkMonitor` (NWPathMonitor) adds the bar
//  while the device is offline (try airplane mode). "File" applies StatusBar/*.json with
//  `cyl_applyStatusConfiguration(contentsOf:)`. The bar keeps CYLChatKit's API: `delegate` and `statusViewClicked(_:)`.
//

import UIKit
import CYLTableViewPlaceHolder

final class CYLStatusBarViewController: UITableViewController, CYLPlaceholderStatusViewDelegate {

    private enum Mode: Int, CaseIterable {
        case barAndPlaceholder, barOnly, placeholderOnly, barAndList

        var title: String {
            switch self {
            case .barAndPlaceholder: return CYLScenarioLocalizedString(.statusModeBoth)
            case .barOnly: return CYLScenarioLocalizedString(.statusModeBar)
            case .placeholderOnly: return CYLScenarioLocalizedString(.statusModePlaceholder)
            case .barAndList: return CYLScenarioLocalizedString(.statusModeList)
            }
        }

        var display: CYLPlaceholderStatusDisplay {
            switch self {
            case .barAndPlaceholder: return .all
            case .barOnly, .barAndList: return .statusBar
            case .placeholderOnly: return .placeholder
            }
        }
    }

    private var mode = Mode.barAndPlaceholder
    private lazy var modeControl: UISegmentedControl = {
        let control = UISegmentedControl(items: Mode.allCases.map(\.title))
        control.selectedSegmentIndex = mode.rawValue
        control.accessibilityIdentifier = "statusBarMode"
        control.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        return control
    }()
    private lazy var networkItem = UIBarButtonItem(title: CYLScenarioLocalizedString(.statusFollowNetwork), style: .plain,
                                                   target: self, action: #selector(toggleNetwork))

    init() {
        super.init(style: .plain)
        title = CYLScenarioLocalizedString(.titleStatusBar)
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
        tableView.tableFooterView = UIView()
        tableView.accessibilityIdentifier = "statusBarDemo"
        networkItem.accessibilityIdentifier = "statusFollowNetwork"
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: CYLScenarioLocalizedString(.actionShowFile), style: .plain, target: self,
                            action: #selector(showFiles)),
            networkItem,
        ]
        toolbarItems = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(customView: modeControl),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
        ]
        // The placeholder: the table's own, independent of the bar.
        tableView.cyl_placeholderViewBlock({ [weak self] _ in
            CYLPlaceholderStackView(scenario: .networkUnavailable, actions: [
                .retry: { _, _ in self?.cyl_showFeedback(CYLScenarioLocalizedString(.feedbackReconnect)) },
            ])
        })
        // The bar: CYLChatKit's network bar; taps go to the delegate, as in CYLChatKit.
        cyl_statusView.delegate = self
        cyl_statusView.placeholderView.accessibilityHint = CYLScenarioLocalizedString(.feedbackReconnect)
        apply(animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: animated)
    }

    @objc private func modeChanged() {
        mode = Mode(rawValue: modeControl.selectedSegmentIndex) ?? .barAndPlaceholder
        apply(animated: true)
    }

    private func apply(animated: Bool) {
        tableView.reloadData()
        cyl_setStatusDisplay(mode.display, animated: animated)
    }

    @objc private func toggleNetwork() {
        cyl_showsStatusViewWhenOffline.toggle()
        networkItem.title = CYLScenarioLocalizedString(cyl_showsStatusViewWhenOffline ? .statusFollowingNetwork
                                                                                         : .statusFollowNetwork)
        let status = CYLPlaceholderNetworkMonitor.name(for: CYLPlaceholderNetworkMonitor.shared.networkStatus)
        cyl_showFeedback(CYLScenarioLocalizedFormat(.formatNetworkStatus, status))
    }

    // MARK: - CYLPlaceholderStatusViewDelegate

    /// CYLChatKit reconnects here; the demo confirms the tap.
    @objc(statusViewClicked:)
    func statusViewClicked(_ sender: Any) {
        cyl_showFeedback(CYLScenarioLocalizedString(.feedbackReconnect))
    }

    // MARK: - Configuration files

    @objc private func showFiles() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let folder = CYLScenarioExampleResourceURL("StatusBar")
        let files = folder.flatMap { try? FileManager.default.contentsOfDirectory(at: $0, includingPropertiesForKeys: nil) } ?? []
        for url in files.filter({ $0.pathExtension == "json" }).sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
            sheet.addAction(UIAlertAction(title: url.lastPathComponent, style: .default) { [weak self] _ in
                self?.applyFile(url)
            })
        }
        sheet.addAction(UIAlertAction(title: CYLScenarioLocalizedString(.actionCancel), style: .cancel))
        sheet.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItems?.first
        present(sheet, animated: true)
    }

    private func applyFile(_ url: URL) {
        do {
            try cyl_applyStatusConfiguration(contentsOf: url)
            cyl_statusView.delegate = self
            mode = cyl_statusDisplay == .all ? .barAndPlaceholder :
                (cyl_statusDisplay == .statusBar ? .barOnly : .placeholderOnly)
            modeControl.selectedSegmentIndex = mode.rawValue
            tableView.reloadData()
        } catch {
            cyl_showFeedback(error.localizedDescription)
        }
    }

    // MARK: - Rows

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mode == .barAndList ? 12 : 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "row", for: indexPath)
        var content = UIListContentConfiguration.cell()
        content.text = CYLScenarioLocalizedFormat(.formatItem, indexPath.row + 1)
        content.image = UIImage(systemName: "bubble.left")
        cell.contentConfiguration = content
        return cell
    }
}
