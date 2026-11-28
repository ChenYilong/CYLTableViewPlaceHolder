//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Game/UIRefreshGameHeader.m (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 8), with the same Objective-C API (the class; no members of
//      its own) and the same scenes, colors and timing. The private `-newPlayingScene` hook is the internal
//      `makePlayingScene()`, overridden by the two games.
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 8 步），Objective-C API（该类本身，没有自己的成员）以及场景、颜色与时序
//      均不变。私有的 `-newPlayingScene` 钩子改为 internal 的 `makePlayingScene()`，由两个游戏重写。

import SpriteKit
import UIKit

/**
 * [EN] The base of the game headers: the game starts while refreshing and the user plays it by dragging.
 * [CN] 游戏刷新头的基类：刷新时开始游戏，用户通过拖动来玩。
 */
@objc(CYLRefreshGameHeader)
open class CYLRefreshGameHeader: CYLRefreshDrawnHeader {

    private var requestFinish = false
    // [EN] The result to finish with once the user stops dragging. [CN] 用户停止拖动后用来结束的结果。
    private var pendingSuccess = false
    private var storedGameView: SKView?
    private var storedSceneStart: CYLRefreshGameStartScene?
    private var storedScenePlaying: CYLRefreshGamePlayingScene?

    // [EN] The view and the scenes are created on first use, as the Objective-C getters did.
    // [CN] 视图与场景在首次使用时创建，与 Objective-C 的 getter 相同。
    private var gameView: SKView {
        if let view = storedGameView { return view }
        let view = SKView()
        storedGameView = view
        return view
    }

    private var sceneStart: CYLRefreshGameStartScene {
        if let scene = storedSceneStart { return scene }
        let scene = CYLRefreshGameStartScene()
        storedSceneStart = scene
        scene.colorAccent = colorAccent
        scene.colorPrimary = colorPrimary
        return scene
    }

    private var scenePlaying: CYLRefreshGamePlayingScene {
        if let scene = storedScenePlaying { return scene }
        let scene = makePlayingScene()
        storedScenePlaying = scene
        scene.colorAccent = colorAccent
        scene.colorPrimary = colorPrimary
        return scene
    }

    // [EN] The scene played while refreshing; the games override it. [CN] 刷新时玩的场景；各个游戏重写它。
    func makePlayingScene() -> CYLRefreshGamePlayingScene {
        CYLRefreshGamePlayingScene()
    }

    /**
     * [EN] A 100-point header, white on dark gray, moving with the content.
     * [CN] 100 点高的刷新头，深灰底白色，随内容移动。
     */
    open override func setUpComponent() {
        super.setUpComponent()
        height = 100
        colorAccent = .white
        colorPrimary = .darkGray
        scrollMode = .move
    }

    /**
     * [EN] Resizes the scenes and the game view when the width changes while attached.
     * [CN] 挂载后宽度变化时调整场景与游戏视图的尺寸。
     */
    open override var frame: CGRect {
        get { super.frame }
        set {
            if isAttached && super.frame.size.width != newValue.size.width {
                super.frame = newValue
                sceneStart.size = bounds.size
                scenePlaying.size = bounds.size
                gameView.frame = bounds
            } else {
                super.frame = newValue
            }
        }
    }

    /**
     * [EN] Colors the scenes' backgrounds. [CN] 为场景背景着色。
     */
    open override var colorPrimary: UIColor? {
        get { super.colorPrimary }
        set {
            super.colorPrimary = newValue
            scenePlaying.colorPrimary = newValue
            sceneStart.colorPrimary = newValue
        }
    }

    /**
     * [EN] Colors the scenes' texts and pieces. [CN] 为场景的文字与元素着色。
     */
    open override var colorAccent: UIColor? {
        get { super.colorAccent }
        set {
            super.colorAccent = newValue
            scenePlaying.colorAccent = newValue
            sceneStart.colorAccent = newValue
        }
    }

    /**
     * [EN] Sizes the scenes and shows the start scene. [CN] 调整场景尺寸并显示开始场景。
     */
    open override func scrollView(_ scrollView: UIScrollView, attached attach: Bool) {
        super.scrollView(scrollView, attached: attach)
        sceneStart.size = bounds.size
        scenePlaying.size = bounds.size
        gameView.frame = bounds
        gameView.presentScene(sceneStart)
        addSubview(gameView)
    }

    /**
     * [EN] Ends a refresh that was asked to end while the user was still playing, once the drag stops.
     * [CN] 用户仍在游戏时被要求结束的刷新，在拖动停止后结束。
     */
    open override func scrollView(_ scrollView: UIScrollView, didScroll offset: CGFloat, percent: CGFloat, drag isDragging: Bool) {
        super.scrollView(scrollView, didScroll: offset, percent: percent, drag: isDragging)
        if isRefreshing {
            if !isDragging && requestFinish {
                requestFinish = false
                super.finishRefresh(withSuccess: pendingSuccess)
            }
        }
    }

    /**
     * [EN] Floats in front while refreshing and closes the doors on the start scene when finishing.
     * [CN] 刷新时浮在前面，结束时以关门转场回到开始场景。
     */
    open override func onStatus(_ oldStatus: CYLRefreshPhase, changed status: CYLRefreshPhase) {
        super.onStatus(oldStatus, changed: status)
        if status == .refreshing {
            scrollMode = .front
        } else if status == .finishing {
            scrollMode = .move
            let transition = SKTransition.doorsCloseVertical(withDuration: 0.4)
            gameView.presentScene(sceneStart, transition: transition)
        } else if status == .idle {
            setNeedsLayout()
        }
    }

    /**
     * [EN] Dragging moves the player's piece. [CN] 拖动时移动玩家的元素。
     */
    open override func onScrolling(withOffset offset: CGFloat, percent: CGFloat, drag isDragging: Bool) {
        if isDragging {
            scenePlaying.moveHandle(min(1, max(percent - 1, 0)))
        }
    }

    /**
     * [EN] Shows the result; while the user still drags, the refresh ends when the drag stops.
     * [CN] 显示结果；用户仍在拖动时，刷新在拖动停止后结束。
     */
    open override func finishRefresh(withSuccess success: Bool) {
        scenePlaying.finish(withSuccess: success)
        if scrollView?.isDragging == true {
            pendingSuccess = success
            requestFinish = true
        } else {
            super.finishRefresh(withSuccess: success)
        }
    }

    /**
     * [EN] Opens the doors on the playing scene and starts the game.
     * [CN] 以开门转场进入游戏场景并开始游戏。
     */
    open override func onStartAnimationWhenRefreshing() {
        let transition = SKTransition.doorsOpenVertical(withDuration: 0.4)
        scenePlaying.reset()
        scenePlaying.start()
        scenePlaying.title = "Refreshing..."
        gameView.presentScene(scenePlaying, transition: transition)
    }
}
