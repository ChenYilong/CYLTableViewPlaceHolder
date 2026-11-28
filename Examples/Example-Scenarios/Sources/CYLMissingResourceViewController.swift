//
//  CYLMissingResourceViewController.swift
//  Example-Scenarios
//
//  A placeholder whose animation file does not exist. The engine swallows that error; the core names the file in the red bar
//  under the navigation bar (`cylShowsMissingResources`, `CYLPlaceholderResourceReporter`): one file reads
//  "Missing resource: Demo.pag (file not found)", several read "Missing resources: Demo.pag +1 more". "Add" adds another
//  missing file; "Load" gives the placeholder a file that exists, which clears its entry.
//

import UIKit
import CYLTableViewPlaceHolder

final class CYLMissingResourceViewController: UITableViewController {

    private var extraViews = [CYLPlaceholderView]()
    private weak var mainView: CYLPlaceholderView?

    init() {
        super.init(style: .plain)
        title = CYLScenarioLocalizedString(.titleMissingResource)
        hidesBottomBarWhenPushed = true
        navigationItem.largeTitleDisplayMode = .never
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.accessibilityIdentifier = "missingResourceDemo"
        let add = UIBarButtonItem(title: CYLScenarioLocalizedString(.missingResourceAdd), style: .plain, target: self,
                                  action: #selector(addMissing))
        add.accessibilityIdentifier = "missingResourceAdd"
        let fix = UIBarButtonItem(title: CYLScenarioLocalizedString(.missingResourceFix), style: .plain, target: self,
                                  action: #selector(loadFile))
        fix.accessibilityIdentifier = "missingResourceFix"
        navigationItem.rightBarButtonItems = [fix, add]
        // The bar names the missing files of this page.
        cylShowsMissingResources = true
        // An empty table shows the placeholder, which asks for a file that is not there.
        tableView.cylPlaceholderViewBlock({ [weak self] _ in
            let attributes: [String: Any] = [
                CYLPlaceholderItemTitle: CYLScenarioLocalizedString(.titleMissingResource),
                CYLPlaceholderItemAnimationFilePath: "/nonexistent/Animations/Demo.pag",
            ]
            let view = try? CYLPlaceholderView(itemAttributes: attributes, imageBundle: nil)
            self?.mainView = view
            return view ?? UIView()
        })
    }

    @objc private func addMissing() {
        let name = "/nonexistent/Animations/Extra\(extraViews.count + 1).riv"
        if let view = try? CYLPlaceholderView(itemAttributes: [CYLPlaceholderItemTitle: name,
                                                               CYLPlaceholderItemAnimationFilePath: name], imageBundle: nil) {
            view.isHidden = true
            tableView.addSubview(view)
            extraViews.append(view)
        }
    }

    @objc private func loadFile() {
        guard let path = CYLPlaceholderView.path(forBundledAnimation: "CYLPlaceholderLoading.json") else { return }
        _ = mainView?.setAnimationFile(path)
        extraViews.forEach { $0.removeFromSuperview() }
        extraViews.removeAll()
    }
}
