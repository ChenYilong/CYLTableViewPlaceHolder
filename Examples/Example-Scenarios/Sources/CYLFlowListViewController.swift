//
//  CYLFlowListViewController.swift
//  Example-Scenarios
//
//  How a placeholder is attached to a list. Most flows use the block API (`cyl_placeholderViewBlock`), asked again on
//  every empty reload; the "keep header" and "scrollable" flows use the delegate API (`cyl_reloadData` with
//  `CYLTableViewPlaceHolderDelegate`), which supports a custom frame and scrolling. Every placeholder is a scenario of
//  the core catalog.
//

import UIKit
import CYLTableViewPlaceHolder

enum CYLFlow: CaseIterable {
    /// A segmented control switches between empty, failed, offline and data (issue #3).
    case switchStates
    /// Delegate API with a custom frame below the table header (issue #17).
    case keepTableHeader
    /// Delegate API with a custom frame below custom section headers (issue #16).
    case keepSectionHeaders
    /// Pull to refresh and load more stay usable above a full-size placeholder (issue #8).
    case refreshControls
    /// The table keeps scrolling while the placeholder shows (delegate API).
    case scrollable
    /// UICollectionView placeholder (issue #11).
    case collection

    var title: String {
        switch self {
        case .switchStates: return CYLScenarioLocalizedString(.titleSwitchStates)
        case .keepTableHeader: return CYLScenarioLocalizedString(.titleKeepTableHeader)
        case .keepSectionHeaders: return CYLScenarioLocalizedString(.titleKeepSectionHeaders)
        case .refreshControls: return CYLScenarioLocalizedString(.titleRefreshControls)
        case .scrollable: return CYLScenarioLocalizedString(.titleScrollable)
        case .collection: return CYLScenarioLocalizedString(.titleCollection)
        }
    }

    /// The API the flow uses; identifiers are not translated.
    var detail: String {
        switch self {
        case .switchStates: return "reloadData #3"
        case .keepTableHeader: return "frameForPlaceHolderViewInTableView: #17"
        case .keepSectionHeaders: return "rectForHeaderInSection: #16"
        case .refreshControls: return "cyl_header + cyl_footer #8"
        case .scrollable: return "enableScrollWhenPlaceHolderViewShowing"
        case .collection: return "cyl_placeholderViewBlock: #11"
        }
    }

    var symbol: String {
        switch self {
        case .switchStates: return "arrow.triangle.2.circlepath"
        case .keepTableHeader: return "rectangle.topthird.inset.filled"
        case .keepSectionHeaders: return "list.bullet.indent"
        case .refreshControls: return "arrow.down.circle"
        case .scrollable: return "arrow.up.and.down"
        case .collection: return "square.grid.2x2"
        }
    }

    /// The scenario shown while the list is empty.
    var scenario: CYLPlaceholderScenario {
        switch self {
        case .switchStates: return .noContent
        case .keepTableHeader: return .noSearchResults
        case .keepSectionHeaders: return .noMessages
        case .refreshControls: return .noNotifications
        case .scrollable: return .textOnly
        case .collection: return .noFavorites
        }
    }
}

final class CYLFlowListViewController: UITableViewController {

    init() {
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "flow")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        CYLFlow.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "flow", for: indexPath)
        let flow = CYLFlow.allCases[indexPath.row]
        var content = UIListContentConfiguration.subtitleCell()
        content.text = flow.title
        content.secondaryText = flow.detail
        content.secondaryTextProperties.color = .secondaryLabel
        content.image = UIImage(systemName: flow.symbol)
        content.imageProperties.tintColor = .systemTeal
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let flow = CYLFlow.allCases[indexPath.row]
        let next: UIViewController = flow == .collection
            ? CYLCollectionFlowViewController(flow: flow)
            : CYLFlowDetailViewController(flow: flow)
        navigationController?.pushViewController(next, animated: true)
    }
}

final class CYLFlowDetailViewController: UITableViewController, CYLTableViewPlaceHolderDelegate {

    private enum State: Int {
        case empty, failed, offline, data
    }

    private let flow: CYLFlow
    private var state = State.empty
    private var rows = 0

