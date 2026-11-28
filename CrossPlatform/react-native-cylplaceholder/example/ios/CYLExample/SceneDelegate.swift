import React
import React_RCTAppDelegate
import UIKit

/// [EN] Puts React Native's root view in the window of the scene (UIScene lifecycle, required by iOS 27); the app delegate set up the factory.
/// [CN] 把 React Native 的根视图放进场景的窗口（UIScene 生命周期，iOS 27 要求）；工厂由应用代理准备好。
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene,
          let appDelegate = UIApplication.shared.delegate as? RCTAppDelegate else { return }
    let rootView = appDelegate.rootViewFactory.view(
      withModuleName: appDelegate.moduleName ?? "CYLExample",
      initialProperties: appDelegate.initialProps,
      launchOptions: nil
    )
    let viewController = appDelegate.createRootViewController()
    appDelegate.setRootView(rootView, toRootViewController: viewController)
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = viewController
    window.makeKeyAndVisible()
    self.window = window
    appDelegate.window = window
  }
}
