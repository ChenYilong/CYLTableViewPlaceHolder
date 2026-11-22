//
//  CYLRefreshStylesAPITests.swift
//  CYLTableViewPlaceHolder tests
//
//  [EN] CYLRefresh styles API on CYLRefresh: attach / addTarget, triggerRate, finishDuration with a result, phases, scroll
//       modes, theme colors and the subclass hooks (docs/Refresh-Library-Parity.md). Swift since 2026-11-20
//       (docs/Swift-Migration.md, step 13); the variadic `-isInPhases:` is checked from Objective-C in
//       `Tests/CYLObjectiveCAPISmokeTests.m`.
//  [CN] CYLRefresh 上的 CYLRefresh styles API：attach / addTarget、triggerRate、带结果的 finishDuration、阶段、滚动模式、主题色与子类钩子
//       （docs/Refresh-Library-Parity.md）。自 2026-11-20 起用 Swift 编写（docs/Swift-Migration.md 第 13 步）；可变参数的 `-isInPhases:`
//       在 `Tests/CYLObjectiveCAPISmokeTests.m` 中从 Objective-C 检查。
//

import UIKit
import XCTest

// [EN] CYLHookHeader and CYLAutoHookHeader (CYLRefreshNormalHeader subclasses that record the hooks) are in
//      Tests/CYLRefreshTestHeaders.swift.
// [CN] CYLHookHeader 与 CYLAutoHookHeader（记录钩子的 CYLRefreshNormalHeader 子类）位于 Tests/CYLRefreshTestHeaders.swift。

/**
 * [EN] A target for -addTarget:action: that ends whichever header is attached. [CN] -addTarget:action: 的目标，结束当前挂着的刷新头。
 */
private final class CYLStartHeaderTarget: NSObject {
    var log: NSMutableArray = []
    weak var scrollView: UIScrollView?

    @objc func refresh() {
        log.add("refresh")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.scrollView?.cylHeader?.endRefreshing()
        }
    }
}

/**
 * [EN] Wraps phases as the `NSNumber`s `isIn(phases:)` takes. [CN] 将阶段包装为 `isIn(phases:)` 接受的 `NSNumber`。
 */
private func numbers(_ phases: CYLRefreshPhase...) -> [NSNumber] {
    phases.map { NSNumber(value: $0.rawValue) }
}

/**
 * [EN] CYLRefresh styles API on CYLRefresh: attach / addTarget, triggerRate, finishDuration with a result, phases, scroll
 *      modes, theme colors and the subclass hooks (docs/Refresh-Library-Parity.md).
 * [CN] CYLRefresh 上的 CYLRefresh styles API（docs/Refresh-Library-Parity.md）。
 */
final class CYLRefreshStylesAPITests: XCTestCase {
    private var targetCalls = 0
    private weak var lastSender: AnyObject?

    @objc private func onRefresh(_ sender: Any) {
        targetCalls += 1
        lastSender = sender as AnyObject
    }

    private func scrollView() -> UIScrollView {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        scrollView.contentSize = CGSize(width: 320, height: 2000)
        return scrollView
    }

