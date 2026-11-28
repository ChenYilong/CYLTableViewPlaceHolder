//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Vector/ValueAnimator.m (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 7), with the same Objective-C API: the class, the selectors
//      (`+newWithFrom:to:`, `+newWithTarget:selector:`, `-setFrom:to:`, ...), the delegate protocol and the two enums with
//      their Objective-C case names (`AnimatorInterpolatorLinear`, `AnimatorRepeatModeReverse`, ...). The drawn styles
//      (Objective-C) get them from the generated Swift header through the umbrella header; the block typedef
//      `CYLRefreshAnimatorInterpolatorBlock` stays in `CYLRefreshValueAnimator.h`. Public only so the module's
//      Objective-C files can read it (an internal helper of the drawn styles, not API).
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 7 步），Objective-C API 不变：类、选择器（`+newWithFrom:to:`、
//      `+newWithTarget:selector:`、`-setFrom:to:` 等）、代理协议以及两个枚举及其 Objective-C case 名（`AnimatorInterpolatorLinear`、
//      `AnimatorRepeatModeReverse` 等）。绘制样式（Objective-C）通过总头文件中的生成 Swift 头文件获得它们；块类型
//      `CYLRefreshAnimatorInterpolatorBlock` 保留在 `CYLRefreshValueAnimator.h`。设为 public 只是为了让模块内的 Objective-C 文件读取
//      （绘制样式的内部辅助类，不是 API）。

import UIKit

/**
 * [EN] The easing curve of a value animator.
 * [CN] 数值动画器的缓动曲线。
 */
@objc public enum CYLRefreshAnimatorInterpolator: UInt {
    /**
     * [EN] Constant speed.
     * [CN] 匀速。
     */
    @objc(AnimatorInterpolatorLinear) case linear
    /**
     * [EN] Starts slow, speeds up.
     * [CN] 先慢后快。
     */
    @objc(AnimatorInterpolatorAccelerate) case accelerate
    /**
     * [EN] Starts fast, slows down.
     * [CN] 先快后慢。
     */
    @objc(AnimatorInterpolatorDecelerate) case decelerate
    /**
     * [EN] Slow at both ends (a cosine curve).
     * [CN] 两端慢、中间快（余弦曲线）。
     */
    @objc(AnimatorInterpolatorAccelerateDecelerate) case accelerateDecelerate
    /**
     * [EN] Bounces at the end.
     * [CN] 结尾回弹。
     */
    @objc(AnimatorInterpolatorBounce) case bounce
}

/**
 * [EN] What a value animator does when one round ends and it repeats.
 * [CN] 数值动画器一轮结束并重复时的行为。
 */
@objc public enum CYLRefreshAnimatorRepeatMode: UInt {
    /**
     * [EN] Starts again from `fromValue`.
     * [CN] 从 `fromValue` 重新开始。
     */
    @objc(AnimatorRepeatModeRestart) case restart
    /**
     * [EN] Runs back to `fromValue`.
     * [CN] 反向回到 `fromValue`。
     */
    @objc(AnimatorRepeatModeReverse) case reverse
}

/**
 * [EN] Told when a value animator starts, repeats and ends; every method is optional.
 * [CN] 数值动画器开始、重复与结束时收到通知；所有方法都是可选的。
 */
@objc(CYLRefreshValueAnimatorDelegate)
public protocol CYLRefreshValueAnimatorDelegate: NSObjectProtocol {
    /**
     * [EN] The animator started (after `beginTime`).
     * [CN] 动画器已开始（在 `beginTime` 之后）。
     */
    @objc(onAnimationStart:) optional func onAnimationStart(_ animator: CYLRefreshValueAnimator)
    /**
     * [EN] One round ended and another starts.
     * [CN] 一轮结束，另一轮开始。
     */
    @objc(onAnimationRepeat:) optional func onAnimationRepeat(_ animator: CYLRefreshValueAnimator)
    /**
     * [EN] The last round ended; the animator stops.
     * [CN] 最后一轮结束；动画器停止。
     */
    @objc(onAnimationEnd:) optional func onAnimationEnd(_ animator: CYLRefreshValueAnimator)
}

