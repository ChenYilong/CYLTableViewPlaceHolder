//
//  CYLAppDelegate.swift
//  Example-objc-02
//
//  Launch arguments (UI tests): `-paging` opens the paging table (MJRefresh #1430) instead of the collection
//  (MJRefresh #1523, #1506, #1483); `-noMoreData` makes the collection footer end with "no more data".
//

import UIKit

@main
class CYLAppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        true
    }

    // UIScene lifecycle: iOS 26 apps built with a current SDK must adopt it, or UIKit stops at launch.
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        configuration.delegateClass = CYLSceneDelegate.self
        return configuration
    }
}

class CYLSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        let controller: UIViewController = ProcessInfo.processInfo.arguments.contains("-paging")
            ? CYLPagingViewController() : CYLCollectionViewController()
        window.rootViewController = UINavigationController(rootViewController: controller)
        self.window = window
        window.makeKeyAndVisible()
    }
}
