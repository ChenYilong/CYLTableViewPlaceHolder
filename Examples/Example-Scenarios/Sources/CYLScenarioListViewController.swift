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
        // A missing permission is its own category, not a network failure; it gets its own section.
        let isPermission = { CYLPlaceholderScenarioCatalog.category(for: $0) == .permission }
        let hasScreenshots = { !CYLPlaceholderScenarioCatalog.readmeScreenshotNumbers(for: $0).isEmpty }
        let readme = all.filter { hasScreenshots($0) && !isPermission($0) }
        let permissions = all.filter(isPermission)
        let business = all.filter { !hasScreenshots($0) && !isPermission($0) }
        return [
            Section(title: CYLScenarioLocalizedString(.sectionReadme), scenarios: readme),
            Section(title: CYLScenarioLocalizedString(.sectionPermissions), scenarios: permissions),
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

    /// The last section lists the configuration files (CYLConfigurationViewController).
    private let configurations = CYLConfigurationFiles.urls()

    private func isConfigurationSection(_ section: Int) -> Bool {
        section == sections.count
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count + 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isConfigurationSection(section) ? configurations.count : sections[section].scenarios.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        isConfigurationSection(section) ? CYLScenarioLocalizedString(.sectionConfigurations) : sections[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scenario", for: indexPath)
        if isConfigurationSection(indexPath.section) {
            // File names and initializer names are identifiers and are not translated.
            let url = configurations[indexPath.row]
            var content = UIListContentConfiguration.subtitleCell()
            content.text = url.lastPathComponent
            content.secondaryText = url.pathExtension == "plist" ? "CYLPlaceholderStackView(contentsOf:actions:) · plist"
                : "CYLPlaceholderStackView(contentsOf:) / (configuration:) · JSON"
            content.secondaryTextProperties.color = .secondaryLabel
            // System image on a list cell: a row icon, not a placeholder, so CYLPlaceholderView does not apply.
            content.image = UIImage(systemName: "doc.text")
            content.imageProperties.tintColor = .systemTeal
            cell.contentConfiguration = content
            cell.accessoryType = .disclosureIndicator
            cell.accessibilityIdentifier = "configuration-\(url.deletingPathExtension().lastPathComponent)"
            return cell
        }
        let scenario = sections[indexPath.section].scenarios[indexPath.row]
        var content = UIListContentConfiguration.subtitleCell()
        content.text = CYLPlaceholderScenarioCatalog.localizedName(for: scenario)
        content.secondaryText = Self.detail(for: scenario)
        content.secondaryTextProperties.color = .secondaryLabel
        // System image on a list cell: a row icon, not a placeholder, so CYLPlaceholderView does not apply.
        content.image = UIImage(systemName: Self.symbol(for: scenario))
        content.imageProperties.tintColor = .systemTeal
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        cell.accessibilityIdentifier = "scenario-\(scenario.rawValue)"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isConfigurationSection(indexPath.section) {
            let next = CYLConfigurationViewController(url: configurations[indexPath.row])
            navigationController?.pushViewController(next, animated: true)
            return
        }
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

    /// The permission, else the action a scenario offers, decides its list icon.
    private static func symbol(for scenario: CYLPlaceholderScenario) -> String {
        switch CYLPlaceholderScenarioCatalog.permission(for: scenario) {
        case .location: return "location.slash"
        case .camera: return "camera"
        case .photoLibrary: return "photo.on.rectangle"
        case .microphone: return "mic.slash"
        case .contacts: return "person.2"
        case .calendar: return "calendar"
        case .bluetooth: return "antenna.radiowaves.left.and.right"
        case .notifications: return "bell.slash"
        default: break
        }
        if CYLPlaceholderScenarioCatalog.category(for: scenario) == .permission { return "lock.shield" }
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
