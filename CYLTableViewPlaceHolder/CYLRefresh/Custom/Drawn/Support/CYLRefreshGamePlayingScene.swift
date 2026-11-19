//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Game/UIRefreshGamePlayingScene.m
//  (commit 9319448) into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 8). Internal: its only users are the game headers and
//      their scenes, all Swift, so its header is deleted (as step 7 did for the paths parser).
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 8 步）。internal：只有游戏刷新头及其场景使用它，且都是 Swift，
//      因此删除了它的头文件（与第 7 步的路径解析器相同）。

import SpriteKit
import UIKit

// [EN] The playing screen of the game headers: a title in the middle; the games subclass it and override the hooks.
// [CN] 游戏刷新头的游戏画面：中间显示标题；各个游戏继承它并重写这些钩子。
class CYLRefreshGamePlayingScene: SKScene {

    private var storedNodeTitle: SKLabelNode?
    // [EN] The Objective-C setter never stored the title, so the getter always returned nil; kept.
    // [CN] Objective-C 的 setter 从不保存标题，因此 getter 总是返回 nil；保持不变。
    private var storedTitle: String?
    private var storedColorAccent: UIColor?
    private var storedColorPrimary: UIColor?

    // [EN] Shows `title` in the middle of the scene. [CN] 在场景中间显示 `title`。
    var title: String? {
        get { storedTitle }
        set { nodeTitle.text = newValue }
    }

    // [EN] Created and added on first use, as the Objective-C getter did. [CN] 首次使用时创建并添加，与 Objective-C 的 getter 相同。
    private var nodeTitle: SKLabelNode {
        if let node = storedNodeTitle { return node }
        let node = SKLabelNode()
        node.fontSize = 20
        node.fontName = "AvenirNext-Bold"
        node.text = title
        storedNodeTitle = node
        addChild(node)
        return node
    }

    // [EN] The title color. [CN] 标题颜色。
    var colorAccent: UIColor? {
        get { storedColorAccent }
        set {
            storedColorAccent = newValue
            nodeTitle.fontColor = newValue
        }
    }

    // [EN] The background color; through key-value coding so nil reaches SpriteKit as the Objective-C message sent it.
    // [CN] 背景颜色；通过键值编码设置，使 nil 与 Objective-C 消息一样传给 SpriteKit。
    var colorPrimary: UIColor? {
        get { storedColorPrimary }
        set {
            storedColorPrimary = newValue
            setValue(newValue, forKey: "backgroundColor")
        }
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        scaleMode = .aspectFit
        nodeTitle.fontColor = colorAccent
    }

    override func didChangeSize(_ oldSize: CGSize) {
        let size = self.size
        super.didChangeSize(oldSize)
        nodeTitle.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }

    func reset() {
        title = "None"
    }

    func start() {
        title = "Loading..."
    }

    func gameWin() {
        title = "Game Win"
    }

    func gameOver() {
        title = "Game Over"
    }

    func moveHandle(_ percent: CGFloat) {
    }

    func finish(withSuccess success: Bool) {
        if success {
            title = "Loading Finished"
        } else {
            title = "Loading Failed!"
        }
    }
}
