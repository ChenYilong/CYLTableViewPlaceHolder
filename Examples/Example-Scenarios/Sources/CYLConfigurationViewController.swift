//
//  CYLConfigurationViewController.swift
//  Example-Scenarios
//
//  One configuration file of CYLScenarioExample.bundle/Configurations (JSON or plist), turned into a placeholder by the
//  core: `CYLPlaceholderStackView(contentsOf:actions:)`. A file that names the example's own texts
//  ("exampleTitleKey") is read here, its texts resolved from the example bundle, then passed to
//  `CYLPlaceholderStackView(configuration:actions:)`, so the core never reads the example's bundle.
//
//  The files show every configuration option: a scenario with overrides, custom components, the tap highlight styles,
//  interaction turned off, the animation repeat count, the four animation formats and raw item attributes.
//

import UIKit
import CYLTableViewPlaceHolder

enum CYLConfigurationFiles {
    /// The configuration files in the example bundle, sorted by name.
    static func urls() -> [URL] {
        guard let folder = CYLScenarioExampleResourceURL("Configurations") else { return [] }
        let files = (try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)) ?? []
        return files.filter { ["json", "plist"].contains($0.pathExtension) }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }
}

final class CYLConfigurationViewController: UIViewController {

    private let url: URL
    private var placeholder: UIView?

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
        title = url.lastPathComponent
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
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: CYLScenarioLocalizedString(.actionShowFile), style: .plain, target: self,
                            action: #selector(showFile)),
            UIBarButtonItem(title: CYLScenarioLocalizedString(.actionReplay), style: .plain, target: self,
                            action: #selector(reload)),
        ]
        reload()
    }

    /// Every action a configuration can name, each confirming the tap.
    private var actions: [CYLPlaceholderAction: CYLPlaceholderActionHandler] {
        let names: [CYLPlaceholderAction] = [.retry, .contactSupport, .openSettings, .goShopping, .done, .chooseManually]
        var handlers: [CYLPlaceholderAction: CYLPlaceholderActionHandler] = [:]
        for action in names {
            handlers[action] = { [weak self] _, action in
                let title = CYLPlaceholderScenarioCatalog.localizedTitle(for: action) ?? action.rawValue
                self?.cyl_showFeedback(CYLScenarioLocalizedFormat(.formatActionTapped, title))
            }
        }
        return handlers
    }

    @objc private func reload() {
        placeholder?.removeFromSuperview()
        let made: UIView
        do {
            made = try makePlaceholder()
        } catch {
            // A broken file shows its error instead of a placeholder.
            let label = UILabel()
            label.numberOfLines = 0
            label.textAlignment = .center
            label.textColor = .systemRed
            label.text = error.localizedDescription
            made = label
        }
        // A placeholder with a status bar spans the full width under the navigation bar, so the bar shows edge to edge.
        let inset: CGFloat = (made as? CYLPlaceholderStackView)?.statusView == nil ? 16 : 0
        made.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(made)
        NSLayoutConstraint.activate([
            made.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            made.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            made.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset),
            made.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset),
        ])
        placeholder = made
    }

    private func makePlaceholder() throws -> CYLPlaceholderStackView {
        let data = try Data(contentsOf: url)
        guard url.pathExtension == "json", String(decoding: data, as: UTF8.self).contains("exampleTitleKey") else {
            // The core reads the file itself.
            return try CYLPlaceholderStackView(contentsOf: url, actions: actions)
        }
        let object = try JSONSerialization.jsonObject(with: data)
        guard let configuration = Self.resolvingExampleTexts(object) as? [String: Any] else {
            throw CocoaError(.fileReadCorruptFile)
        }
        return try CYLPlaceholderStackView(configuration: configuration, actions: actions)
    }

    /// Replaces each "exampleTitleKey" with a "title" read from the example bundle.
    private static func resolvingExampleTexts(_ value: Any) -> Any {
        if let array = value as? [Any] {
            return array.map(resolvingExampleTexts)
        }
        guard var dictionary = value as? [String: Any] else { return value }
        if let key = dictionary.removeValue(forKey: "exampleTitleKey") as? String, let l10n = CYLScenarioL10n(rawValue: key) {
            dictionary["title"] = CYLScenarioLocalizedString(l10n)
        }
        return dictionary.mapValues(resolvingExampleTexts)
    }

    @objc private func showFile() {
        let controller = UIViewController()
        controller.title = url.lastPathComponent
        let textView = UITextView()
        textView.isEditable = false
        textView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.text = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
        controller.view = textView
        navigationController?.pushViewController(controller, animated: true)
    }

}
