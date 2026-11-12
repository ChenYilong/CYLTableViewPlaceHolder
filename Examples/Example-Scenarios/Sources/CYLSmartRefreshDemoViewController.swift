//
//  CYLSmartRefreshDemoViewController.swift
//  Example-Scenarios
//
//  The demo of SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, SmartRefreshDemo, MIT; by
//  SCWANG), transcribed to Swift on this project's API: DemoViewController's list became the "SmartRefreshControl
//  styles" section of the Refresh tab, UIDemoHeaderController / UIDemoFooterController and the per-style controllers
//  became this page (one page, a method per style), and UIDeliveryController is the plain list of `smartDelivery`.
//  Only data, style parameters and taps live here; every header and footer comes from the core (CYLRefresh).
//
//  Differences from the original, each for a reason:
//  - "Classics" uses CYLRefreshNormalHeader / CYLRefreshBackNormalFooter, this project's classic controls (the
//    SmartRefreshControl API table maps UIRefreshClassicsHeader / Footer to them).
//  - The theme changes the navigation bar through UINavigationBarAppearance (barTintColor no longer colors the bar
//    on iOS 15 and later), and restores the appearance when the page goes away.
//  - Texts come from CYLScenarioExample.bundle in seven languages; style names are proper nouns and stay as they are.
//

import UIKit
import CYLTableViewPlaceHolder

final class CYLSmartRefreshDemoViewController: UITableViewController, CYLRefreshExampleRunning {

    var method = ""

    /// A row: its text, its detail text and what a tap does.
    private struct Row {
        let title: String
        var detail: String?
        var action: (() -> Void)?
    }

    private var sections: [(title: String?, rows: [Row])] = []
    private var header: CYLRefreshComponent?
    private var footer: CYLRefreshFooter?
    /// The control's own colors, restored by "Default theme".
    private var defaultAccent: UIColor?
    private var defaultPrimary: UIColor?
    private var savedAppearance: (standard: UINavigationBarAppearance, scrollEdge: UINavigationBarAppearance?, tint: UIColor?)?