    func testAttachPicksTheSlotByClassAndCallsEveryTarget() {
        let scrollView = self.scrollView()
        let header = CYLRefreshNormalHeader.attach(to: scrollView, target: self, action: #selector(onRefresh(_:)))
        XCTAssertTrue(scrollView.cylHeader === header)
        XCTAssertTrue(header.isAttached)
        let footer = CYLRefreshAutoNormalFooter.attach(to: scrollView)
        XCTAssertTrue(scrollView.cylFooter === footer)
        let trailer = CYLRefreshNormalTrailer()
        trailer.attach(to: scrollView)
        XCTAssertTrue(scrollView.cylTrailer === trailer)

        var handled: CYLRefreshComponent?
        header.refreshingHandler = { component in handled = component }
        header.addTarget(self, action: #selector(onRefresh(_:)))
        header.executeRefreshingCallback()
        XCTAssertEqual(targetCalls, 2, "both added target-actions run")
        XCTAssertTrue(lastSender === header)
        XCTAssertTrue(handled === header, "the handler gets the control")
        header.removeTarget(self, action: #selector(onRefresh(_:)))
        header.executeRefreshingCallback()
        XCTAssertEqual(targetCalls, 2, "removed")
        scrollView.cylHeader = nil
        XCTAssertFalse(header.isAttached)
    }

    func testTriggerRateScalesThePullDistance() {
        let scrollView = self.scrollView()
        let header = CYLRefreshNormalHeader.attach(to: scrollView)
        header.triggerRate = 2
        let height = header.expandHeight
        // [EN] Pulled one header height: half the trigger distance. [CN] 拉动一个刷新头高度：触发距离的一半。
        scrollView.contentOffset = CGPoint(x: 0, y: -height)
        XCTAssertEqual(header.pullingPercent, 0.5, accuracy: 0.01)
        XCTAssertEqual(header.dragOffset, height, accuracy: 0.5)
        header.triggerRate = 0
        XCTAssertEqual(header.triggerRate, 1, "invalid rates fall back to 1")
    }

    func testFinishDurationHoldsAndShowsTheResult() {
        let scrollView = self.scrollView()
        let header = CYLHookHeader.attach(to: scrollView)
        XCTAssertEqual(header.attachCount, 1)
        header.finishDuration = 0.2
        header.state = .refreshing
        XCTAssertEqual(header.phase, .refreshing)
        header.endRefreshing(success: false)
        XCTAssertEqual(header.finishedWith, NSNumber(value: false))
        XCTAssertFalse(header.lastRefreshSucceeded)
        XCTAssertEqual(header.phase, .finishing, "holding")
        // [EN] Swift's form of `-isInPhases:` (the variadic Objective-C call is in CYLObjectiveCAPISmokeTests.m).
        // [CN] `-isInPhases:` 的 Swift 写法（可变参数的 Objective-C 调用在 CYLObjectiveCAPISmokeTests.m 中）。
        XCTAssertTrue(header.isIn(phases: numbers(.refreshing, .finishing)))
        XCTAssertTrue(header.isIn(phases: [NSNumber(value: CYLRefreshPhase.finishing.rawValue)]))
        XCTAssertFalse(header.isIn(phases: numbers(.idle)))
        XCTAssertEqual(header.stateLabel?.text, Bundle.cylLocalizedString(forKey: CYLRefreshHeaderFailedText))
        let done = expectation(description: "retracts")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            XCTAssertEqual(header.state, .idle)
            XCTAssertTrue(header.phases?.contains(NSNumber(value: CYLRefreshPhase.finishing.rawValue)) ?? false)
            done.fulfill()
        }
        waitForExpectations(timeout: 2)

        // [EN] Without a finish duration, ending is immediate, as before. [CN] 不设停留时间时立即结束，与以前相同。
        header.finishDuration = 0
        header.state = .refreshing
        header.endRefreshing()
        XCTAssertEqual(header.state, .idle)
        XCTAssertTrue(header.lastRefreshSucceeded)
    }

    func testScrollModesPlaceTheHeader() {
        let scrollView = self.scrollView()
        let header = CYLRefreshNormalHeader.attach(to: scrollView)
        let height = header.expandHeight
        header.scrollMode = .stretch
        scrollView.contentOffset = CGPoint(x: 0, y: -150)
        XCTAssertEqual(header.cylH, 150, accuracy: 0.5, "stretched over the pulled distance")
        XCTAssertEqual(header.cylY, -150, accuracy: 0.5)
        XCTAssertEqual(header.expandHeight, height, accuracy: 0.5, "the open height is kept")
        header.scrollMode = .front
        scrollView.contentOffset = CGPoint(x: 0, y: -150)
        XCTAssertEqual(header.cylH, height, accuracy: 0.5)
        XCTAssertEqual(header.cylY, -150, accuracy: 0.5, "pinned at the visible top, in front")
        XCTAssertEqual(header.layer.zPosition, 1)
        header.scrollMode = .move
        XCTAssertEqual(header.cylY, -height, accuracy: 0.5, "back to moving with the content")
    }

    func testThemeColorsAndHeaderDetails() {
        let scrollView = self.scrollView()
        let header = CYLRefreshNormalHeader.attach(to: scrollView)
        header.colorAccent = .systemRed
        header.colorPrimary = .systemYellow
        header.frame = CGRect(x: 0, y: -54, width: 320, height: 54)
        header.layoutIfNeeded()
        XCTAssertEqual(header.stateLabel?.textColor, UIColor.systemRed)
        XCTAssertEqual(header.lastUpdatedTimeLabel?.textColor, UIColor.systemRed)
        XCTAssertEqual(header.loadingView.color, UIColor.systemRed)
        XCTAssertEqual(header.backgroundColor, UIColor.systemYellow)

        header.lastUpdatedTimeKey = "CYLRefreshStylesAPITests"
        let date = Date(timeIntervalSince1970: 0)
        header.lastUpdatedTime = date
        XCTAssertEqual(header.lastUpdatedTime, date)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        header.lastUpdatedTimeFormatter = formatter
        XCTAssertTrue(header.lastUpdatedTimeString?.hasSuffix("1970") ?? false, "\(String(describing: header.lastUpdatedTimeString))")
        header.lastUpdatedTime = nil
        XCTAssertNil(header.lastUpdatedTime)

        header.titleTimeSpacing = 6
        header.setNeedsLayout()
        header.layoutIfNeeded()
        XCTAssertEqual((header.lastUpdatedTimeLabel?.frame.minY ?? 0) - (header.stateLabel?.frame.maxY ?? 0), 6, accuracy: 0.5)

        let footer = CYLRefreshBackNormalFooter.attach(to: scrollView)
        XCTAssertFalse(footer.isNoMoreData)
        footer.endRefreshingWithNoMoreData()
        XCTAssertTrue(footer.isNoMoreData)
        XCTAssertEqual(footer.phase, .noMoreData)
    }

    func testFlutterEasyRefreshStyleOptions() {
        let scrollView = self.scrollView()
        let header = CYLRefreshNormalHeader.attach(to: scrollView)
        let footer = CYLRefreshBackNormalFooter.attach(to: scrollView)
        XCTAssertTrue(header.isRefreshEnabled, "on by default")

        // [EN] External phase observers (listenable / ListenerHeader). [CN] 外部阶段观察者（listenable / ListenerHeader）。
        var seen: [CYLRefreshPhase] = []
        let token = header.addPhaseObserver { component, _, phase in
            XCTAssertTrue(component === header)
            seen.append(phase)
        }
        header.state = .refreshing
        XCTAssertEqual(seen.last, .refreshing)
        header.removePhaseObserver(token)
        header.state = .idle
        XCTAssertEqual(seen.last, .refreshing, "removed observers stay silent")

        // [EN] resetsFooterAfterRefresh. [CN] 刷新后重置加载尾。
        footer.endRefreshingWithNoMoreData()
        XCTAssertTrue(footer.isNoMoreData)
        header.resetsFooterAfterRefresh = true
        header.state = .refreshing
        header.endRefreshing(success: true)
        XCTAssertFalse(footer.isNoMoreData, "a successful refresh resets no more data")
        footer.endRefreshingWithNoMoreData()
        header.state = .refreshing
        header.endRefreshing(success: false)
        XCTAssertTrue(footer.isNoMoreData, "a failed refresh keeps it")

        // [EN] notifiesWhenHidden: hooks still follow the scroll view. [CN] 隐藏时仍跟随滚动。
        header.isHidden = true
        header.notifiesWhenHidden = true
        scrollView.contentOffset = CGPoint(x: 0, y: -10)
        XCTAssertGreaterThan(header.pullingPercent, 0, "still followed while hidden")
        header.isHidden = false

        header.triggersWhenReached = true
        header.hapticFeedback = true
        header.maxPullDistance = 120
        header.isRefreshEnabled = false
        footer.loadsAfterNoMoreData = true
        XCTAssertTrue(header.triggersWhenReached && header.hapticFeedback && footer.loadsAfterNoMoreData)
        XCTAssertEqual(header.maxPullDistance, 120)
        XCTAssertFalse(header.isRefreshEnabled)
    }

    func testTriggerModeBehindModeStartHeaderAndCupertino() {
        let scrollView = self.scrollView()
        let header = CYLRefreshNormalHeader.attach(to: scrollView)
        XCTAssertEqual(header.triggerMode, .anywhere, "default")
        header.triggerMode = .onEdge
        XCTAssertEqual(header.triggerMode, .onEdge)

        // [EN] Behind: pinned behind the content. [CN] 后置：固定在内容后面。
        header.scrollMode = .behind
        scrollView.contentOffset = CGPoint(x: 0, y: -120)
        XCTAssertEqual(header.layer.zPosition, -1)
        XCTAssertTrue(scrollView.subviews.first === header, "sent to the back")
        XCTAssertEqual(header.frame.minY, -120, accuracy: 0.5, "pinned at the visible top")
        header.scrollMode = .move
        XCTAssertEqual(header.layer.zPosition, 0)

        // [EN] A start header refreshes once, then the regular header comes back. [CN] 起始刷新头刷新一次后换回常规刷新头。
        var calls = 0
        header.refreshingBlock = { calls += 1 }
        let start = CYLRefreshCupertinoHeader()
        scrollView.cylBeginRefreshing(startHeader: start)
        XCTAssertTrue(scrollView.cylHeader === start)
        XCTAssertTrue(start.isRefreshing || start.state == .willRefresh)
        start.executeRefreshingCallback()
        XCTAssertEqual(calls, 1, "the regular header's callback runs")
        let back = expectation(description: "regular header back")
        start.endRefreshing(completionBlock: {})
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertTrue(scrollView.cylHeader === header)
            back.fulfill()
        }
        waitForExpectations(timeout: 3)

        // [EN] Cupertino: the indicator spins only while refreshing. [CN] Cupertino：菊花只在刷新时旋转。
        let footer = CYLRefreshCupertinoFooter.attach(to: scrollView)
        XCTAssertFalse(footer.activityIndicator.isAnimating)
        footer.state = .refreshing
        XCTAssertTrue(footer.activityIndicator.isAnimating)
        footer.state = .idle
        XCTAssertFalse(footer.activityIndicator.isAnimating)
        let cupertino = CYLRefreshCupertinoHeader()
        cupertino.pullingPercent = 0.5
        XCTAssertEqual(cupertino.activityIndicator.alpha, 0.5, accuracy: 0.01, "fades in with the pull")
        cupertino.state = .refreshing
        XCTAssertTrue(cupertino.activityIndicator.isAnimating)
        XCTAssertNotNil(cupertino.activityIndicator.accessibilityLabel)
    }

    /**
     * [EN] Runs the main run loop until `condition` holds or 15 s pass. [CN] 运行主 run loop，直到 `condition` 成立或经过 15 秒。
     */
    private func waitUntil(_ condition: () -> Bool) {
        let deadline = Date(timeIntervalSinceNow: 15)
        while !condition() && deadline.timeIntervalSinceNow > 0 {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
        }
    }

    func testSecondFloorOpensAndCloses() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.isHidden = false
        let scrollView = self.scrollView()
        window.addSubview(scrollView)
        let header = CYLRefreshNormalHeader.attach(to: scrollView)
        let floor = UIView()
        header.secondaryTriggerOffset = 160
        header.secondaryDimension = 300
        header.secondaryView = floor
        XCTAssertTrue(floor.superview === scrollView, "the second floor's view sits in the scroll view")
        XCTAssertEqual(floor.frame.minY, -300, accuracy: 0.5, "above the content")
        XCTAssertEqual(header.secondaryCloseTriggerOffset, 80, accuracy: 0.01)
        let top = scrollView.adjustedContentInset.top

        var opened = false, closed = false
        var phases: [CYLRefreshPhase] = []
        _ = header.addPhaseObserver { _, _, phase in phases.append(phase) }
        header.secondaryOpenedBlock = { opened = true }
        header.secondaryClosedBlock = { closed = true }
        // [EN] Poll for the end of each animation instead of a fixed 0.7 s: a busy CI runner stretched the close (4eaed77:
        //      still SecondaryClosing after 0.7 s while the test took 35 s).
        // [CN] 轮询动画结束，而不是固定等待 0.7 秒：CI 机器繁忙时关闭动画变慢（4eaed77：0.7 秒后仍为 SecondaryClosing，测试用时 35 秒）。
        header.openSecondary()
        XCTAssertTrue(header.isSecondaryOpen)
        XCTAssertEqual(header.phase, .secondaryOpen)
        waitUntil { opened && abs(scrollView.adjustedContentInset.top - (top + 300)) <= 0.5 }
        XCTAssertTrue(opened)
        XCTAssertEqual(scrollView.adjustedContentInset.top, top + 300, accuracy: 0.5, "the content moved down by the floor")
        XCTAssertNil(header.layer.mask, "not auto-hidden while the floor is open")
        XCTAssertGreaterThan(scrollView.subviews.firstIndex(of: floor) ?? NSNotFound, scrollView.subviews.firstIndex(of: header) ?? NSNotFound,
                             "the open floor is in front of the header")

        header.closeSecondary()
        XCTAssertEqual(header.phase, .secondaryClosing)
        waitUntil { closed && phases.last == .idle }
        XCTAssertTrue(closed, "closed (phases \(phases.map { $0.rawValue }))")
        XCTAssertFalse(header.isSecondaryOpen)
        XCTAssertEqual(scrollView.adjustedContentInset.top, top, accuracy: 0.5, "the inset is back")
        XCTAssertLessThan(scrollView.subviews.firstIndex(of: floor) ?? NSNotFound, scrollView.subviews.firstIndex(of: header) ?? NSNotFound,
                          "closed: behind the header again")
        XCTAssertTrue(phases.contains(.secondaryOpen))
        XCTAssertEqual(phases.last, .idle)
        window.isHidden = true
    }

