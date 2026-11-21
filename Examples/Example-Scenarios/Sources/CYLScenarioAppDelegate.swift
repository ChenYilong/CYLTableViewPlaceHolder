//
//  CYLScenarioAppDelegate.swift
//  Example-Scenarios
//

import UIKit
import CYLTabBarController
import CYLTableViewPlaceHolder

@main
final class CYLScenarioAppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        true
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        configuration.delegateClass = CYLScenarioSceneDelegate.self
        return configuration
    }
}

/// UIScene lifecycle: iOS 26 apps built with a current SDK must adopt it, or UIKit stops at launch.
final class CYLScenarioSceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.backgroundColor = .systemBackground
        // `-localizationCheck` shows the example table's lookup check instead of the demo, with no root provider, so
        // the check's language switches do not rebuild the root (CYLScenarioLocalization.swift).
        if ProcessInfo.processInfo.arguments.contains("-localizationCheck") {
            window.rootViewController = CYLScenarioLocalizationCheckViewController()
            window.makeKeyAndVisible()
            self.window = window
            return
        }
        // As in CYLTabBarController's Objective-C demo: the root is rebuilt after every language change
        // (`CYLScenarioLanguage.select(_:)` posts it), so every text, core and example, shows in the new language.
        // The plus button comes from the configuration file (`CYLTabBarControllerPlusButton`), registered by the tab bar
        // controller for the file's context, so nothing is registered here.
        window.cyl_setRootViewControllerProvider {
            CYLScenarioTabBarController.makeForDemo()
        }
        window.makeKeyAndVisible()
        self.window = window
    }
}
