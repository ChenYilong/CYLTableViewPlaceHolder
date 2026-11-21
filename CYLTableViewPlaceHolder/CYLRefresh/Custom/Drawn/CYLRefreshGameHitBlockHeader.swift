//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Header/UIRefreshGameHitBlockHeader.m (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 8), with the same Objective-C API (the class) and the same
//      scene: physics, colors, sizes, logs and timing.
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 8 步），Objective-C API（该类本身）以及场景的物理、颜色、尺寸、日志与时序
//      均不变。

import SpriteKit
import UIKit

/**
 * [EN] A brick-breaker game played while refreshing (after FunGameRefresh HitBlock); drag to move the paddle.
 * [CN] 刷新时玩的打砖块游戏（参考 FunGameRefresh HitBlock），拖动来移动挡板。
 */
@objc(CYLRefreshGameHitBlockHeader)
open class CYLRefreshGameHitBlockHeader: CYLRefreshGameHeader {

    override func makePlayingScene() -> CYLRefreshGamePlayingScene {
        HitBlockScene()
    }
}

// [EN] The brick-breaker: a ball bounces between the paddle on the right and the blocks on the left.
// [CN] 打砖块：小球在右边的挡板与左边的砖块之间弹跳。
private final class HitBlockScene: CYLRefreshGamePlayingScene, SKPhysicsContactDelegate {

    private static let nameBall = "ball"
    private static let nameBlock = "block"
    private static let nameLine = "line"
    private static let namePaddle = "paddle"

    private static let maskBall: UInt32 = 0x1
    private static let maskLine: UInt32 = 0x2
    private static let maskBlock: UInt32 = 0x4
    private static let maskPaddle: UInt32 = 0x8

    private var nodeEndLine: SKNode?
    private var nodeBall: SKSpriteNode?
    private var nodePaddle: SKSpriteNode?

    override init() {
        super.init()
        initize()
    }

    // [EN] SKScene's -init calls -initWithSize:, which a Swift subclass must implement; the Objective-C scene inherited it.
    // [CN] SKScene 的 -init 会调用 -initWithSize:，Swift 子类必须实现它；Objective-C 场景直接继承。
    override init(size: CGSize) {
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        NSLog("dealloc-%@", (name ?? "(null)") as NSString)
    }

    private func initize() {
        name = "HitBlockScene"
        scaleMode = .fill
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self

        let endLine = SKNode()
        nodeEndLine = endLine
        endLine.name = Self.nameLine
        addChild(endLine)

        let sizePaddle = CGSize(width: 5, height: 30)
        let paddle = SKSpriteNode()
        nodePaddle = paddle
        paddle.size = sizePaddle
        paddle.name = Self.namePaddle
        paddle.physicsBody = SKPhysicsBody(rectangleOf: sizePaddle)
        paddle.physicsBody?.isDynamic = false
        paddle.physicsBody?.friction = 0
        paddle.physicsBody?.restitution = 1
        paddle.physicsBody?.categoryBitMask = Self.maskPaddle
        addChild(paddle)

        let sizeBall = CGSize(width: 8, height: 8)
        let ball = SKSpriteNode()
        nodeBall = ball
        ball.size = sizeBall
        ball.name = Self.nameBall
        ball.physicsBody = SKPhysicsBody(circleOfRadius: sizeBall.width / 2)
        ball.physicsBody?.friction = 0
        ball.physicsBody?.restitution = 1
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.allowsRotation = false
        ball.physicsBody?.usesPreciseCollisionDetection = true
        ball.physicsBody?.categoryBitMask = Self.maskBall
        ball.physicsBody?.contactTestBitMask = Self.maskLine | Self.maskBlock
        addChild(ball)
    }

    // [EN] Colors a sprite through key-value coding, so a nil color reaches SpriteKit as the Objective-C message sent it.
    // [CN] 通过键值编码为精灵着色，使 nil 颜色与 Objective-C 消息一样传给 SpriteKit。
    private static func color(_ node: SKSpriteNode?, with color: UIColor?) {
        node?.setValue(color, forKey: "color")
    }

