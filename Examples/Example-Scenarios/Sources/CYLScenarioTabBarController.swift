//
//  CYLScenarioTabBarController.swift
//  Example-Scenarios
//

import UIKit
import CYLTabBarController
import CYLTableViewPlaceHolder

/// Four tabs and a plus button, modeled on CYLTabBarController's Objective-C demo.
final class CYLScenarioTabBarController: CYLTabBarController {

    private struct Tab {
        let root: UIViewController
        let title: CYLScenarioL10n
        let image: String
        let selectedImage: String
    }

    static func makeForDemo() -> CYLScenarioTabBarController {
        let tabs = [
            // Every scenario of the core catalog (README screenshots and business cases); the language button is here.
            Tab(root: CYLScenarioListViewController(), title: .tabScenarios,
                image: "rectangle.stack", selectedImage: "rectangle.stack.fill"),
            // Every animation bundled in CYLTableViewPlaceHolder.bundle/Animations.
            Tab(root: CYLAnimationListViewController(), title: .tabAnimations, image: "sparkles", selectedImage: "sparkles"),
            // Table and collection integration: switching states, custom frames, refresh controls.
            Tab(root: CYLFlowListViewController(), title: .tabFlows,
                image: "arrow.triangle.branch", selectedImage: "arrow.triangle.branch"),
            // A feed that loads, fails and refreshes with CYLRefresh.
            Tab(root: CYLFeedViewController(), title: .tabFeed,
                image: "bubble.left.and.bubble.right", selectedImage: "bubble.left.and.bubble.right.fill"),
        ]
        let viewControllers: [UIViewController] = tabs.map { tab in
            tab.root.title = CYLScenarioLocalizedString(tab.title)
            let navigation = UINavigationController(rootViewController: tab.root)
            navigation.navigationBar.prefersLargeTitles = true
            return navigation
        }
        let attributes: [[AnyHashable: Any]] = tabs.map { tab in
            var item: [AnyHashable: Any] = [CYLTabBarItemTitle: CYLScenarioLocalizedString(tab.title)]
            item[CYLTabBarItemImage] = UIImage(systemName: tab.image)
            item[CYLTabBarItemSelectedImage] = UIImage(systemName: tab.selectedImage)
            return item
        }
        return CYLScenarioTabBarController(viewControllers: viewControllers, tabBarItemsAttributes: attributes)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .systemTeal
    }
}

/// The plus button opens the publish page: uploading, then success.
final class CYLScenarioPlusButton: CYLPlusButton, CYLPlusButtonSubclassing {

    static func plusButton() -> Any {
        let button = CYLScenarioPlusButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 38, weight: .bold)
        button.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: configuration), for: .normal)
        button.tintColor = .systemTeal
        button.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        button.accessibilityLabel = CYLScenarioLocalizedString(.actionPublish)
        button.accessibilityIdentifier = "plusButton"
        button.addTarget(button, action: #selector(publish), for: .touchUpInside)
        return button
    }

    /// Raises the button a little above the tab bar's center.
    static func constantOfPlusButtonCenterYOffset(forTabBarHeight tabBarHeight: CGFloat) -> CGFloat {
        -6
    }

    @objc private func publish() {
        var presenter = window?.rootViewController
        while let presented = presenter?.presentedViewController {
            presenter = presented
        }
        presenter?.present(UINavigationController(rootViewController: CYLPublishViewController()), animated: true)
    }
}

/// The Uploading scenario (GIF), then the Success scenario, whose "Done" button closes the page.
final class CYLPublishViewController: UIViewController {

    private var placeholder: CYLPlaceholderStackView?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = CYLScenarioLocalizedString(.actionPublish)
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self,
                                                           action: #selector(close))
        show(CYLPlaceholderStackView(scenario: .uploading, actions: nil))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.show(CYLPlaceholderStackView(scenario: .success, actions: [
                .done: { [weak self] _, _ in self?.close() },
            ]))
        }
    }

    private func show(_ placeholder: CYLPlaceholderStackView) {
        self.placeholder?.removeFromSuperview()
        self.placeholder = placeholder
        placeholder.frame = view.bounds
        placeholder.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(placeholder)
    }

    @objc private func close() {
        dismiss(animated: true)
    }
}
