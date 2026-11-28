//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Header/UIRefreshGameBattleCityHeader.m (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 8), with the same Objective-C API (the class) and the same
//      scene: physics, colors, sizes and timing.
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 8 步），Objective-C API（该类本身）以及场景的物理、颜色、尺寸与时序
//      均不变。

import SpriteKit
import UIKit

/**
 * [EN] A tank game played while refreshing (after FunGameRefresh BattleCity); drag to move the tank.
 * [CN] 刷新时玩的坦克游戏（参考 FunGameRefresh BattleCity），拖动来移动坦克。
 */
@objc(CYLRefreshGameBattleCityHeader)
open class CYLRefreshGameBattleCityHeader: CYLRefreshGameHeader {

    override func makePlayingScene() -> CYLRefreshGamePlayingScene {
        BattleCityScene()
    }
}

// [EN] The tank game: enemy tanks drive in from the left, the player's tank on the right fires at them.
// [CN] 坦克游戏：敌方坦克从左边驶来，右边玩家的坦克向它们开火。
private final class BattleCityScene: CYLRefreshGamePlayingScene, SKPhysicsContactDelegate {

    private static let namePlayer = "player"
    private static let nameTank = "tank"
    private static let nameBullet = "bullet"

    private static let maskPlayer: UInt32 = 0x1
    private static let maskTank: UInt32 = 0x2
    private static let maskBullet: UInt32 = 0x4
    private static let maskWorld: UInt32 = 0x8

    // [EN] Number of rows. [CN] 轨道数量。
    private static let tankRowNum: UInt32 = 3
    // [EN] The barrel's size as a ratio of the tank's. [CN] 炮管尺寸所在 tank 尺寸的比率。
    private static let tankBarrelRatio: CGFloat = 1.0 / 3
    // [EN] Default gap between bullets. [CN] 默认子弹之间空隙间距。
    private static let bulletNumSpacing: CGFloat = 200
    // [EN] Default gap between enemy tanks. [CN] 默认敌方坦克之间间距。
    private static let tankNumSpacing: CGFloat = 40

    private var nodePlayer: SKShapeNode?
    private var pathPlayer: UIBezierPath?
    private var nodeBullet: SKShapeNode?
    private var pathBullet: UIBezierPath?
    private var nodeEnemy: SKShapeNode?
    private var pathEnemy: UIBezierPath?
    private var spaceEnemy: CGFloat = 0
    private var spaceBullet: CGFloat = 0
    private var isGameRunning = false

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

