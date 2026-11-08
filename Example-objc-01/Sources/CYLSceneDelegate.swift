//
//  Adapted from TestRefreshDemo by Jerry Jiang, 2022/9/30.
//
import UIKit

class CYLSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(rootViewController: CYLViewController())
        window.backgroundColor = .white
        self.window = window
        window.makeKeyAndVisible()
    }
}
