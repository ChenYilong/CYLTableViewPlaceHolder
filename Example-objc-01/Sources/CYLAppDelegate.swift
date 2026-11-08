//
//  Adapted from TestRefreshDemo by Jerry Jiang, 2022/9/30.
//
import UIKit

@main
class CYLAppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        configuration.delegateClass = CYLSceneDelegate.self
        return configuration
    }
}
