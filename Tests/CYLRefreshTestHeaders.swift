//
//  CYLRefreshTestHeaders.swift
//  CYLTableViewPlaceHolder tests
//
//  [EN] The refresh control subclasses the Objective-C tests use. Objective-C cannot subclass a Swift class, so since the
//       controls moved to Swift (docs/Swift-Migration.md, step 9) these helpers are Swift; the Objective-C tests get them
//       from the test module's generated Swift header (through `CYLTableViewPlaceHolder.h`) under the same class names.
//  [CN] Objective-C 测试使用的刷新控件子类。Objective-C 不能继承 Swift 类，因此在控件改为 Swift（docs/Swift-Migration.md 第 9 步）之后，
//       这些辅助类用 Swift 编写；Objective-C 测试通过测试模块生成的 Swift 头文件（经由 `CYLTableViewPlaceHolder.h`）以相同类名使用它们。
//

import UIKit

/**
 * [EN] Records every status the drawn header base reports (`Tests/CYLRefreshDrawnHeaderTests.m`).
 * [CN] 记录手绘刷新头基类报告的每个状态（`Tests/CYLRefreshDrawnHeaderTests.m`）。
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
