//
//  CYLScenarioListViewController.swift
//  Example-Scenarios
//
//  The entry page: every scenario of `CYLPlaceholderScenarioCatalog`, the README screenshots first, then the business
//  cases. Names, components and texts all come from the core; the example only lists them. The language button sits
//  at the top of this page.
//

import UIKit
import CYLTableViewPlaceHolder

final class CYLScenarioListViewController: UITableViewController {

    private struct Section {
        let title: String
        let scenarios: [CYLPlaceholderScenario]
    }

    private let sections: [Section] = {
        let all = CYLPlaceholderScenarioCatalog.allScenarios.compactMap { CYLPlaceholderScenario(rawValue: $0.intValue) }
        let readme = all.filter { !CYLPlaceholderScenarioCatalog.readmeScreenshotNumbers(for: $0).isEmpty }
        let business = all.filter { CYLPlaceholderScenarioCatalog.readmeScreenshotNumbers(for: $0).isEmpty }
        return [
            Section(title: CYLScenarioLocalizedString(.sectionReadme), scenarios: readme),
            Section(title: CYLScenarioLocalizedString(.sectionBusiness), scenarios: business),
        ]
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
        navigationItem.rightBarButtonItem = CYLScenarioLanguage.barButtonItem()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "scenario")
        tableView.accessibilityIdentifier = "scenarioList"
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].scenarios.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scenario", for: indexPath)
        let scenario = sections[indexPath.section].scenarios[indexPath.row]
        var content = UIListContentConfiguration.subtitleCell()
        content.text = CYLPlaceholderScenarioCatalog.localizedName(for: scenario)
        content.secondaryText = Self.detail(for: scenario)
        content.secondaryTextProperties.color = .secondaryLabel
        content.image = UIImage(systemName: Self.symbol(for: scenario))
        content.imageProperties.tintColor = .systemTeal
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        cell.accessibilityIdentifier = "scenario-\(scenario.rawValue)"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let scenario = sections[indexPath.section].scenarios[indexPath.row]
        navigationController?.pushViewController(CYLScenarioDetailViewController(scenario: scenario), animated: true)
    }

    /// "README #01, #02 · 3 components", or only the component count for a business case.
    private static func detail(for scenario: CYLPlaceholderScenario) -> String {
        let count = CYLPlaceholderScenarioCatalog.components(for: scenario).count
        let components = CYLScenarioLocalizedFormat(.formatComponents, count)
        let numbers = CYLPlaceholderScenarioCatalog.readmeScreenshotNumbers(for: scenario)
        guard !numbers.isEmpty else { return components }
        let list = numbers.map { String(format: "#%02ld", $0.intValue) }.joined(separator: ", ")
        return CYLScenarioLocalizedFormat(.formatReadmeNumbers, list) + " · " + components
    }

    /// The action a scenario offers decides its list icon.
    private static func symbol(for scenario: CYLPlaceholderScenario) -> String {
        let actions = Set(CYLPlaceholderScenarioCatalog.components(for: scenario).compactMap(\.action))
        if actions.contains(.contactSupport) { return "headphones" }
        if actions.contains(.openSettings) { return "gearshape" }
        if actions.contains(.goShopping) { return "cart" }
        if actions.contains(.done) { return "checkmark.circle" }
        if actions.contains(.retry) || CYLPlaceholderScenarioCatalog.backgroundAction(for: scenario) != nil {
            return "arrow.clockwise"
        }
        return "rectangle.dashed"
    }
}
