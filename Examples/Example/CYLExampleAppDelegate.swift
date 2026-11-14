//
//  CYLExampleAppDelegate.swift
//  CYLNoResultTableViewController
//
//  Created by 微博@iOS程序犭袁 ( http://weibo.com/luohanchenyilong/ ) on 15/12/22.
//  Copyright © 2015年 https://github.com/ChenYilong . All rights reserved.
//
//  [EN] Swift translation of AppDelegate.h/.m and main.m. `@main` replaces main.m.
//  [CN] AppDelegate.h/.m 与 main.m 的 Swift 版本，`@main` 取代 main.m。
//

import UIKit

@main
final class CYLExampleAppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let navigationBar = UINavigationBar.appearance()
        navigationBar.tintColor = .white
        navigationBar.titleTextAttributes = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.white,
        ]
        navigationBar.barTintColor = UIColor(red: 51 / 255, green: 171 / 255, blue: 160 / 255, alpha: 1)
        navigationBar.isTranslucent = false
        // The window is created by CYLSceneDelegate.
        return true
    }
}

/// UIScene lifecycle: iOS 26 apps built with a current SDK must adopt it, or UIKit stops at launch.
/// Named in Info.plist (UIApplicationSceneManifest) as `CYLSceneDelegate`; `@objc(CYLSceneDelegate)` keeps that
/// Objective-C class name independent of the Swift module name.
@available(iOS 13.0, *)
@objc(CYLSceneDelegate)
final class CYLSceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(rootViewController: CYLExampleViewController())
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        self.window = window
    }
}