/**
 * [EN] Animates a number on a display link (`CACurrentMediaTime`): from `fromValue` to `toValue`, or through `points`,
 *      for `duration` seconds and `repeatCount` rounds, telling a target (by selector) every frame and a delegate at the
 *      start, each repeat and the end. It stops by itself once its owner (target and delegate, both weak) is gone.
 * [CN] 在 display link（`CACurrentMediaTime`）上驱动一个数值：在 `duration` 秒内从 `fromValue` 到 `toValue`（或经过 `points`），共
 *      `repeatCount` 轮；每帧通过选择器通知 target，并在开始、每次重复与结束时通知 delegate。其拥有者（target 与 delegate，都是弱引用）
 *      释放后会自行停止。
 */
@objc(CYLRefreshValueAnimator)
public final class CYLRefreshValueAnimator: NSObject {

    /**
     * [EN] A new animator from `from` to `to`.
     * [CN] 从 `from` 到 `to` 的新动画器。
     */
    @objc(newWithFrom:to:)
    public class func newWith(from: CGFloat, to: CGFloat) -> CYLRefreshValueAnimator {
        let animator = CYLRefreshValueAnimator()
        animator.setFrom(from, to: to)
        return animator
    }

    /**
     * [EN] A new animator that sends `action` (with the animator as argument) to `target` every frame.
     * [CN] 每帧向 `target` 发送 `action`（参数为动画器）的新动画器。
     */
    @objc(newWithTarget:selector:)
    public class func newWith(target: AnyObject?, selector action: Selector) -> CYLRefreshValueAnimator {
        let animator = CYLRefreshValueAnimator()
        animator.setTarget(target, selector: action)
        return animator
    }

    // [EN] Told every frame; weak, like the Objective-C property. [CN] 每帧收到通知；与 Objective-C 属性一样为弱引用。
    private weak var target: AnyObject?
    private var action: Selector?
    private var reversed = false
    private var link: CADisplayLink?
    private var timeStart: CFTimeInterval = 0
    private var timeOffset: CFTimeInterval = 0
    private var points: [NSNumber]?
    // [EN] A target or a delegate was set: when both are gone, nobody reads the value any more.
    // [CN] 设置过 target 或 delegate：两者都释放后，再没有人读取数值。
    private var hasOwner = false

    /**
     * [EN] The value at the start of a round. Default 0.
     * [CN] 一轮开始时的数值。默认 0。
     */
    @objc public var fromValue: CGFloat = 0
    /**
     * [EN] The value at the end of a round. Default 1.
     * [CN] 一轮结束时的数值。默认 1。
     */
    @objc public var toValue: CGFloat = 1
    /**
     * [EN] Kept from the original API; not used. Default 1.
     * [CN] 沿用原 API；未使用。默认 1。
     */
    @objc public var speed: CGFloat = 1
    /**
     * [EN] The number of rounds; `INFINITY` repeats for ever (until the owner is gone). Default 1.
     * [CN] 轮数；`INFINITY` 表示无限重复（直到拥有者释放）。默认 1。
     */
    @objc public var repeatCount: CGFloat = 1
    /**
     * [EN] The delay in seconds before `start` starts the display link. Default 0.
     * [CN] `start` 启动 display link 之前的延迟（秒）。默认 0。
     */
    @objc public var beginTime: CFTimeInterval = 0
    /**
     * [EN] The length of one round in seconds. Default 1.
     * [CN] 一轮的时长（秒）。默认 1。
     */
    @objc public var duration: CFTimeInterval = 1
    /**
     * [EN] What happens when a round ends and another starts. Default restart.
     * [CN] 一轮结束并开始下一轮时的行为。默认重新开始。
     */
    @objc public var repeatMode: CYLRefreshAnimatorRepeatMode = .restart
    /**
     * [EN] The easing curve. Default linear.
     * [CN] 缓动曲线。默认匀速。
     */
    @objc public var interpolator: CYLRefreshAnimatorInterpolator = .linear