    func testFooterSecondFloorOpensAndCloses() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.isHidden = false
        let scrollView = self.scrollView()
        window.addSubview(scrollView)
        let footer = CYLRefreshBackNormalFooter.attach(to: scrollView)
        let floor = UIView()
        footer.secondaryTriggerOffset = 160
        footer.secondaryDimension = 260
        footer.secondaryView = floor
        XCTAssertTrue(floor.superview === scrollView)
        XCTAssertEqual(floor.frame.minY, 2000, accuracy: 0.5, "right below the content")
        XCTAssertEqual(footer.secondaryCloseTriggerOffset, 80, accuracy: 0.01)
        let bottom = scrollView.adjustedContentInset.bottom
        var opened = false, closed = false
        footer.secondaryOpenedBlock = { opened = true }
        footer.secondaryClosedBlock = { closed = true }
        // [EN] Poll for the end of each animation instead of a fixed 0.7 s: a busy CI runner stretched the open (a56ea22:
        //      the opened block had not run after 0.7 s while the test took 10 s), as for the header in CYLRefreshSmartAPITests.
        // [CN] 轮询动画结束，而不是固定等待 0.7 秒：CI 机器繁忙时打开动画变慢（a56ea22：0.7 秒后 opened 回调尚未执行，测试用时 10 秒），与
        //      CYLRefreshSmartAPITests 中的刷新头相同。
        footer.openSecondary()
        XCTAssertEqual(footer.phase, .secondaryOpen)
        waitUntil { opened && footer.isSecondaryOpen }
        XCTAssertTrue(opened && footer.isSecondaryOpen)
        XCTAssertEqual(scrollView.adjustedContentInset.bottom, bottom + 260, accuracy: 0.5)
        footer.closeSecondary()
        waitUntil { closed && footer.phase == .idle }
        XCTAssertTrue(closed)
        XCTAssertFalse(footer.isSecondaryOpen)
        XCTAssertEqual(scrollView.adjustedContentInset.bottom, bottom, accuracy: 0.5)
        XCTAssertEqual(footer.phase, .idle)
        window.isHidden = true
    }

    func testCallRefreshOptionsResultImageAndTrailingIcon() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.isHidden = false
        let scrollView = self.scrollView()
        window.addSubview(scrollView)
        let header = CYLRefreshNormalHeader.attach(to: scrollView)
        let footer = CYLRefreshBackNormalFooter.attach(to: scrollView)
        let fast = header.fastAnimationDuration

        // force: starts although the footer refreshes and the header is exclusive.
        header.isExclusiveWithOtherRefresh = true
        footer.beginRefreshing()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.4))
        header.beginRefreshing(duration: 0.5, overOffset: 20, force: true)
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1.2))
        XCTAssertTrue(header.isRefreshing, "force starts the refresh")
        XCTAssertTrue(header.isExclusiveWithOtherRefresh, "the option is restored")
        XCTAssertEqual(header.fastAnimationDuration, fast, accuracy: 0.001, "the duration is restored")
        XCTAssertEqual(scrollView.contentOffset.y, -(scrollView.adjustedContentInset.top), accuracy: 1, "back at rest after the overshoot")
        footer.endRefreshing()

        // succeededImage takes the icon's place while the header holds after success.
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10))
        let check = renderer.image { _ in
            UIColor.green.setFill()
            UIRectFill(CGRect(x: 0, y: 0, width: 10, height: 10))
        }
        header.succeededImage = check
        header.finishDuration = 1
        header.endRefreshing(success: true)
        header.layoutIfNeeded()
        var result: UIImageView?
        for view in header.subviews {
            if let imageView = view as? UIImageView, imageView.image === check { result = imageView }
        }
        XCTAssertNotNil(result)
        XCTAssertFalse(result?.isHidden ?? true)
        XCTAssertEqual(header.loadingView.alpha, 0, accuracy: 0.01, "the spinner gives way")
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 2))
        XCTAssertEqual(header.state, .idle)
        XCTAssertTrue(result?.isHidden ?? false, "gone when idle again")

        // iconOnTrailingSide puts the arrow after the text.
        header.lastUpdatedTimeLabel?.isHidden = true
        header.layoutIfNeeded()
        let leading = header.arrowView.center.x
        header.iconOnTrailingSide = true
        header.layoutIfNeeded()
        XCTAssertLessThan(leading, header.cylW * 0.5)
        XCTAssertGreaterThan(header.arrowView.center.x, header.cylW * 0.5)
        header.secondaryVelocity = 1500
        XCTAssertEqual(header.secondaryVelocity, 1500, accuracy: 0.01)
        window.isHidden = true
    }

    func testNoMoreDataImageAndIconSize() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.isHidden = false
        let scrollView = self.scrollView()
        window.addSubview(scrollView)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 12, height: 12))
        let image = renderer.image { _ in
            UIColor.gray.setFill()
            UIRectFill(CGRect(x: 0, y: 0, width: 12, height: 12))
        }
        let classes: [CYLRefreshFooter.Type] = [CYLRefreshBackNormalFooter.self, CYLRefreshAutoNormalFooter.self]
        for cls in classes {
            let footer = cls.attach(to: scrollView)
            footer.setValue(image, forKey: "noMoreDataImage")
            let find: () -> UIImageView? = {
                for view in footer.subviews {
                    if let imageView = view as? UIImageView, imageView.image === image { return imageView }
                }
                return nil
            }
            XCTAssertTrue(find() == nil || find()!.isHidden, "\(cls): hidden before no more data")
            footer.endRefreshingWithNoMoreData()
            footer.layoutIfNeeded()
            XCTAssertNotNil(find(), "\(cls)")
            XCTAssertFalse(find()?.isHidden ?? true, "\(cls): shown with no more data")
            XCTAssertLessThan(find()?.center.x ?? .greatestFiniteMagnitude, footer.cylW * 0.5, "\(cls): before the text")
            footer.resetNoMoreData()
            XCTAssertTrue(find()?.isHidden ?? false, "\(cls): hidden again")
            scrollView.cylFooter = nil
        }
        let back = CYLRefreshBackNormalFooter.attach(to: scrollView)
        back.iconSize = CGSize(width: 30, height: 20)
        back.layoutIfNeeded()
        // [EN] The idle back-footer arrow is turned by almost pi, so its frame-set size carries float error.
        // [CN] 空闲时返回式尾的箭头旋转了接近 π，按 frame 设置的尺寸有浮点误差。
        XCTAssertEqual(back.arrowView.bounds.size.width, 30, accuracy: 0.01, NSCoder.string(for: back.arrowView.bounds.size))
        XCTAssertEqual(back.arrowView.bounds.size.height, 20, accuracy: 0.01)
        let header = CYLRefreshNormalHeader.attach(to: scrollView)
        header.iconSize = CGSize(width: 24, height: 24)
        header.layoutIfNeeded()
        XCTAssertTrue(header.arrowView.bounds.size == CGSize(width: 24, height: 24))
        window.isHidden = true
    }

    func testPagingRefreshLoadRetryAndNoMore() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.isHidden = false
        let scrollView = self.scrollView()
        window.addSubview(scrollView)
        let header = CYLRefreshNormalHeader.attach(to: scrollView)
        let footer = CYLRefreshBackNormalFooter.attach(to: scrollView)
        var failNext = false
        var total = 25
        var requested: [Int] = []
        let paging = CYLRefreshPaging(header: header, footer: footer) { page, done in
            requested.append(page)
            if failNext {
                failNext = false
                done(nil, NSNotFound, NSNotFound, NSError(domain: "test", code: 1, userInfo: nil))
                return
            }
            var items: [Any] = []
            var index = (page - 1) * 10
            while index < min(page * 10, total) {
                items.append(index)
                index += 1
            }
            done(items, total, NSNotFound, nil)
        }
        var changes = 0
        paging.itemsDidChange = { _ in changes += 1 }
        XCTAssertNil(paging.items)
        XCTAssertFalse(paging.isEmpty)
        XCTAssertFalse(paging.isNoMore, "nothing known yet")

        paging.refresh()
        XCTAssertEqual(paging.count, 10)
        XCTAssertEqual(paging.page, 1)
        XCTAssertEqual(changes, 1)

        failNext = true
        paging.loadMore()
        XCTAssertEqual(paging.count, 10, "a failed load commits nothing")
        XCTAssertEqual(paging.page, 1)
        paging.loadMore()
        XCTAssertEqual(requested, [1, 2, 2], "the failed page is asked for again")
        XCTAssertEqual(paging.count, 20)
        paging.loadMore()
        XCTAssertEqual(paging.count, 25)
        XCTAssertTrue(paging.isNoMore, "count >= total")
        XCTAssertEqual(footer.state, .noMoreData)

        failNext = true
        paging.refresh()
        XCTAssertEqual(paging.count, 25, "a failed refresh keeps the items")
        XCTAssertEqual(footer.state, .noMoreData, "and the footer")
        total = 40
        paging.refresh()
        XCTAssertEqual(paging.count, 10, "refresh replaces the items")
        XCTAssertNotEqual(footer.state, .noMoreData, "reset after a successful refresh")

        total = 0
        paging.refresh()
        XCTAssertTrue(paging.isEmpty)
        XCTAssertTrue(paging.isNoMore)
        window.isHidden = true
    }

    func testPagingNoMoreByPageCountAndAsyncCompletion() {
        let paging = CYLRefreshPaging(header: nil, footer: nil) { page, done in
            DispatchQueue.global(qos: .default).async { done([page], NSNotFound, 2, nil) }
        }
        let first = expectation(description: "first page")
        paging.itemsDidChange = { _ in
            XCTAssertTrue(Thread.isMainThread, "reported on the main queue")
            first.fulfill()
        }
        paging.start()
        wait(for: [first], timeout: 15)
        XCTAssertFalse(paging.isNoMore, "page 1 of 2")
        let second = expectation(description: "second page")
        paging.itemsDidChange = { _ in second.fulfill() }
        paging.loadMore()
        wait(for: [second], timeout: 15)
        XCTAssertEqual(paging.page, 2)
        XCTAssertTrue(paging.isNoMore, "page >= totalPage")
        XCTAssertEqual(paging.items as? [Int], [1, 2])
    }

    /**
     * [EN] flutter_easy_refresh #631: a mouse wheel moves the offset without a drag and without overscroll; the auto footer
     *      must still load when the bottom is reached. [CN] flutter_easy_refresh #631：鼠标滚轮移动偏移时没有拖动、也不越界；
     *      到达底部时自动加载尾仍须加载。
     */
    func testAutoFooterLoadsWhenWheelReachesBottom() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.isHidden = false
        let scrollView = self.scrollView()
        window.addSubview(scrollView)
        let footer = CYLRefreshAutoNormalFooter.attach(to: scrollView)
        var loads = 0
        footer.refreshingBlock = { loads += 1 }
        XCTAssertFalse(scrollView.isDragging)
        let bottom = scrollView.contentSize.height + scrollView.adjustedContentInset.bottom - scrollView.bounds.height
        // Wheel steps of 40 points down to the bottom, never past it.
        var y = bottom - 400
        while y <= bottom {
            scrollView.contentOffset = CGPoint(x: 0, y: min(y, bottom))
            y += 40
        }
        scrollView.contentOffset = CGPoint(x: 0, y: bottom)
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.3))
        XCTAssertEqual(footer.state, .refreshing, "loads without a drag")
        XCTAssertEqual(loads, 1)
        window.isHidden = true
    }

    func testStartHeaderBeforeWindowRestoresRegularHeader() {
        let scrollView = self.scrollView()
        let regular = CYLRefreshNormalHeader.attach(to: scrollView)
        var refreshes = 0
        regular.refreshingBlock = { refreshes += 1 }
        let start = CYLRefreshCupertinoHeader()
        scrollView.cylBeginRefreshing(startHeader: start)   // viewDidLoad: not in a window yet
        XCTAssertTrue(scrollView.cylHeader === start)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.isHidden = false
        window.addSubview(scrollView)
        // [EN] Polled, not fixed waits (0.6 s, then 1.5 s): on a slow runner the refresh had not called back yet when
        //      endRefreshing ran, so the regular header's block never ran (714d4fc: refreshes == 0, the test took 24 s).
        // [CN] 轮询而非固定等待（0.6 秒、1.5 秒）：在慢速 runner 上 endRefreshing 执行时刷新尚未回调，常规刷新头的 block 从未执行
        //      （714d4fc：refreshes == 0，测试耗时 24 秒）。
        var deadline = Date(timeIntervalSinceNow: 15)
        while refreshes == 0 && deadline.timeIntervalSinceNow > 0 {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
        }
        XCTAssertTrue(start.isRefreshing)
        scrollView.cylHeader?.endRefreshing()
        deadline = Date(timeIntervalSinceNow: 15)
        while scrollView.cylHeader !== regular && deadline.timeIntervalSinceNow > 0 {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
        }
        XCTAssertTrue(scrollView.cylHeader === regular, "the regular header is back")
        XCTAssertEqual(refreshes, 1)
        window.isHidden = true
    }

    func testStartHeaderInPushedTableViewController() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let nav = UINavigationController(rootViewController: UIViewController())
        window.rootViewController = nav
        window.isHidden = false
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.3))
        let page = UITableViewController(style: .plain)
        let log = NSMutableArray()
        // viewDidLoad equivalent: attach, then start with another header.
        _ = page.view
        // [EN] attach:target:action:, as the example does: the callback is a target-action of -addTarget:action:.
        // [CN] 与示例一样用 attach:target:action:：回调是 -addTarget:action: 的 target-action。
        let target = CYLStartHeaderTarget()
        target.log = log
        target.scrollView = page.tableView
        let regular = CYLRefreshNormalHeader.attach(to: page.tableView, target: target, action: #selector(CYLStartHeaderTarget.refresh))
        let start = CYLRefreshCupertinoHeader()
        _ = start.addPhaseObserver { _, old, phase in
            log.add("start \(old.rawValue)>\(phase.rawValue)")
        }
        page.tableView.cylBeginRefreshing(startHeader: start)
        nav.pushViewController(page, animated: true)
        // [EN] Poll instead of a fixed 3 s: on a loaded CI runner the animated push and the first refresh can take longer
        //      (the fixed wait failed once on CI while every other test passed).
        // [CN] 轮询而不是固定等待 3 秒：CI 机器繁忙时动画 push 与首次刷新可能更久（固定等待曾在 CI 上失败一次，其他测试都通过）。
        //      The iOS 12 simulator on CI can stall a single run-loop pass for a minute (203b0c1: the test took 75 s with a
        //      15 s limit and stopped with the start header in the window but still WillRefresh, its promotion block queued
        //      by -didMoveToWindow not yet run). So wait up to 60 s, and drain the queue once more after the deadline.
        // [CN] CI 上的 iOS 12 模拟器可能让一次 run loop 卡住一分钟（203b0c1：限时 15 秒，测试用时 75 秒，结束时起始刷新头已在窗口中但仍为
        //      WillRefresh，-didMoveToWindow 排队的切换尚未执行）。因此最多等 60 秒，并在超时后再处理一次队列。
        let done = { log.contains("refresh") && page.tableView.cylHeader === regular }
        let deadline = Date(timeIntervalSinceNow: 60)
        while !done() && deadline.timeIntervalSinceNow > 0 {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
        }
        let drain = Date(timeIntervalSinceNow: 2)
        while !done() && drain.timeIntervalSinceNow > 0 {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
        }
        // [EN] The messages carry the phase log and the start header's state, so a failure shows where it stopped (waiting
        //      for a window, never refreshing, or refreshing without the callback).
        // [CN] 失败信息包含阶段日志与起始刷新头的状态，便于看出停在哪一步（等待窗口、未开始刷新、或刷新了但没有回调）。
        let where_ = "log \(log), start state \(start.state.rawValue), in window \(start.window != nil ? 1 : 0), header \(page.tableView.cylHeader === start ? "start" : "other")"
        XCTAssertTrue(log.contains("refresh"), "the start header calls the regular header's target-action (\(where_))")
        XCTAssertTrue(page.tableView.cylHeader === regular, "the regular header is back after the first refresh (\(where_))")
        window.isHidden = true
    }

    // MARK: - CYLRefreshLayout parity (docs/iOS-API-Map.md)

    func testAutoRefreshTellsCodeFromAPull() {
        let scrollView = self.scrollView()
        let header = CYLAutoHookHeader.attach(to: scrollView)
        XCTAssertFalse(header.isAutoRefresh)
        header.beginRefreshing()
        XCTAssertTrue(header.isAutoRefresh, "started in code")
        header.state = .idle
        XCTAssertFalse(header.isAutoRefresh, "cleared when it ends")
        XCTAssertEqual(header.autoChanges, [true, false] as NSArray)
    }

    func testAnimationOnlySkipsTheCallbacksOnce() {
        let scrollView = self.scrollView()
        let header = CYLRefreshNormalHeader.attach(to: scrollView)
        var calls = 0
        header.refreshingBlock = { calls += 1 }
        header.beginRefreshingAnimationOnly()
        XCTAssertTrue(header.isRefreshing)
        header.executeRefreshingCallback()
        XCTAssertEqual(calls, 0, "animation only")
        header.state = .idle
        header.executeRefreshingCallback()
        XCTAssertEqual(calls, 1, "the next refresh calls back again")
    }

    func testScrollObserversDecidersAndContentTouches() {
        let scrollView = self.scrollView()
        let header = CYLRefreshNormalHeader.attach(to: scrollView)
        var moves = 0
        let token = header.addScrollObserver { _, _, _, _ in
            moves += 1
        }
        scrollView.contentOffset = CGPoint(x: 0, y: -10)
        XCTAssertGreaterThan(moves, 0, "OnMultiListener.onHeaderMoving")
        header.removeScrollObserver(token)
        let before = moves
        scrollView.contentOffset = CGPoint(x: 0, y: -20)
        XCTAssertEqual(moves, before, "removed observers stay silent")

        XCTAssertTrue(header.canTrigger(), "no decider: the built-in check")
        header.canTriggerBlock = { _ in false }
        XCTAssertFalse(header.canTrigger())

        header.disablesContentWhileRefreshing = true
        header.state = .refreshing
        XCTAssertFalse(scrollView.isUserInteractionEnabled, "setDisableContentWhenRefresh")
        header.state = .idle
        XCTAssertTrue(scrollView.isUserInteractionEnabled)
    }

    func testSecondFloorVetoAndDelayedCalls() {
        let scrollView = self.scrollView()
        let header = CYLRefreshNormalHeader.attach(to: scrollView)
        header.secondaryTriggerOffset = 120
        header.secondaryAnimationDuration = 0.05
        header.secondaryShouldOpenBlock = { _ in false }
        header.openSecondary()
        XCTAssertFalse(header.isSecondaryOpen, "OnTwoLevelListener returned false")
        header.secondaryShouldOpenBlock = { _ in true }
        header.openSecondary()
        XCTAssertTrue(header.isSecondaryOpen)

        let other = CYLRefreshNormalHeader.attach(to: self.scrollView())
        let began = expectation(description: "autoRefresh(delayed)")
        other.beginRefreshing(afterDelay: 0.05)
        XCTAssertFalse(other.isRefreshing, "not yet")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertTrue(other.isRefreshing)
            began.fulfill()
        }
        waitForExpectations(timeout: 2)
    }

    func testFinishWithNoMoreDataAndAppWideDefaults() {
        let scrollView = self.scrollView()
        let header = CYLRefreshNormalHeader.attach(to: scrollView)
        let footer = CYLRefreshBackNormalFooter.attach(to: scrollView)
        header.state = .refreshing
        scrollView.cylEndRefreshing(afterDelay: 0, success: true, noMoreData: true)
        XCTAssertTrue(footer.isNoMoreData, "finishRefresh(noMoreData: true)")
        scrollView.cylEndRefreshing(afterDelay: 0, success: true, noMoreData: false)
        XCTAssertFalse(footer.isNoMoreData, "finishRefresh(noMoreData: false) resets it")
        footer.state = .refreshing
        scrollView.cylEndLoadingMore(afterDelay: 0, success: true, noMoreData: true)
        XCTAssertTrue(footer.isNoMoreData, "finishLoadMore(noMoreData: true)")

        let config = CYLRefreshConfig.default
        var initialized = 0
        config.defaultHeaderCreator = { _ in CYLRefreshNormalHeader() }
        config.defaultFooterCreator = { _ in CYLRefreshBackNormalFooter() }
        config.defaultInitializer = { _ in initialized += 1 }
        let fresh = self.scrollView()
        fresh.cylInstallDefaultRefreshControls()
        config.defaultHeaderCreator = nil
        config.defaultFooterCreator = nil
        config.defaultInitializer = nil
        XCTAssertTrue(fresh.cylHeader is CYLRefreshNormalHeader)
        XCTAssertTrue(fresh.cylFooter is CYLRefreshBackNormalFooter)
        XCTAssertEqual(initialized, 2, "every new control is set up once")
    }

    func testLayoutOptionsDefaultsAndEffects() {
        let scrollView = self.scrollView()
        let header = CYLRefreshNormalHeader.attach(to: scrollView)
        let footer = CYLRefreshBackNormalFooter.attach(to: scrollView)
        let autoFooter = CYLRefreshAutoNormalFooter()
        XCTAssertEqual(header.dragRate, 0, "UIScrollView's own rubber band by default")
        XCTAssertEqual(header.reboundAnimationOptions, UIView.AnimationOptions(rawValue: 0))
        XCTAssertFalse(header.clipsWhenBehind)
        XCTAssertFalse(header.supportsHorizontalDrag)
        XCTAssertFalse(header.openForAutoRefresh(withDuration: 0.25), "autoOpen: the layout animates by default")
        XCTAssertTrue(footer.scrollsContentAfterLoading, "setEnableScrollContentWhenLoaded defaults to true")
        XCTAssertFalse(footer.followsContentWhenNoMoreData)
        XCTAssertTrue(autoFooter.loadsWhenContentNotFull, "setEnableLoadMoreWhenContentNotFull defaults to true")

        header.layoutIfNeeded()
        let y = header.cylY
        header.insetStart = 44
        header.setNeedsLayout()
        header.layoutIfNeeded()
        XCTAssertEqual(header.cylY, y + 44, accuracy: 0.5, "setHeaderInsetStart")

        let pinned = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        scrollView.addSubview(pinned)
        header.pinnedView = pinned
        scrollView.contentOffset = CGPoint(x: 0, y: -30)
        XCTAssertLessThan(pinned.transform.ty, 0, "setFixedHeaderViewId: moved back up by the pull")
        scrollView.contentOffset = .zero
        XCTAssertEqual(pinned.transform.ty, 0, accuracy: 0.001)
    }
}
