//
//  CYLScenarioTabBarController.swift
//  Example-Scenarios
//

import UIKit
import CYLTabBarController
import CYLTableViewPlaceHolder

/// The navigation controller of every tab. UIKit asks a navigation controller with a visible bar for its own status bar
/// style, not for the top screen's; the tag-list screens decide their style (`CYLTagListScreenViewController`), so the top
/// screen is consulted here (without it the light gradient page showed a white clock, tested 2026-11-26). A screen that sets
/// nothing keeps the system's pick.
final class CYLScenarioNavigationController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? { topViewController }
}

/// Five tabs and a plus button with a page of its own, modeled on CYLTabBarController's Objective-C demo and created the
/// examples' default way ("Integrating CYLTabBarController in the examples"): the tabs, their titles and images and the
/// plus button come from `CYLScenarioExample.bundle/TabBar/tabbar.json`, the pages from `CYLTabBarPageRegistry`.
final class CYLScenarioTabBarController: CYLTabBarController {

    /// The configuration file, inside the example's own bundle.
    static let configurationPath = CYLScenarioExampleBundle()?.path(forResource: "tabbar", ofType: "json", inDirectory: "TabBar")

    /// The page of each `CYLTabBarItemPageIdentifier` of the file, with the title key of its navigation bar.
    private static let pages: [(identifier: String, title: CYLScenarioL10n, make: () -> UIViewController)] = [
        // Every scenario of the core catalog (README screenshots and business cases); the language button is here.
        ("scenarios", .tabScenarios, { CYLScenarioListViewController() }),
        // Every animation bundled in CYLTableViewPlaceHolder.bundle/Animations.
        ("animations", .tabAnimations, { CYLAnimationListViewController() }),
        // Table and collection integration: switching states, custom frames, refresh controls.
        ("flows", .tabFlows, { CYLFlowListViewController() }),
        // A feed that loads, fails and refreshes with CYLRefresh.
        ("feed", .tabFeed, { CYLFeedViewController() }),
        // MJRefresh's example layer in Swift on the CYLRefresh API, plus GIF, Lottie, PAG and Rive icons.
        ("refresh", .tabRefresh, { CYLRefreshExampleViewController() }),
        // The plus button's own page (`plusChildViewController`): Uploading, then Success with Done.
        ("publish", .actionPublish, { CYLPublishViewController() }),
    ]

    /// Registers a provider for every page identifier of the file in the shared registry; registering again replaces
    /// them, so each rebuild after a language change gets new pages.
    static func registerPages() {
        for page in pages {
            CYLTabBarPageRegistry.shared.register(factory: { _ in
                let root = page.make()
                root.title = CYLScenarioLocalizedString(page.title)
                let navigation = CYLScenarioNavigationController(rootViewController: root)
                navigation.navigationBar.prefersLargeTitles = true
                return navigation
            }, forPageIdentifier: page.identifier)
        }
    }

    static func makeForDemo() -> UIViewController {
        registerPages()
        do {
            guard let path = configurationPath else {
                throw NSError(domain: "Example-Scenarios", code: 1,
                              userInfo: [NSLocalizedDescriptionKey: "CYLScenarioExample.bundle/TabBar/tabbar.json is missing"])
            }
            return try CYLScenarioTabBarController(configurationFile: path)
        } catch {
            // The file ships in the app; a failure is a build mistake, shown instead of an empty tab bar.
            NSLog("Example-Scenarios: %@", error.localizedDescription)
            let message = UILabel()
            message.text = error.localizedDescription
            message.numberOfLines = 0
            message.textAlignment = .center
            let page = UIViewController()
            page.view = message
            page.view.backgroundColor = .systemBackground
            return page
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .systemTeal
        labelPlusButton()
    }

    /// What the configuration file cannot hold: the plus button's localized accessibility label and its identifier
    /// (its teal image is the asset `CYLScenarioPlusButton`, named in the file). The tab bar creates the button while it
    /// lays out, so this runs again until the button exists.
    private func labelPlusButton() {
        guard let plusButton = CYLPlusButton(forOwner: self) ?? CYLPlusButton(forTabBarContext: context) else { return }
        guard plusButton.accessibilityIdentifier != "plusButton" else { return }
        plusButton.accessibilityLabel = CYLScenarioLocalizedString(.actionPublish)
        plusButton.accessibilityIdentifier = "plusButton"
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        labelPlusButton()
    }

    /// `-CYLRiveRoomsPage`: switch once to the Animations tab, which opens the house.riv Rooms page.
    private var showedRoomsPage = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !showedRoomsPage, ProcessInfo.processInfo.arguments.contains("-CYLRiveRoomsPage") else { return }
        showedRoomsPage = true
        selectedIndex = 1
    }
}

/// The plus button's page: the Uploading scenario (GIF), then the Success scenario, whose "Done" button goes back to
/// the first tab. It starts over each time the plus button selects it.
final class CYLPublishViewController: UIViewController {

    private var placeholder: CYLPlaceholderStackView?
    private var successWork: DispatchWorkItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        show(CYLPlaceholderStackView(scenario: .uploading, actions: nil))
        let work = DispatchWorkItem { [weak self] in
            self?.show(CYLPlaceholderStackView(scenario: .success, actions: [
                .done: { [weak self] _, _ in self?.close() },
            ]))
        }
        successWork?.cancel()
        successWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: work)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        successWork?.cancel()
    }

    private func show(_ placeholder: CYLPlaceholderStackView) {
        self.placeholder?.removeFromSuperview()
        self.placeholder = placeholder
        placeholder.frame = view.bounds
        placeholder.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(placeholder)
    }

    private func close() {
        tabBarController?.selectedIndex = 0
    }
}