    /**
     * [EN] Told at the start, each repeat and the end; weak. Setting one makes the animator stop once it is gone.
     * [CN] 在开始、每次重复与结束时收到通知；弱引用。设置后，它释放时动画器会停止。
     */
    @objc public weak var delegate: CYLRefreshValueAnimatorDelegate? {
        didSet {
            if delegate != nil { hasOwner = true }
        }
    }

    /**
     * [EN] A custom easing curve that wins over `interpolator`; nil by default.
     * [CN] 自定义缓动曲线，优先于 `interpolator`；默认 nil。
     */
    @objc public var interpolatorBlock: ((CGFloat) -> CGFloat)?

    /**
     * [EN] YES while the display link runs.
     * [CN] display link 运行期间为 YES。
     */
    @objc public var isRunning: Bool { link != nil }

    /**
     * [EN] The current value.
     * [CN] 当前数值。
     */
    @objc public private(set) var value: CGFloat = 0

    /**
     * [EN] The eased progress of the current round, 0 to 1.
     * [CN] 当前一轮经过缓动的进度，0 到 1。
     */
    @objc public var percent: CGFloat {
        interpolation(CGFloat(timeOffset / duration))
    }

    deinit {
        stop()
    }

    /**
     * [EN] Sends `action` (with the animator as argument) to `target` every frame; the target is weak.
     * [CN] 每帧向 `target` 发送 `action`（参数为动画器）；target 为弱引用。
     */
    @objc(setTarget:selector:)
    public func setTarget(_ target: AnyObject?, selector action: Selector) {
        self.target = target
        self.action = action
        if target != nil { hasOwner = true }
    }

    /**
     * [EN] Sets the start and end values; the current value becomes `from` when the animator is not running.
     * [CN] 设置开始与结束数值；动画器未运行时当前数值变为 `from`。
     */
    @objc(setFrom:to:)
    public func setFrom(_ from: CGFloat, to: CGFloat) {
        toValue = to
        fromValue = from
        if !isRunning {
            value = from
        }
    }

    /**
     * [EN] Animates through several values instead of `fromValue` and `toValue`.
     * [CN] 改为经过多个数值，而不是 `fromValue` 与 `toValue`。
     */
    @objc(setFromToPoints:)
    public func setFromToPoints(_ points: [NSNumber]) {
        self.points = points
        if !isRunning && !points.isEmpty {
            // [EN] `floatValue`, as the Objective-C code read it. [CN] 与 Objective-C 代码一样读取 `floatValue`。
            value = CGFloat(points[0].floatValue)
        }
    }

