//
//  CYLScenarioDetailViewController.swift
//  Example-Scenarios
//
//  One scenario on an empty table: `CYLPlaceholderStackView(scenario:actions:)` builds the components, the example
//  only gives the handlers of their actions when the view is created:
//
//  - retry:          the Loading scenario, then data; "Clear" empties the table again
//  - contactSupport: pushes the support page
//  - openSettings:   opens the app's page in Settings
//  - goShopping:     a short confirmation
//  - chooseManually: a short confirmation (the location permission scenario offers to pick an address by hand)
//  - done:           goes back
//

import UIKit
import CYLTableViewPlaceHolder

final class CYLScenarioDetailViewController: UITableViewController {

    private let scenario: CYLPlaceholderScenario
    private var isLoading = false
    /// Every component's `tapInteractionEnabled`; off keeps the components visible but inert.
    private var interactionEnabled = true
    private var rows = 0

    init(scenario: CYLPlaceholderScenario) {
        self.scenario = scenario
        super.init(style: .plain)
        title = CYLPlaceholderScenarioCatalog.localizedName(for: scenario)
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
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: CYLScenarioLocalizedString(.actionClear), style: .plain, target: self,
                            action: #selector(clear)),
            interactionItem(),
        ]
        tableView.cyl_placeholderViewBlock({ [weak self] _ in
            self?.makePlaceholder()
        })
        tableView.reloadData()
    }

    private func interactionItem() -> UIBarButtonItem {
        let title = CYLScenarioLocalizedString(interactionEnabled ? .interactionOn : .interactionOff)
        let item = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(toggleInteraction))
        item.accessibilityIdentifier = "interactionToggle"
        return item
    }

    /// Each component exposes its own switch: off, a tap neither runs the action nor highlights.
    @objc private func toggleInteraction() {
        interactionEnabled.toggle()
        navigationItem.rightBarButtonItems?[1] = interactionItem()
        tableView.reloadData()
    }

    private func makePlaceholder() -> UIView {
        if isLoading {
            return CYLPlaceholderStackView(scenario: .loading, actions: nil)
        }
        let placeholder = makeScenarioPlaceholder()
        for component in placeholder.componentViews {
            component.isTapInteractionEnabled = interactionEnabled
        }
        return placeholder
    }

    private func makeScenarioPlaceholder() -> CYLPlaceholderStackView {
        return CYLPlaceholderStackView(scenario: scenario, actions: [
            .retry: { [weak self] _, _ in self?.retry() },
            .contactSupport: { [weak self] _, _ in
                self?.navigationController?.pushViewController(CYLSupportViewController(), animated: true)
            },
            .openSettings: { _, _ in
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            },
            .goShopping: { [weak self] _, _ in
                self?.cyl_showFeedback(CYLScenarioLocalizedString(.feedbackGoShopping))
            },
            .chooseManually: { [weak self] _, _ in
                self?.cyl_showFeedback(CYLScenarioLocalizedString(.feedbackChooseManually))
            },
            .done: { [weak self] _, _ in self?.navigationController?.popViewController(animated: true) },
        ])
    }

    private func retry() {
        isLoading = true
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let self = self else { return }
            self.isLoading = false
            self.rows = 12
            self.tableView.reloadData()
            self.cyl_showFeedback(CYLScenarioLocalizedString(.feedbackRetry))
        }
    }

    @objc private func clear() {
        isLoading = false
        rows = 0
        tableView.reloadData()
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows
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

/// The page "Contact support" pushes: the No Messages scenario with the example's own text under it.
final class CYLSupportViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = CYLScenarioLocalizedString(.supportTitle)
        view.backgroundColor = .systemBackground
        let placeholder = CYLPlaceholderStackView(components: [
            CYLPlaceholderComponent(bundledAnimation: "CYLPlaceholderContactSupport.json", fallbackStyle: .help,
                                    title: CYLScenarioLocalizedString(.supportTitle),
                                    size: CGSize(width: 120, height: 120), action: nil),
            CYLPlaceholderComponent.hint(text: CYLScenarioLocalizedString(.supportText)),
        ], actions: nil)
        placeholder.frame = view.bounds
        placeholder.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        placeholder.accessibilityIdentifier = "supportPage"
        view.addSubview(placeholder)
    }
}
