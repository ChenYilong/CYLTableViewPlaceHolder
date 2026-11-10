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
//  - done:           goes back
//

import UIKit
import CYLTableViewPlaceHolder

final class CYLScenarioDetailViewController: UITableViewController {

    private let scenario: CYLPlaceholderScenario
    private var isLoading = false
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: CYLScenarioLocalizedString(.actionClear),
                                                            style: .plain, target: self, action: #selector(clear))
        tableView.cyl_placeholderViewBlock({ [weak self] _ in
            self?.makePlaceholder()
        })
        tableView.reloadData()
    }

    private func makePlaceholder() -> UIView {
        if isLoading {
            return CYLPlaceholderStackView(scenario: .loading, actions: nil)
        }
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
                self?.showFeedback(CYLScenarioLocalizedString(.feedbackGoShopping))
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
            self.showFeedback(CYLScenarioLocalizedString(.feedbackRetry))
        }
    }

    @objc private func clear() {
        isLoading = false
        rows = 0
        tableView.reloadData()
    }

    private func showFeedback(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak alert] in
            alert?.dismiss(animated: true)
        }
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
