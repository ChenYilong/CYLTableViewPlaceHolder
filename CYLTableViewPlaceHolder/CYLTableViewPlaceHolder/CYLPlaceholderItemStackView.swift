//
//  CYLPlaceholderItemStackView.swift
//  CYLTableViewPlaceHolder
//

import UIKit
// [EN] The CYLAnimatedItem pod and framework; an older Carthage build compiled the component into CYLTabBarController.
// [CN] CYLAnimatedItem pod 与 framework；较早的 Carthage 构建把该组件编译进 CYLTabBarController。
#if canImport(CYLAnimatedItem)
import CYLAnimatedItem
#elseif canImport(CYLTabBarController)
import CYLTabBarController
#endif

/**
 * [EN] The CYLAnimatedItemStackView inside CYLPlaceholderStackView, which lays out its components. A component handles
 *      its own tap (`tapHandler`, `tapInteractionEnabled`), so the stack does not dispatch item taps
 *      (`dispatchesItemTaps` is NO); a component counts as interactive when its own tap would run
 *      (`isTapInteractive`), so the background tap passes through every other component, including one with an action
 *      whose interaction is off. Made by CYLPlaceholderStackView; apps use CYLPlaceholderStackView.
 * [CN] CYLPlaceholderStackView 内部负责组件布局的 CYLAnimatedItemStackView。组件自己处理点击（`tapHandler`、`tapInteractionEnabled`），
 *      因此堆叠视图不分发条目点击（`dispatchesItemTaps` 为 NO）；组件自己的点击会执行时（`isTapInteractive`）才算可交互，背景点击
 *      会穿过其他所有组件，包括带动作但关闭了交互的组件。由 CYLPlaceholderStackView 创建；应用使用 CYLPlaceholderStackView。
 */
@objc(CYLPlaceholderItemStackView)
public final class CYLPlaceholderItemStackView: CYLAnimatedItemStackView {

    /**
     * [EN] A stack that leaves item taps to the items. [CN] 把条目点击留给条目自己的堆叠视图。
     */
    public override init(frame: CGRect) {
        super.init(frame: frame)
        dispatchesItemTaps = false
    }

    /**
     * [EN] Not used: made in code only. [CN] 不使用：只在代码中创建。
     */
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        dispatchesItemTaps = false
    }

    /**
     * [EN] A placeholder component is interactive when its own tap would run; other items keep the default.
     * [CN] 占位组件自己的点击会执行时才可交互；其他条目使用默认判断。
     */
    public override func isItemViewInteractive(_ itemView: CYLAnimatedItemView) -> Bool {
        if let component = itemView as? CYLPlaceholderView { return component.isTapInteractive }
        return super.isItemViewInteractive(itemView)
    }
}
