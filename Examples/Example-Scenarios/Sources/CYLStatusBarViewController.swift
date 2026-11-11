//
//  CYLStatusBarViewController.swift
//  Example-Scenarios
//
//  The status bar ported from CYLChatKit (`CYLPlaceholderStatusView`, "Network unavailable, Check network") and its
//  combinations with the placeholder, chosen in the toolbar:
//
//  - bar + placeholder:  `CYLPlaceholderStackView(scenario:actions:)` with `statusView`
//  - bar only:           `CYLPlaceholderStackView(statusView:)` (`componentsHidden` is true)
//  - placeholder only:   the scenario without `statusView`
//  - bar + list:         rows are shown, so no placeholder; the bar is the table header, as CYLChatKit shows it
//
//  The bar keeps CYLChatKit's API: `CYLPlaceholderStatusView(frame:)`, `delegate` and `statusViewClicked(_:)`, the 44-point
//  height. The same combinations come from configuration files: Configurations/status-bar-*.json ("File").
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
    }

    private var mode = Mode.barAndPlaceholder
    private lazy var modeControl: UISegmentedControl = {
        let control = UISegmentedControl(items: Mode.allCases.map(\.title))
        control.selectedSegmentIndex = mode.rawValue
        control.accessibilityIdentifier = "statusBarMode"
        control.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        return control
    }()

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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: CYLScenarioLocalizedString(.actionShowFile),
                                                            style: .plain, target: self, action: #selector(showFiles))
        toolbarItems = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(customView: modeControl),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
        ]
        tableView.cyl_placeholderViewBlock({ [weak self] _ in
            self?.makePlaceholder()
        })
        apply()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: animated)
    }

    /// CYLChatKit's bar: the network message and icon, a 44-point height, taps sent to the delegate.
    private func makeBar() -> CYLPlaceholderStatusView {
        let bar = CYLPlaceholderStatusView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width,
                                                         height: CYLPlaceholderStatusViewHeight))
        bar.delegate = self
        bar.placeholderView.accessibilityHint = CYLScenarioLocalizedString(.feedbackReconnect)
        return bar
    }

    private func makePlaceholder() -> UIView? {
        switch mode {
        case .barAndPlaceholder:
            let placeholder = makeScenario()
            placeholder.statusView = makeBar()
            return placeholder
        case .barOnly:
            return CYLPlaceholderStackView(statusView: makeBar())
        case .placeholderOnly:
            return makeScenario()
        case .barAndList:
            return nil
        }
    }

    private func makeScenario() -> CYLPlaceholderStackView {
        CYLPlaceholderStackView(scenario: .networkUnavailable, actions: [
            .retry: { [weak self] _, _ in self?.cyl_showFeedback(CYLScenarioLocalizedString(.feedbackReconnect)) },
        ])
    }

    @objc private func modeChanged() {
        mode = Mode(rawValue: modeControl.selectedSegmentIndex) ?? .barAndPlaceholder
        apply()
    }

    private func apply() {
        // With rows the table shows no placeholder, so the bar goes on top of the list, as in CYLChatKit.
        tableView.tableHeaderView = mode == .barAndList ? makeBar() : nil
        tableView.reloadData()
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
        for url in CYLConfigurationFiles.urls() where url.lastPathComponent.hasPrefix("status-bar") {
            sheet.addAction(UIAlertAction(title: url.lastPathComponent, style: .default) { [weak self] _ in
                self?.navigationController?.pushViewController(CYLConfigurationViewController(url: url), animated: true)
            })
        }
        sheet.addAction(UIAlertAction(title: CYLScenarioLocalizedString(.actionCancel), style: .cancel))
        sheet.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(sheet, animated: true)
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