    init() {
        super.init(style: .grouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.accessibilityIdentifier = "smartRefreshDemo"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "item")
        if method == "smartDelivery" {
            // UIDeliveryController: the header over a plain list of 20 rows, refreshing once on open.
            sections = [(nil, (1...20).map { Row(title: String(format: CYLScenarioLocalizedString(.smartTestDataRow), $0)) })]
            // SmartRefreshControl's way 1: create, attach and bind in one call.
            let delivery = CYLRefreshDeliveryHeader.attach(to: tableView, target: self, action: #selector(onRefresh))
            header = delivery
            delivery.beginRefreshing()
            return
        }
        sections = [(nil, themeRows()), (CYLScenarioLocalizedString(.smartTestData), testRows(count: 8))]
        if method == "smartClassicsFooter" {
            let classics = CYLRefreshBackNormalFooter()
            classics.attach(to: tableView)
            classics.addTarget(self, action: #selector(onLoadMore))
            footer = classics
            defaultAccent = classics.colorAccent
            defaultPrimary = classics.colorPrimary
            return
        }
        // SmartRefreshControl's way 3: create first, then attach and bind.
        let control = makeHeader()
        control.attach(to: tableView)
        control.addTarget(self, action: #selector(onRefresh))
        header = control
        defaultAccent = control.colorAccent
        defaultPrimary = control.colorPrimary
        control.beginRefreshing()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let bar = navigationController?.navigationBar else { return }
        savedAppearance = (bar.standardAppearance.copy(), bar.scrollEdgeAppearance?.copy(), bar.tintColor)
        // UIFlyController and UIWaveSwipeController open in the style's own blue.
        if method == "smartFly" {
            applyTheme(primary: UIColor(red: 0.2, green: 0.6, blue: 1, alpha: 1), accent: .white)
        } else if method == "smartWaveSwipe" {
            defaultPrimary = .clear
            applyTheme(primary: .systemBlue, accent: .white)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let bar = navigationController?.navigationBar, let saved = savedAppearance else { return }
        bar.standardAppearance = saved.standard
        bar.scrollEdgeAppearance = saved.scrollEdge
        bar.tintColor = saved.tint
    }

    // MARK: - Data and styles

    /// The header of each style (SmartRefreshControl's per-style controllers).
    private func makeHeader() -> CYLRefreshHeader {
        switch method {
        case "smartDropBox": return CYLRefreshDropBoxHeader()
        case "smartPhoenix": return CYLRefreshPhoenixHeader()
        case "smartTaurus": return CYLRefreshTaurusHeader()
        case "smartBezierRadar": return CYLRefreshBezierRadarHeader()
        case "smartBezierCircle": return CYLRefreshBezierCircleHeader()
        case "smartStoreHouse": return CYLRefreshStoreHouseHeader()
        case "smartWaveSwipe": return CYLRefreshWaveSwipeHeader()
        case "smartOriginal": return CYLRefreshOriginalHeader()
        case "smartMaterial": return CYLRefreshMaterialHeader()
        case "smartGameHitBlock": return CYLRefreshGameHitBlockHeader()
        case "smartGameBattleCity": return CYLRefreshGameBattleCityHeader()
        case "smartFly": return CYLRefreshFlyHeader()
        default: return CYLRefreshNormalHeader()
        }
    }

    private func themeRows() -> [Row] {
        let restore = CYLScenarioLocalizedString(.smartTapToRestore)
        let change = CYLScenarioLocalizedString(.smartTapToSwitch)
        return [
            Row(title: CYLScenarioLocalizedString(.smartThemeDefault), detail: restore) { [weak self] in
                guard let self = self else { return }
                self.applyTheme(primary: self.defaultPrimary, accent: self.defaultAccent)
            },
            Row(title: CYLScenarioLocalizedString(.smartThemeOrange), detail: change) { [weak self] in
                self?.applyTheme(primary: .systemOrange, accent: .white)
            },
            Row(title: CYLScenarioLocalizedString(.smartThemeRed), detail: change) { [weak self] in
                self?.applyTheme(primary: .systemRed, accent: .white)
            },
            Row(title: CYLScenarioLocalizedString(.smartThemeGreen), detail: change) { [weak self] in
                self?.applyTheme(primary: .systemGreen, accent: .white)
            },
            Row(title: CYLScenarioLocalizedString(.smartThemeBlue), detail: change) { [weak self] in
                self?.applyTheme(primary: .systemBlue, accent: .white)
            },
        ]
    }

    private func testRows(count: Int) -> [Row] {
        (1...count).map { Row(title: String(format: CYLScenarioLocalizedString(.smartTestDataRow), $0)) }
    }

    /// UIDemoHeaderController.changeTheme: colors the control and the navigation bar, and refreshes once.
    private func applyTheme(primary: UIColor?, accent: UIColor?) {
        let control: CYLRefreshComponent? = header ?? footer
        control?.colorAccent = accent
        control?.colorPrimary = primary
        if header != nil { header?.beginRefreshing() }
        guard let bar = navigationController?.navigationBar, let saved = savedAppearance else { return }
        let isDefault = primary == defaultPrimary && accent == defaultAccent
        if isDefault || primary == nil || primary == .clear {
            bar.standardAppearance = saved.standard
            bar.scrollEdgeAppearance = saved.scrollEdge
            bar.tintColor = saved.tint
            return
        }
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = primary
        appearance.shadowColor = .clear
        if let accent = accent {
            appearance.titleTextAttributes = [.foregroundColor: accent]
        }
        bar.standardAppearance = appearance
        bar.scrollEdgeAppearance = appearance
        bar.tintColor = accent
    }

    // MARK: - Taps

    /// UIDemoHeaderController.onRefresh: ends 2.5 seconds later.
    @objc private func onRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.header?.endRefreshing()
        }
    }

    /// UIDemoFooterController.onLoadMore: doubles the test rows, then reports no more data past 16 rows.
    @objc private func onLoadMore() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            guard let self = self, let last = self.sections.indices.last else { return }
            self.sections[last].rows = self.testRows(count: self.sections[last].rows.count * 2)
            self.tableView.reloadData()
            if self.sections[last].rows.count <= 16 {
                self.footer?.endRefreshing()
            } else {
                self.footer?.endRefreshingWithNoMoreData()
            }
        }
    }

    // MARK: - Table

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath)
        let row = sections[indexPath.section].rows[indexPath.row]
        var content = UIListContentConfiguration.valueCell()
        content.text = row.title
        content.secondaryText = row.detail
        cell.contentConfiguration = content
        cell.accessibilityTraits = row.action == nil ? .staticText : .button
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        sections[indexPath.section].rows[indexPath.row].action?()
    }
}