    override var colorAccent: UIColor? {
        get { super.colorAccent }
        set {
            super.colorAccent = newValue
            Self.color(nodeBall, with: newValue)
            Self.color(nodePaddle, with: newValue)
        }
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)

        let size = self.size

        let body: SKPhysicsBody? = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody = body
        physicsBody?.friction = 0.0
        physicsBody?.restitution = 0.1
        physicsBody?.isDynamic = true

        let from = CGPoint(x: size.width - 1, y: 0)
        let to = CGPoint(x: size.width - 1, y: size.height)
        if let endLine = nodeEndLine {
            endLine.physicsBody = SKPhysicsBody(edgeFrom: from, to: to)
        }
        // [EN] As the original: the paddle (not the end line) gets the line's category. [CN] 与原实现相同：挡板（而不是终点线）获得线的类别。
        nodePaddle?.physicsBody?.categoryBitMask = Self.maskLine

        let yPaddle = size.height - (nodePaddle?.size.height ?? 0) / 2
        nodePaddle?.position = CGPoint(x: size.width - 30, y: yPaddle)
    }

    override func reset() {
        let size = self.size
        let sizePaddle = nodePaddle?.size ?? .zero
        nodeBall?.isHidden = false
        nodeBall?.position = CGPoint(x: size.width - 30 - sizePaddle.width, y: size.height / 2)
        nodeBall?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)

        let yPaddle = size.height - sizePaddle.height / 2
        nodePaddle?.position = CGPoint(x: size.width - 30, y: yPaddle)

        while let node = childNode(withName: Self.nameBlock) {
            node.removeFromParent()
        }

        let sizeBlock = CGSize(width: 5, height: (self.size.height - 4) / 5)

        for i in 0..<3 {
            let color = colorAccent?.withAlphaComponent(CGFloat(1 - Double(i) * 0.2))
            for j in 0..<5 {
                let blockBody = SKPhysicsBody(rectangleOf: sizeBlock)
                blockBody.friction = 0
                blockBody.restitution = 1
                blockBody.isDynamic = false
                blockBody.allowsRotation = false
                blockBody.categoryBitMask = Self.maskBlock

                let y = CGFloat(j) * (sizeBlock.height + 1) + sizeBlock.height / 2
                let node = SKSpriteNode()
                Self.color(node, with: color)
                node.size = sizeBlock
                node.name = Self.nameBlock
                node.physicsBody = blockBody
                node.position = CGPoint(x: CGFloat(20 + i * 6), y: y)
                addChild(node)
            }
        }
    }

    override func start() {
        let y = (30.0 - CGFloat(arc4random() % 60)) / 100
        NSLog("start.y = %@", NSNumber(value: Double(y)))
        nodeBall?.physicsBody?.applyImpulse(CGVector(dx: -0.5, dy: y))
    }

    override func moveHandle(_ percent: CGFloat) {
        let sizeScene = size
        let sizePaddle = nodePaddle?.size ?? .zero
        let old = nodePaddle?.position ?? .zero
        let y = (sizeScene.height - sizePaddle.height) * (1 - percent) + sizePaddle.height / 2
        nodePaddle?.position = CGPoint(x: old.x, y: y)
    }

    func didEnd(_ contact: SKPhysicsContact) {
        // [EN] The Objective-C array literal raised when a body had no node; such a contact is skipped instead.
        // [CN] Objective-C 的数组字面量在物理体没有节点时会抛出异常；这里改为跳过这样的接触。
        for node in [contact.bodyA.node, contact.bodyB.node].compactMap({ $0 }) {
            if node === nodeEndLine {
                gameOver()
            } else if node.physicsBody?.categoryBitMask == Self.maskBlock {
                node.removeFromParent()
            }
        }

        if isGameWin {
            gameWin()
        }
    }

    override func gameWin() {
        super.gameWin()
        nodeBall?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        nodeBall?.isHidden = true
    }

    override func gameOver() {
        super.gameOver()
        nodeBall?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        nodeBall?.isHidden = true
    }

    private var isGameWin: Bool {
        var count = 0
        enumerateChildNodes(withName: Self.nameBlock) { _, _ in
            count += 1
        }
        return count == 0
    }
}
