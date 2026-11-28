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

final class CYLScenarioListViewController: CYLTagListScreenViewController {

    private struct Group {
        let title: String
        let scenarios: [CYLPlaceholderScenario]
    }

    private let groups: [Group] = {
        let all = CYLPlaceholderScenarioCatalog.allScenarios.compactMap { CYLPlaceholderScenario(rawValue: $0.intValue) }
        // A missing permission is its own category, not a network failure; it gets its own section.
        let isPermission = { CYLPlaceholderScenarioCatalog.category(for: $0) == .permission }
        let hasScreenshots = { !CYLPlaceholderScenarioCatalog.readmeScreenshotNumbers(for: $0).isEmpty }
        let readme = all.filter { hasScreenshots($0) && !isPermission($0) }
        let permissions = all.filter(isPermission)
        let business = all.filter { !hasScreenshots($0) && !isPermission($0) }
        return [
            Group(title: CYLScenarioLocalizedString(.sectionReadme), scenarios: readme),
            Group(title: CYLScenarioLocalizedString(.sectionPermissions), scenarios: permissions),
            Group(title: CYLScenarioLocalizedString(.sectionBusiness), scenarios: business),
        ]
    }()

    /// The last section lists the configuration files (CYLConfigurationViewController).
    private let configurations = CYLConfigurationFiles.urls()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        navigationItem.rightBarButtonItem = CYLScenarioLanguage.barButtonItem()
        sections = makeSections()
        super.viewDidLoad()
        tagList.accessibilityIdentifier = "scenarioList"
    }

    private func makeSections() -> [CYLTagSection] {
        var result = groups.map { group in
            CYLTagSection(title: group.title, entries: group.scenarios.map { scenario in
                CYLTagEntry(title: CYLPlaceholderScenarioCatalog.localizedName(for: scenario),
                            subtitle: Self.detail(for: scenario), symbol: Self.symbol(for: scenario),
                            accessibilityIdentifier: "scenario-\(scenario.rawValue)") { [weak self] in
                    self?.navigationController?.pushViewController(CYLScenarioDetailViewController(scenario: scenario),
                                                                   animated: true)
                }
            })
        }
        result.append(CYLTagSection(title: CYLScenarioLocalizedString(.sectionConfigurations),
                                    entries: configurations.map { url in
            // File names and initializer names are identifiers and are not translated.
            CYLTagEntry(title: url.lastPathComponent,
                        subtitle: url.pathExtension == "plist" ? "CYLPlaceholderStackView(contentsOf:actions:) · plist"
                            : "CYLPlaceholderStackView(contentsOf:) / (configuration:) · JSON",
                        symbol: "doc.text",
                        accessibilityIdentifier: "configuration-\(url.deletingPathExtension().lastPathComponent)") { [weak self] in
                self?.navigationController?.pushViewController(CYLConfigurationViewController(url: url), animated: true)
            }
        }))
        return result
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
