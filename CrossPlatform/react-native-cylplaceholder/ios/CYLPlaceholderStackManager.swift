import React
import UIKit

/**
 * [EN] The React Native view manager of `CYLPlaceholderStackHostView`; the JavaScript name "CYLPlaceholderStack", the props and the
 *      event `onAction` are declared in `CYLPlaceholderReactBridge.m`, as on Android's `CYLPlaceholderStackManager`. The command
 *      `restartAnimation` runs on the UI thread.
 * [CN] `CYLPlaceholderStackHostView` 的 React Native View Manager；JavaScript 名称 “CYLPlaceholderStack”、属性与事件 `onAction`
 *      在 `CYLPlaceholderReactBridge.m` 中声明，与 Android 的 `CYLPlaceholderStackManager` 一致。命令 `restartAnimation` 在 UI 线程执行。
 */
@objc(CYLPlaceholderStackManager)
final class CYLPlaceholderStackManager: RCTViewManager {
    override static func requiresMainQueueSetup() -> Bool { true }

    override func view() -> UIView! {
        CYLPlaceholderStackHostView()
    }

    // [EN] The command `restartAnimation` of `UIManager.dispatchViewManagerCommand`. [CN] `UIManager.dispatchViewManagerCommand` 的 `restartAnimation` 命令。
    @objc(restartAnimation:)
    func restartAnimation(_ reactTag: NSNumber) {
        bridge.uiManager.addUIBlock { _, viewRegistry in
            (viewRegistry?[reactTag] as? CYLPlaceholderStackHostView)?.restartAnimation()
        }
    }
}
