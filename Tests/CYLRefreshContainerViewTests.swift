//
//  CYLRefreshContainerViewTests.swift
//  CYLTableViewPlaceHolder tests
//
//  [EN] The iOS half of the React Native `CYLRefreshContainer` (CrossPlatform/react-native-cylplaceholder/ios/
//       CYLRefreshContainerView.m) without a React Native runtime: a plain UIScrollView child, the props as Android's
//       CYLRefreshContainerView takes them (refreshing, enabled, loadMoreEnabled, loadingMore, noMoreData) and the two events.
//  [CN] React Native `CYLRefreshContainer` 的 iOS 一侧，不需要 React Native 运行时：子视图是普通 UIScrollView，属性与 Android 的
//       CYLRefreshContainerView 相同（refreshing、enabled、loadMoreEnabled、loadingMore、noMoreData），以及两个事件。
//

import XCTest
import UIKit

final class CYLRefreshContainerViewTests: XCTestCase {

    private var window: UIWindow!
    private var refreshEvents = 0
    private var loadMoreEvents = 0

    override func setUp() {
        super.setUp()
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 600))
        window.isHidden = false
        refreshEvents = 0
        loadMoreEvents = 0
    }

    private func spin(_ seconds: TimeInterval = 0.3) {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: seconds))
    }

    // [EN] Polls for a state an animation completion produces: the refreshing block runs in the completion of the 0.25 s inset
    //      animation, so a fixed spin races it on a busy CI runner (the iOS 15 job). The assertions after it report a timeout.
    // [CN] 轮询由动画完成产生的状态：刷新块在 0.25 秒 inset 动画完成时运行，固定时长的 spin 在繁忙的 CI 机器上会与之竞争（iOS 15 任务）。
    @discardableResult
    private func waitUntil(timeout: TimeInterval = 15, _ condition: () -> Bool) -> Bool {
        let deadline = Date(timeIntervalSinceNow: timeout)
        while !condition() && deadline.timeIntervalSinceNow > 0 {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
        }
        return condition()
    }

    /// Counts the runs of a header's or footer's refreshing block (the container's own block still runs first).
    private func countRuns(of component: CYLRefreshComponent?, _ counter: @escaping () -> Void) {
        let container = component?.refreshingBlock
        component?.refreshingBlock = { container?(); counter() }
    }

    /// A container with a scroll view one wrapper deep, as React Native builds it (RCTScrollView > RCTCustomScrollView).
    private func container(attach: Bool = true) -> (CYLRefreshContainerView, UIScrollView) {
        let container = CYLRefreshContainerView(frame: window.bounds)
        container.onRefresh = { [unowned self] _ in refreshEvents += 1 }
        container.onLoadMore = { [unowned self] _ in loadMoreEvents += 1 }
        window.addSubview(container)
        let scrollView = UIScrollView(frame: container.bounds)
        scrollView.contentSize = CGSize(width: 320, height: 1200)
        if attach { addScrollView(scrollView, to: container) }
        return (container, scrollView)
    }

    private func addScrollView(_ scrollView: UIScrollView, to container: CYLRefreshContainerView) {
        let wrapper = UIView(frame: container.bounds)
        wrapper.addSubview(scrollView)
        container.addSubview(wrapper)
        container.layoutIfNeeded()
        spin(0.1)
    }

    func testTheFirstScrollViewBelowTheContainerGetsTheClassicHeader() {
        let (container, scrollView) = container()
        XCTAssertTrue(container.scrollView === scrollView)
        XCTAssertTrue(scrollView.cylHeader is CYLRefreshNormalHeader)
        XCTAssertNil(scrollView.cylFooter, "no footer until loadMoreEnabled, as on Android")
        XCTAssertTrue(container.clipsToBounds, "the resting header must not draw over the views above the container")
    }

    func testEnabledFalseRemovesTheHeaderAndTrueBringsItBack() {
        let (container, scrollView) = container()
        container.enabled = false
        XCTAssertNil(scrollView.cylHeader)
        container.enabled = true
        XCTAssertTrue(scrollView.cylHeader is CYLRefreshNormalHeader)
    }

    func testTheFooterIsTheBackFooterWhileLoadMoreIsEnabled() {
        let (container, scrollView) = container()
        container.loadMoreEnabled = true
        XCTAssertTrue(scrollView.cylFooter is CYLRefreshBackNormalFooter)
        container.loadMoreEnabled = false
        XCTAssertNil(scrollView.cylFooter)
    }

    func testPropsSetBeforeTheScrollViewArrivesAreAppliedWhenItDoes() {
        let (container, scrollView) = container(attach: false)
        container.loadMoreEnabled = true
        container.loadsAfterNoMoreData = true
        container.enabled = false
        XCTAssertNil(container.scrollView)
        addScrollView(scrollView, to: container)
        XCTAssertNil(scrollView.cylHeader, "enabled = false was set first")
        let footer = scrollView.cylFooter
        XCTAssertTrue(footer is CYLRefreshBackNormalFooter)
        XCTAssertEqual(footer?.loadsAfterNoMoreData, true)
    }

    func testAPullStartedByTheUserSendsOnRefreshOnce() {
        let (_, scrollView) = container()
        scrollView.cylHeader?.beginRefreshing()
        waitUntil { refreshEvents == 1 }
        XCTAssertEqual(refreshEvents, 1)
        XCTAssertTrue(scrollView.cylHeader?.isRefreshing == true)
        scrollView.cylHeader?.endRefreshing()
        waitUntil { scrollView.cylHeader?.isRefreshing != true }
        XCTAssertEqual(refreshEvents, 1)
        XCTAssertFalse(scrollView.cylHeader?.isRefreshing == true)
    }

    func testRefreshingSetFromJavaScriptShowsTheStateWithoutCallingOnRefresh() {
        let (container, scrollView) = container()
        var blockRuns = 0
        countRuns(of: scrollView.cylHeader) { blockRuns += 1 }
        container.refreshing = true
        // The block runs once the inset animation completes; JavaScript must not be told, and the one-shot flag is used up by it.
        waitUntil { blockRuns == 1 }
        XCTAssertTrue(scrollView.cylHeader?.isRefreshing == true)
        XCTAssertEqual(refreshEvents, 0, "a value JavaScript set does not call onRefresh back")
        container.refreshing = false
        waitUntil { scrollView.cylHeader?.isRefreshing != true }
        XCTAssertFalse(scrollView.cylHeader?.isRefreshing == true)
        XCTAssertEqual(refreshEvents, 0)
    }

    func testRefreshingSetBeforeTheScrollViewArrivesStartsWhenItDoes() {
        let (container, scrollView) = container(attach: false)
        container.refreshing = true
        addScrollView(scrollView, to: container)
        spin()
        XCTAssertTrue(scrollView.cylHeader?.isRefreshing == true)
        XCTAssertEqual(refreshEvents, 0)
    }

    func testALoadStartedByTheUserSendsOnLoadMoreOnce() {
        let (container, scrollView) = container()
        container.loadMoreEnabled = true
        scrollView.cylFooter?.beginRefreshing()
        waitUntil { loadMoreEvents == 1 }
        XCTAssertEqual(loadMoreEvents, 1)
        XCTAssertTrue(scrollView.cylFooter?.isRefreshing == true)
        container.loadingMore = false
        waitUntil { scrollView.cylFooter?.isRefreshing != true }
        XCTAssertFalse(scrollView.cylFooter?.isRefreshing == true)
        XCTAssertEqual(loadMoreEvents, 1)
    }

    func testLoadingMoreSetFromJavaScriptShowsTheStateWithoutCallingOnLoadMore() {
        let (container, scrollView) = container()
        container.loadMoreEnabled = true
        var blockRuns = 0
        countRuns(of: scrollView.cylFooter) { blockRuns += 1 }
        container.loadingMore = true
        waitUntil { blockRuns == 1 }
        XCTAssertTrue(scrollView.cylFooter?.isRefreshing == true)
        XCTAssertEqual(loadMoreEvents, 0)
        container.loadingMore = false
        waitUntil { scrollView.cylFooter?.isRefreshing != true }
        XCTAssertFalse(scrollView.cylFooter?.isRefreshing == true)
    }

    func testNoMoreDataShowsTheStateEndsALoadAndResets() {
        let (container, scrollView) = container()
        container.loadMoreEnabled = true
        scrollView.cylFooter?.beginRefreshing()
        waitUntil { loadMoreEvents == 1 }
        XCTAssertTrue(scrollView.cylFooter?.isRefreshing == true)
        // JavaScript ends a last load with loadingMore false and noMoreData true together, in either order.
        container.noMoreData = true
        container.loadingMore = false
        waitUntil { scrollView.cylFooter?.isNoMoreData == true && scrollView.cylFooter?.isRefreshing != true }
        XCTAssertEqual(scrollView.cylFooter?.isNoMoreData, true)
        XCTAssertFalse(scrollView.cylFooter?.isRefreshing == true)
        container.noMoreData = false
        XCTAssertEqual(scrollView.cylFooter?.isNoMoreData, false)
    }

    func testNoMoreDataFalseFirstThenLoadingMoreFalseAlsoEndsInNoMoreData() {
        let (container, scrollView) = container()
        container.loadMoreEnabled = true
        scrollView.cylFooter?.beginRefreshing()
        waitUntil { loadMoreEvents == 1 }
        container.loadingMore = false
        container.noMoreData = true
        waitUntil { scrollView.cylFooter?.isNoMoreData == true && scrollView.cylFooter?.isRefreshing != true }
        XCTAssertEqual(scrollView.cylFooter?.isNoMoreData, true)
        XCTAssertFalse(scrollView.cylFooter?.isRefreshing == true)
    }

    func testLoadsAfterNoMoreDataReachesTheFooter() {
        let (container, scrollView) = container()
        container.loadMoreEnabled = true
        XCTAssertEqual(scrollView.cylFooter?.loadsAfterNoMoreData, false)
        container.loadsAfterNoMoreData = true
        XCTAssertEqual(scrollView.cylFooter?.loadsAfterNoMoreData, true)
    }

    func testANewScrollViewReplacesTheOldOneAndTheOldOneLosesTheHeader() {
        let (container, old) = container()
        old.superview?.removeFromSuperview()
        container.layoutIfNeeded()
        XCTAssertNil(container.scrollView)
        let new = UIScrollView(frame: container.bounds)
        addScrollView(new, to: container)
        XCTAssertTrue(container.scrollView === new)
        XCTAssertTrue(new.cylHeader is CYLRefreshNormalHeader)
    }

    func testHeaderStyleAndFooterStyleChooseTheLookAndAnUnknownNameIsClassic() {
        let (container, scrollView) = container()
        container.loadMoreEnabled = true
        container.headerStyle = "phoenix"
        container.footerStyle = "taurus"
        XCTAssertTrue(scrollView.cylHeader is CYLRefreshPhoenixHeader)
        XCTAssertTrue(scrollView.cylFooter is CYLRefreshTaurusFooter)
        container.headerStyle = "rainbow"
        container.footerStyle = nil
        XCTAssertTrue(scrollView.cylHeader is CYLRefreshNormalHeader)
        XCTAssertTrue(scrollView.cylFooter is CYLRefreshBackNormalFooter)
        // [EN] A style set before the scroll view arrives is applied when it does. [CN] 滚动视图出现之前设置的样式，在它出现时生效。
        let (late, lateScrollView) = self.container(attach: false)
        late.headerStyle = "delivery"
        addScrollView(lateScrollView, to: late)
        XCTAssertTrue(lateScrollView.cylHeader is CYLRefreshDeliveryHeader)
    }

    func testAStyledHeaderStillCallsOnRefreshOnce() {
        let (container, scrollView) = container()
        container.headerStyle = "material"
        scrollView.cylHeader?.beginRefreshing()
        waitUntil { refreshEvents == 1 }
        XCTAssertEqual(refreshEvents, 1)
    }
}