    init(flow: CYLFlow) {
        self.flow = flow
        super.init(style: flow == .keepSectionHeaders ? .insetGrouped : .plain)
        title = flow.title
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "row")
        tableView.tableFooterView = UIView()
        switch flow {
        case .keepTableHeader:
            let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 56))
            searchBar.placeholder = CYLScenarioLocalizedString(.searchPlaceholder)
            tableView.tableHeaderView = searchBar
            tableView.cyl_reloadData()
        case .keepSectionHeaders:
            tableView.cyl_reloadData()
        case .scrollable:
            setUpRefreshHeader(usesDelegateAPI: true)
            tableView.cyl_reloadData()
        case .switchStates:
            setUpStateSwitcher()
            installPlaceholderBlock()
        case .refreshControls:
            setUpRefreshHeader(usesDelegateAPI: false)
            // A Rive pull-to-refresh icon in the header (see setUpRefreshHeader) and a GIF icon in the footer.
            tableView.cyl_header?.setIconAnimation(bundled: "CYLPlaceholderPullToRefresh.riv",
                                                   size: CGSize(width: 40, height: 40), for: .idle)
            let footer = CYLRefreshAutoNormalFooter { [weak self] in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.tableView.cyl_footer?.endRefreshingWithNoMoreData()
                }
            }
            footer.setIconAnimation(bundled: "CYLPlaceholderUploading.gif", size: CGSize(width: 32, height: 32),
                                    for: .refreshing)
            tableView.cyl_footer = footer
            installPlaceholderBlock()
        case .collection:
            installPlaceholderBlock()
        }
    }

    // MARK: Block API

    private func installPlaceholderBlock() {
        tableView.cyl_placeholderViewBlock({ [weak self] _ in
            self?.makePlaceholder()
        })
        tableView.reloadData()
    }

    private func makePlaceholder() -> UIView {
        let scenario: CYLPlaceholderScenario
        switch state {
        case .failed: scenario = .retryButton
        case .offline: scenario = .networkUnavailable
        case .empty, .data: scenario = flow.scenario
        }
        return CYLPlaceholderStackView(scenario: scenario, actions: [
            .retry: { [weak self] _, _ in self?.select(.data) },
        ])
    }

    // MARK: Switch states (issue #3)

    private func setUpStateSwitcher() {
        let control = UISegmentedControl(items: [
            CYLScenarioLocalizedString(.stateEmpty), CYLScenarioLocalizedString(.stateFailed),
            CYLScenarioLocalizedString(.stateOffline), CYLScenarioLocalizedString(.stateData),
        ])
        control.selectedSegmentIndex = 0
        control.accessibilityIdentifier = "stateSwitcher"
        control.addTarget(self, action: #selector(stateChanged(_:)), for: .valueChanged)
        navigationItem.titleView = control
    }

    @objc private func stateChanged(_ control: UISegmentedControl) {
        select(State(rawValue: control.selectedSegmentIndex) ?? .empty)
    }

    private func select(_ newState: State) {
        state = newState
        rows = newState == .data ? 12 : 0
        (navigationItem.titleView as? UISegmentedControl)?.selectedSegmentIndex = newState.rawValue
        // Each empty reload asks the block again, so the same table switches between different placeholders.
        if flow == .keepTableHeader || flow == .keepSectionHeaders || flow == .scrollable {
            tableView.cyl_reloadData()
        } else {
            tableView.reloadData()
        }
    }

    // MARK: Refresh controls (issue #8)

    private func setUpRefreshHeader(usesDelegateAPI: Bool) {
        tableView.cyl_header = CYLRefreshNormalHeader { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                guard let self = self else { return }
                self.rows = self.rows > 0 ? 0 : 12
                self.tableView.cyl_footer?.resetNoMoreData()
                if usesDelegateAPI {
                    self.tableView.cyl_reloadData()
                } else {
                    self.tableView.reloadData()
                }
                self.tableView.cyl_header?.endRefreshing()
            }
        }
    }

    // MARK: Delegate API (issues #16, #17)

    @objc(makePlaceHolderView)
    func makePlaceHolderView() -> UIView {
        makePlaceholder()
    }

    @objc(enableScrollWhenPlaceHolderViewShowing)
    func enableScrollWhenPlaceHolderViewShowing() -> Bool {
        flow == .scrollable
    }

    @objc(frameForPlaceHolderViewInTableView:)
    func frameForPlaceHolderView(in tableView: UITableView) -> CGRect {
        var top: CGFloat = 0
        if flow == .keepTableHeader {
            top = tableView.tableHeaderView?.frame.maxY ?? 0
        } else if flow == .keepSectionHeaders {
            let lastSection = tableView.numberOfSections - 1
            top = lastSection >= 0 ? tableView.rectForHeader(inSection: lastSection).maxY : 0
        }
        return CGRect(x: 0, y: top, width: tableView.bounds.width, height: max(0, tableView.bounds.height - top))
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        flow == .keepSectionHeaders ? 2 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard flow == .keepSectionHeaders else { return nil }
        return CYLScenarioLocalizedString(section == 0 ? .sectionPinned : .sectionAll)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "row", for: indexPath)
        var content = UIListContentConfiguration.cell()
        content.text = CYLScenarioLocalizedFormat(.formatItem, indexPath.row + 1)
        content.image = UIImage(systemName: "doc.text")
        cell.contentConfiguration = content
        return cell
    }
}

final class CYLCollectionFlowViewController: UICollectionViewController {

    private let flow: CYLFlow
    private var items = 0

    init(flow: CYLFlow) {
        self.flow = flow
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 104, height: 104)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        super.init(collectionViewLayout: layout)
        title = flow.title
        hidesBottomBarWhenPushed = true
        navigationItem.largeTitleDisplayMode = .never
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .systemBackground
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "photo")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: CYLScenarioLocalizedString(.actionAdd),
                                                            style: .plain, target: self, action: #selector(toggleItems))
        collectionView.cyl_placeholderViewBlock({ [weak self] _ in
            guard let self = self else { return nil }
            return CYLPlaceholderStackView(scenario: self.flow.scenario, actions: nil)
        })
        collectionView.reloadData()
    }

    @objc private func toggleItems() {
        items = items > 0 ? 0 : 18
        navigationItem.rightBarButtonItem?.title = CYLScenarioLocalizedString(items > 0 ? .actionClear : .actionAdd)
        collectionView.reloadData()
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photo", for: indexPath)
        let hue = CGFloat(indexPath.item % 12) / 12
        cell.contentView.backgroundColor = UIColor(hue: hue, saturation: 0.35, brightness: 0.95, alpha: 1)
        cell.contentView.layer.cornerRadius = 10
        return cell
    }
}
