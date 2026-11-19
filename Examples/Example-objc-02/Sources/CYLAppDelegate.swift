//
//  CYLAppDelegate.swift
//  Example-objc-02
//
//  Launch arguments (UI tests): `-paging` opens the paging table (MJRefresh #1430, and with `-pagingAutoFooter` the
//  automatic footer of MJRefresh #1610; `-pagingNoGrowth` makes its loads add no page) instead of the collection
//  (MJRefresh #1523, #1506, #1483); `-noMoreData` makes the collection footer end with "no more data"; `-sections`
//  opens the table with floating section headers (MJRefresh PR #1444).
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
        let arguments = ProcessInfo.processInfo.arguments
        let controller: UIViewController
        if arguments.contains("-sections") {
            controller = CYLSectionsViewController()
        } else if arguments.contains("-paging") {
            controller = CYLPagingViewController()
        } else {
            controller = CYLCollectionViewController()
        }
        window.rootViewController = UINavigationController(rootViewController: controller)
        self.window = window
        window.makeKeyAndVisible()
    }
}
