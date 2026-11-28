//
//  CYLAccessibilityHostApp.swift
//  CYLTableViewPlaceHolder accessibility host
//
//  A minimal app for `Tests/run-accessibility-tests.rb`: XCUITest reads the
//  accessibility tree VoiceOver reads, and runs Apple's accessibility audit.
//  It compiles into the library's module (`CYLTableViewPlaceHolder`), so it needs no import of the library.
//

import UIKit

private final class CYLAccessibilityHostViewController: UIViewController {
    private var element: CYLPlaceholderView!
    private var grouped: CYLPlaceholderView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // 1. A configured placeholder: it is itself an accessibility element.
        do {
            element = try CYLPlaceholderView(itemAttributes: [
                CYLPlaceholderItemStyle: CYLPlaceholderStyle.inbox.rawValue,
                CYLPlaceholderItemTitle: "Inbox",
                CYLPlaceholderItemAccessibilityIdentifier: "element",
                CYLPlaceholderItemAccessibilityHint: "No messages yet",
                CYLPlaceholderItemTitleColor: UIColor.label,
                CYLPlaceholderItemTitleFont: UIFont.preferredFont(forTextStyle: .body)
            ], imageBundle: nil)
        } catch {
            assertionFailure("\(error)")
        }
        element.accessibilityValue = "Synced"
        element.placeholderBadgeValue = "3"
        element.badgeLabel.accessibilityIdentifier = "elementBadge"

        // 2. A plain placeholder inside an accessible container: the badge is read on its own.
        let group = UIView()
        group.accessibilityContainerType = .semanticGroup
        group.accessibilityLabel = "Notifications"
        group.accessibilityIdentifier = "group"
        grouped = CYLPlaceholderView(style: .notificationsOff, text: "Nothing new")
        grouped.textLabel.textColor = .label
        grouped.textLabel.font = UIFont.preferredFont(forTextStyle: .body)
        grouped.textLabel.accessibilityIdentifier = "groupTitle"
        _ = grouped.showBadge(with: .text, value: "New")
        grouped.badgeLabel.accessibilityIdentifier = "groupBadge"
        grouped.frame = CGRect(x: 0, y: 0, width: 320, height: 220)
        grouped.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        group.addSubview(grouped)

        // A button configuration wraps its title at large text sizes instead of clipping it.
        var toggleConfiguration = UIButton.Configuration.plain()
        toggleConfiguration.title = "Toggle selection"
        let toggle = UIButton(configuration: toggleConfiguration, primaryAction: nil)
        toggle.accessibilityIdentifier = "toggle"
        toggle.addTarget(self, action: #selector(toggleSelection), for: .touchUpInside)

        // A button configuration wraps its title at large text sizes instead of clipping it.
        var clearConfiguration = UIButton.Configuration.plain()
        clearConfiguration.title = "Clear badges"
        let clear = UIButton(configuration: clearConfiguration, primaryAction: nil)
        clear.accessibilityIdentifier = "clear"
        clear.addTarget(self, action: #selector(clearBadges), for: .touchUpInside)

        // `-CYLShow element|group|buttons` shows one part only, so an audit issue can be attributed.
        let only = UserDefaults.standard.string(forKey: "CYLShow")
        var parts = [UIView]()
        if only == nil || only == "element" { parts.append(element) }
        if only == nil || only == "group" { parts.append(group) }
        if only == nil || only == "buttons" { parts.append(contentsOf: [toggle, clear]) }
        let stack = UIStackView(arrangedSubviews: parts)
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: safe.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: safe.bottomAnchor, constant: -16),
        ])
        for part in [element as UIView, group] where part.superview != nil {
            part.heightAnchor.constraint(equalToConstant: 220).isActive = true
        }
    }

    @objc private func toggleSelection() {
        element.isSelected = !element.isSelected
    }

    @objc private func clearBadges() {
        element.placeholderBadgeValue = nil
        grouped.placeholderBadgeValue = nil
    }
}

/**
 * UIScene lifecycle: iOS 26 traps apps that do not adopt it.
 */
final class CYLAccessibilityHostSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = CYLAccessibilityHostViewController()
        window.makeKeyAndVisible()
        self.window = window
    }
}

@main
final class CYLAccessibilityHostAppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Default", sessionRole: connectingSceneSession.role)
        configuration.delegateClass = CYLAccessibilityHostSceneDelegate.self
        return configuration
    }
}