    private func initize() {
        name = "BattleCityScene"
        scaleMode = .fill
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self

        pathPlayer = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 20, height: 20))

        let player = SKShapeNode()
        nodePlayer = player
        player.name = Self.namePlayer
        addChild(player)
    }

    // [EN] Fills a shape through key-value coding, so a nil color reaches SpriteKit as the Objective-C message sent it.
    // [CN] 通过键值编码填充形状，使 nil 颜色与 Objective-C 消息一样传给 SpriteKit。
    private static func fill(_ node: SKShapeNode?, with color: UIColor?) {
        node?.setValue(color, forKey: "fillColor")
    }

    override var colorAccent: UIColor? {
        get { super.colorAccent }
        set {
            super.colorAccent = newValue
            Self.fill(nodePlayer, with: newValue)
        }
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)

        let size = self.size

        let body: SKPhysicsBody? = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody = body
        physicsBody?.categoryBitMask = Self.maskWorld
        physicsBody?.friction = 0.0
        physicsBody?.restitution = 0.1
        physicsBody?.isDynamic = true

        let sizeTank = size.height / CGFloat(Self.tankRowNum)
        let halfTank = sizeTank / 2
        let sizeBarrel = sizeTank * Self.tankBarrelRatio
        let paddingBarrel = (sizeTank - sizeBarrel) / 2

        let player = UIBezierPath()
        pathPlayer = player
        player.move(to: CGPoint(x: halfTank, y: halfTank))
        player.addLine(to: CGPoint(x: halfTank, y: -halfTank))
        player.addLine(to: CGPoint(x: -halfTank, y: -halfTank))
        player.addLine(to: CGPoint(x: -halfTank, y: -halfTank + paddingBarrel))
        player.addLine(to: CGPoint(x: -halfTank - sizeBarrel, y: -halfTank + paddingBarrel))
        player.addLine(to: CGPoint(x: -halfTank - sizeBarrel, y: -halfTank + paddingBarrel + sizeBarrel))
        player.addLine(to: CGPoint(x: -halfTank, y: -halfTank + paddingBarrel + sizeBarrel))
        player.addLine(to: CGPoint(x: -halfTank, y: halfTank))
        player.close()

        if let node = nodePlayer {
            node.path = player.cgPath
            node.position = CGPoint(x: size.width - halfTank, y: size.height - halfTank)
            // [EN] SpriteKit may return nil for a degenerate path; an optional keeps the Objective-C nil messaging.
            // [CN] 路径退化时 SpriteKit 可能返回 nil；用可选值保持 Objective-C 向 nil 发消息的行为。
            let playerBody: SKPhysicsBody? = SKPhysicsBody(polygonFrom: player.cgPath)
            node.physicsBody = playerBody
            node.physicsBody?.categoryBitMask = Self.maskPlayer
            node.physicsBody?.allowsRotation = false
        }

        let rectBullet = CGRect(x: -sizeBarrel / 2, y: -sizeBarrel / 2, width: sizeBarrel, height: sizeBarrel)
        pathBullet = UIBezierPath(ovalIn: rectBullet)

        let enemy = UIBezierPath()
        pathEnemy = enemy
        enemy.move(to: CGPoint(x: -halfTank, y: halfTank))
        enemy.addLine(to: CGPoint(x: -halfTank, y: -halfTank))
        enemy.addLine(to: CGPoint(x: halfTank - paddingBarrel, y: -halfTank))
        enemy.addLine(to: CGPoint(x: halfTank - paddingBarrel, y: -halfTank + paddingBarrel))
        enemy.addLine(to: CGPoint(x: halfTank, y: -halfTank + paddingBarrel))
        enemy.addLine(to: CGPoint(x: halfTank, y: halfTank - paddingBarrel))
        enemy.addLine(to: CGPoint(x: halfTank - paddingBarrel, y: halfTank - paddingBarrel))
        enemy.addLine(to: CGPoint(x: halfTank - paddingBarrel, y: halfTank))
        enemy.close()
    }

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)

        if !isGameRunning {
            return
        }

        let sizeScene = size
        let sizeTank = sizeScene.height / CGFloat(Self.tankRowNum)
        let sizeBarrel = sizeTank * Self.tankBarrelRatio

        if nodeEnemy == nil || (nodeEnemy?.position.x ?? 0) > spaceEnemy + sizeTank {
            let enemy = SKShapeNode()
            nodeEnemy = enemy
            enemy.name = Self.nameTank
            Self.fill(enemy, with: colorAccent)
            enemy.position = CGPoint(x: sizeTank / 2 + 5, y: sizeTank * (0.5 + CGFloat(arc4random() % Self.tankRowNum)))
            if let path = pathEnemy?.cgPath {
                enemy.path = path
                let body: SKPhysicsBody? = SKPhysicsBody(polygonFrom: path)
                enemy.physicsBody = body
            }
            enemy.physicsBody?.friction = 0
            enemy.physicsBody?.linearDamping = 0
            enemy.physicsBody?.allowsRotation = false
            enemy.physicsBody?.usesPreciseCollisionDetection = true
            enemy.physicsBody?.categoryBitMask = Self.maskTank
            enemy.physicsBody?.contactTestBitMask = Self.maskWorld | Self.maskPlayer
            addChild(enemy)
            enemy.physicsBody?.applyImpulse(CGVector(dx: 2, dy: 0))
        }

        if (nodeBullet?.position.x ?? 0) < sizeScene.width - sizeTank - sizeBarrel - spaceBullet {

            let pt = nodePlayer?.position ?? .zero

            let bullet = SKShapeNode()
            nodeBullet = bullet
            bullet.name = Self.nameBullet
            Self.fill(bullet, with: colorAccent)
            bullet.position = CGPoint(x: pt.x - sizeTank - sizeBarrel / 3, y: pt.y)
            bullet.path = pathBullet?.cgPath
            bullet.physicsBody = SKPhysicsBody(circleOfRadius: sizeBarrel / 2)
            bullet.physicsBody?.friction = 0
            bullet.physicsBody?.linearDamping = 0
            bullet.physicsBody?.allowsRotation = false
            bullet.physicsBody?.usesPreciseCollisionDetection = true
            bullet.physicsBody?.categoryBitMask = Self.maskBullet
            bullet.physicsBody?.contactTestBitMask = Self.maskWorld | Self.maskTank
            addChild(bullet)
            bullet.physicsBody?.applyImpulse(CGVector(dx: -1, dy: 0))
        }
    }

    override func reset() {
        nodeEnemy = nil
        nodeBullet = nil
        spaceEnemy = Self.tankNumSpacing
        spaceBullet = Self.bulletNumSpacing

        let sizeScene = size
        let sizeTank = sizeScene.height / CGFloat(Self.tankRowNum)
        let halfTank = sizeTank / 2
        nodePlayer?.position = CGPoint(x: sizeScene.width - halfTank, y: sizeScene.height - halfTank)

        enumerateChildNodes(withName: Self.nameTank) { node, _ in
            node.removeFromParent()
        }
        enumerateChildNodes(withName: Self.nameBullet) { node, _ in
            node.removeFromParent()
        }
    }

    override func start() {
        isGameRunning = true
    }

    override func moveHandle(_ percent: CGFloat) {
        let sizeScene = size
        let sizeTank = sizeScene.height / CGFloat(Self.tankRowNum)

        let old = nodePlayer?.position ?? .zero
        let y = (sizeScene.height - sizeTank) * (1 - percent) + sizeTank / 2
        nodePlayer?.position = CGPoint(x: old.x, y: y)
    }

    func didEnd(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else {
            return
        }
        for node in [nodeA, nodeB] {
            if node === nodeBullet {
                nodeBullet = nil
            } else if node === nodeEnemy {
                nodeEnemy = nil
            } else if node === nodePlayer {
                gameOver()
            }
            if node !== self && node !== nodePlayer {
                node.removeFromParent()
            }
        }
    }

    override func gameWin() {
        super.gameWin()
        isGameRunning = false
    }

    override func gameOver() {
        super.gameOver()
        isGameRunning = false
    }
}
