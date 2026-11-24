import React
import React_RCTAppDelegate
import UIKit

/// [EN] The React Native 0.76 app delegate in Swift (the examples are Swift, `instructions/macos.md`); the old architecture, as the Android half.
/// [CN] Swift 编写的 React Native 0.76 应用代理（示例使用 Swift，见 `instructions/macos.md`）；使用旧架构，与 Android 一致。
@main
class AppDelegate: RCTAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    moduleName = "CYLExample"
    initialProps = [:]
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func sourceURL(for bridge: RCTBridge) -> URL? {
    bundleURL()
  }

  override func bundleURL() -> URL? {
    #if DEBUG
    RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index")
    #else
    Bundle.main.url(forResource: "main", withExtension: "jsbundle")
    #endif
  }
}
