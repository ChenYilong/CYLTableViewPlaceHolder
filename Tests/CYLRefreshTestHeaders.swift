//
//  CYLRefreshTestHeaders.swift
//  CYLTableViewPlaceHolder tests
//
//  [EN] The refresh control subclasses the tests use (Tests/CYLRefreshStylesAPITests.swift and
//       Tests/CYLRefreshDrawnHeaderTests.swift). Objective-C cannot subclass a Swift class, so since the controls moved to
//       Swift (docs/Swift-Migration.md, step 9) these helpers are Swift; the tests are Swift too since step 13.
//  [CN] 测试使用的刷新控件子类（Tests/CYLRefreshStylesAPITests.swift 与 Tests/CYLRefreshDrawnHeaderTests.swift）。Objective-C 不能继承
//       Swift 类，因此在控件改为 Swift（docs/Swift-Migration.md 第 9 步）之后，这些辅助类用 Swift 编写；自第 13 步起测试本身也用 Swift 编写。
//

import UIKit

/**
 * [EN] Records every status the drawn header base reports (`Tests/CYLRefreshDrawnHeaderTests.swift`).
 * [CN] 记录手绘刷新头基类报告的每个状态（`Tests/CYLRefreshDrawnHeaderTests.swift`）。
 */
@objc(CYLStatusRecordingHeader)
public final class CYLStatusRecordingHeader: CYLRefreshBezierRadarHeader {

    /**
     * [EN] The statuses in the order reported, as `NSNumber`s; nil before the first one.
     * [CN] 按报告顺序记录的状态（`NSNumber`）；第一个之前为 nil。
     */
    @objc public var statuses: NSMutableArray?

    /**
     * [EN] Records `status` after the base handled it. [CN] 基类处理后记录 `status`。
     */
    public override func onStatus(_ oldStatus: CYLRefreshPhase, changed status: CYLRefreshPhase) {
        super.onStatus(oldStatus, changed: status)
        if statuses == nil { statuses = NSMutableArray() }
        statuses?.add(NSNumber(value: status.rawValue))
    }
}

/**
 * [EN] Records the subclass hooks of a normal header (`Tests/CYLRefreshStylesAPITests.swift`).
 * [CN] 记录普通刷新头的子类钩子（`Tests/CYLRefreshStylesAPITests.swift`）。
 */
@objc(CYLHookHeader)
public final class CYLHookHeader: CYLRefreshNormalHeader {

    /**
     * [EN] How many times the header was attached. [CN] 刷新头被挂上的次数。
     */
    @objc public var attachCount = 0

    /**
     * [EN] The phases in the order reported, as `NSNumber`s; nil before the first one.
     * [CN] 按报告顺序记录的阶段（`NSNumber`）；第一个之前为 nil。
     */
    @objc public var phases: NSMutableArray?

    /**
     * [EN] The last result passed to `refreshDidFinishWithSuccess:`, as an `NSNumber`; nil before the first one.
     * [CN] 最近一次传给 `refreshDidFinishWithSuccess:` 的结果（`NSNumber`）；第一次之前为 nil。
     */
    @objc public var finishedWith: NSNumber?

    /**
     * [EN] Counts the attachment. [CN] 记录挂上次数。
     */
    public override func didAttach(to scrollView: UIScrollView) {
        super.didAttach(to: scrollView)
        attachCount += 1
    }

    /**
     * [EN] Records `phase` (without calling super, as the Objective-C helper did). [CN] 记录 `phase`（与 Objective-C 辅助类相同，不调用 super）。
     */
    public override func phaseDidChange(from oldPhase: CYLRefreshPhase, to phase: CYLRefreshPhase) {
        if phases == nil { phases = NSMutableArray() }
        phases?.add(NSNumber(value: phase.rawValue))
    }

    /**
     * [EN] Records the result after the base handled it. [CN] 基类处理后记录结果。
     */
    public override func refreshDidFinish(withSuccess success: Bool) {
        super.refreshDidFinish(withSuccess: success)
        finishedWith = NSNumber(value: success)
    }
}

/**
 * [EN] Records every `autoRefreshDidChange:` of a normal header (`Tests/CYLRefreshStylesAPITests.swift`).
 * [CN] 记录普通刷新头的每次 `autoRefreshDidChange:`（`Tests/CYLRefreshStylesAPITests.swift`）。
 */
@objc(CYLAutoHookHeader)
public final class CYLAutoHookHeader: CYLRefreshNormalHeader {

    /**
     * [EN] The values passed, as `NSNumber`s; nil before the first one. [CN] 传入的值（`NSNumber`）；第一次之前为 nil。
     */
    @objc public var autoChanges: NSMutableArray?

    /**
     * [EN] Records `autoRefresh`. [CN] 记录 `autoRefresh`。
     */
    public override func autoRefreshDidChange(_ autoRefresh: Bool) {
        if autoChanges == nil { autoChanges = NSMutableArray() }
        autoChanges?.add(NSNumber(value: autoRefresh))
    }
}