    /**
     * [EN] Starts the display link (after `beginTime`); does nothing while it runs.
     * [CN] 启动 display link（在 `beginTime` 之后）；运行期间不做任何事。
     */
    @objc public func start() {
        if link == nil {
            if beginTime > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + beginTime) {
                    self.startInternal()
                }
            } else {
                startInternal()
            }
        }
    }

    /**
     * [EN] Stops the display link; the value stays where it is.
     * [CN] 停止 display link；数值保持当前值。
     */
    @objc public func stop() {
        if let link = link {
            link.invalidate()
            self.link = nil
        }
    }

    private func startInternal() {
        timeOffset = 0
        reversed = false
        timeStart = CACurrentMediaTime()
        let link = CADisplayLink(target: self, selector: #selector(step(_:)))
        link.add(to: .main, forMode: .default)
        link.add(to: .main, forMode: .tracking)
        self.link = link
        delegate?.onAnimationStart?(self)
    }

    private func interpolatedValue(from points: [NSNumber], time: CGFloat, reverse reversed: Bool) -> CGFloat {
        let ordered = reversed ? Array(points.reversed()) : points
        let count = ordered.count
        // [EN] As the Objective-C enumerator: one value per step, the next one only on a match; the segment bounds use
        //      the count (not count - 1), as the original did.
        // [CN] 与 Objective-C 的枚举器相同：每步取一个值，命中时再取下一个；区间边界按个数（而非个数减 1）计算，与原实现一致。
        var i = 0
        while count > 1 && i < count - 1 {
            let from = CGFloat(ordered[i].floatValue)
            let start = 1.0 * CGFloat(i) / CGFloat(count)
            let end = 1.0 * CGFloat(i + 1) / CGFloat(count)
            if time >= start && time < end {
                let to = CGFloat(ordered[i + 1].floatValue)
                let t = (time - start) / (end - start)
                return from + (to - from) * t
            }
            i += 1
        }
        return CGFloat(points[0].floatValue)
    }

    @objc private func step(_ link: CADisplayLink) {
        // [EN] The display link retains the animator, and an endless animator (repeatCount INFINITY) never stops by itself:
        //      once its owner (target and delegate, both weak) is released, stop, so the link and the animator are released
        //      instead of ticking every frame for the rest of the app's life.
        // [CN] display link 强持有动画器，无限重复（repeatCount INFINITY）的动画器不会自己停止：其拥有者（target 与 delegate，都是弱引用）
        //      释放后就停止，使 display link 与动画器被释放，而不是在应用余下的生命周期里每帧空转。
        if hasOwner && target == nil && delegate == nil {
            stop()
            return
        }
        let thisStep = CACurrentMediaTime()
        let stepDuration = thisStep - timeStart
        // update time offset
        timeOffset = min(stepDuration, duration)
        // get normalized time offset (in range 0 - 1)
        let time = interpolation(CGFloat(timeOffset / duration))

        if let points = points, !points.isEmpty {
            value = interpolatedValue(from: points, time: time, reverse: reversed)
        } else {
            let from = reversed ? toValue : fromValue
            let to = reversed ? fromValue : toValue
            value = from + (to - from) * time
        }

        if let target = target as? NSObjectProtocol, let action = action {
            _ = target.perform(action, with: self)
        }

        if timeOffset >= duration {
            if repeatCount != .infinity {
                repeatCount -= 1
            }
            if repeatCount <= 0 {
                delegate?.onAnimationEnd?(self)
                stop()
            } else {
                delegate?.onAnimationRepeat?(self)
                if repeatMode == .reverse {
                    reversed = !reversed
                } else {
                    value = fromValue
                }
            }
            timeStart = thisStep
        }
    }

    private func interpolation(_ input: CGFloat) -> CGFloat {
        if let block = interpolatorBlock {
            return block(input)
        }
        switch interpolator {
        case .accelerateDecelerate:
            return cos((input + 1) * 3.1415926) / 2 + 0.5
        case .accelerate:
            return input * input
        case .decelerate:
            return 1.0 - (1.0 - input) * (1.0 - input)
        case .bounce:
            // [EN] The original's float literals (`1.1226f`, ...), widened to CGFloat as C did.
            // [CN] 原实现的 float 字面量（`1.1226f` 等），与 C 一样提升为 CGFloat。
            func f(_ literal: Float) -> CGFloat { CGFloat(literal) }
            func bounce(_ v: CGFloat) -> CGFloat { v * v * 8 }
            let value = input * f(1.1226)
            if value < f(0.3535) { return bounce(value) }
            if value < f(0.7408) { return bounce(value - f(0.54719)) + f(0.7) }
            if value < f(0.9644) { return bounce(value - f(0.8526)) + f(0.9) }
            return bounce(value - f(1.0435)) + f(0.95)
        default:
            return input
        }
    }
}
