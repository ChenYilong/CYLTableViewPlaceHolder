//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Game/UIRefreshGameStartScene.m
//  (commit 9319448) into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 7), with the same Objective-C API (`colorAccent`,
//      `colorPrimary`). Its sibling `CYLRefreshGamePlayingScene` stays Objective-C until step 8: the two game headers
//      subclass it in Objective-C. Public only so the module's Objective-C files can read it (an internal helper of the
//      drawn styles, not API).
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 7 步），Objective-C API 不变（`colorAccent`、`colorPrimary`）。同类的
//      `CYLRefreshGamePlayingScene` 在第 8 步之前仍为 Objective-C：两个游戏刷新头在 Objective-C 中继承它。设为 public 只是为了让模块内的
//      Objective-C 文件读取（绘制样式的内部辅助类，不是 API）。

import SpriteKit
import UIKit

/**
 * [EN] The start screen of the game headers: "Pull to Break Out!" and "Scroll to move handle" in a frame, in
 *      `colorPrimary` on `colorAccent`.
 * [CN] 游戏刷新头的开始画面：边框内的 "Pull to Break Out!" 与 "Scroll to move handle"，`colorAccent` 背景上使用 `colorPrimary`。
 */
@objc(CYLRefreshGameStartScene)
open class CYLRefreshGameStartScene: SKScene {

    /**
     * [EN] The background color, applied when the scene is presented; nil until it is set.
     * [CN] 背景颜色，在场景显示时应用；设置之前为 nil。
     */
    @objc public var colorAccent: UIColor!

    /**
     * [EN] The color of the texts and the frame, applied when the scene is presented; nil until it is set.
     * [CN] 文字与边框的颜色，在场景显示时应用；设置之前为 nil。
     */
    @objc public var colorPrimary: UIColor!

    private var storedNodeTitle: SKLabelNode?
    private var storedNodeDetail: SKLabelNode?
    private var storedNodeFrame: SKShapeNode?

    // [EN] The nodes are created and added on first use, as the Objective-C getters did.
    // [CN] 节点在首次使用时创建并添加，与 Objective-C 的 getter 相同。
    private var nodeTitle: SKLabelNode {
        if let node = storedNodeTitle { return node }
        let node = SKLabelNode()
        node.fontSize = 20
        node.fontName = "AvenirNext-Bold"
        node.text = "Pull to Break Out!"
        storedNodeTitle = node
        addChild(node)
        return node
    }

    private var nodeDetail: SKLabelNode {
        if let node = storedNodeDetail { return node }
        let node = SKLabelNode()
        node.fontSize = 17
        node.fontName = "AvenirNext-Bold"
        node.text = "Scroll to move handle"
        storedNodeDetail = node
        addChild(node)
        return node
    }

    private var nodeFrame: SKShapeNode {
        if let node = storedNodeFrame { return node }
        let node = SKShapeNode()
        node.lineWidth = 1
        storedNodeFrame = node
        addChild(node)
        return node
    }

    /**
     * [EN] Applies the colors when the scene is presented.
     * [CN] 场景显示时应用颜色。
     */
    open override func didMove(to view: SKView) {
        super.didMove(to: view)
        // [EN] Through key-value coding so a nil color reaches SpriteKit as nil, as the Objective-C messages sent it.
        // [CN] 通过键值编码设置，使 nil 颜色与 Objective-C 消息一样以 nil 传给 SpriteKit。
        setValue(colorAccent, forKey: "backgroundColor")
        scaleMode = .aspectFit
        nodeTitle.fontColor = colorPrimary
        nodeDetail.fontColor = colorPrimary
        nodeFrame.setValue(colorPrimary, forKey: "strokeColor")
    }

    /**
     * [EN] Centers the texts and frames the whole scene.
     * [CN] 文字居中，边框围住整个场景。
     */
    open override var size: CGSize {
        get { super.size }
        set {
            super.size = newValue
            nodeTitle.position = CGPoint(x: newValue.width / 2, y: newValue.height / 2 + 5)
            nodeDetail.position = CGPoint(x: newValue.width / 2, y: newValue.height / 2 - 15)
            nodeFrame.path = CGPath(rect: CGRect(x: 0, y: 0, width: newValue.width, height: newValue.height), transform: nil)
        }
    }
}
