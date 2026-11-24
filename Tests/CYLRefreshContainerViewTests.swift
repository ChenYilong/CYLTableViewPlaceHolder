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
        XCTAssertTrue(scrollView.cyl_header is CYLRefreshNormalHeader)
        XCTAssertNil(scrollView.cyl_footer, "no footer until loadMoreEnabled, as on Android")
        XCTAssertTrue(container.clipsToBounds, "the resting header must not draw over the views above the container")
    }

    func testEnabledFalseRemovesTheHeaderAndTrueBringsItBack() {
        let (container, scrollView) = container()
        container.enabled = false
        XCTAssertNil(scrollView.cyl_header)
        container.enabled = true
        XCTAssertTrue(scrollView.cyl_header is CYLRefreshNormalHeader)
    }

    func testTheFooterIsTheBackFooterWhileLoadMoreIsEnabled() {
        let (container, scrollView) = container()
        container.loadMoreEnabled = true
        XCTAssertTrue(scrollView.cyl_footer is CYLRefreshBackNormalFooter)
        container.loadMoreEnabled = false
        XCTAssertNil(scrollView.cyl_footer)
    }

    func testPropsSetBeforeTheScrollViewArrivesAreAppliedWhenItDoes() {
        let (container, scrollView) = container(attach: false)
        container.loadMoreEnabled = true
        container.loadsAfterNoMoreData = true
        container.enabled = false
        XCTAssertNil(container.scrollView)
        addScrollView(scrollView, to: container)
        XCTAssertNil(scrollView.cyl_header, "enabled = false was set first")
        let footer = scrollView.cyl_footer
        XCTAssertTrue(footer is CYLRefreshBackNormalFooter)
        XCTAssertEqual(footer?.loadsAfterNoMoreData, true)
    }

    func testAPullStartedByTheUserSendsOnRefreshOnce() {
        let (_, scrollView) = container()
        scrollView.cyl_header?.beginRefreshing()
        spin()
        XCTAssertEqual(refreshEvents, 1)
        XCTAssertTrue(scrollView.cyl_header?.isRefreshing == true)
        scrollView.cyl_header?.endRefreshing()
        spin(0.8)
        XCTAssertEqual(refreshEvents, 1)
        XCTAssertFalse(scrollView.cyl_header?.isRefreshing == true)
    }

    func testRefreshingSetFromJavaScriptShowsTheStateWithoutCallingOnRefresh() {
        let (container, scrollView) = container()
        container.refreshing = true
        spin()
        XCTAssertTrue(scrollView.cyl_header?.isRefreshing == true)
        XCTAssertEqual(refreshEvents, 0, "a value JavaScript set does not call onRefresh back")
        container.refreshing = false
        spin(0.8)
        XCTAssertFalse(scrollView.cyl_header?.isRefreshing == true)
        XCTAssertEqual(refreshEvents, 0)
    }

    func testRefreshingSetBeforeTheScrollViewArrivesStartsWhenItDoes() {
        let (container, scrollView) = container(attach: false)
        container.refreshing = true
        addScrollView(scrollView, to: container)
        spin()
        XCTAssertTrue(scrollView.cyl_header?.isRefreshing == true)
        XCTAssertEqual(refreshEvents, 0)
    }

    func testALoadStartedByTheUserSendsOnLoadMoreOnce() {
        let (container, scrollView) = container()
        container.loadMoreEnabled = true
        scrollView.cyl_footer?.beginRefreshing()
        spin()
        XCTAssertEqual(loadMoreEvents, 1)
        XCTAssertTrue(scrollView.cyl_footer?.isRefreshing == true)
        container.loadingMore = false
        spin(0.8)
        XCTAssertFalse(scrollView.cyl_footer?.isRefreshing == true)
        XCTAssertEqual(loadMoreEvents, 1)
    }

    func testLoadingMoreSetFromJavaScriptShowsTheStateWithoutCallingOnLoadMore() {
        let (container, scrollView) = container()
        container.loadMoreEnabled = true
        container.loadingMore = true
        spin()
        XCTAssertTrue(scrollView.cyl_footer?.isRefreshing == true)
        XCTAssertEqual(loadMoreEvents, 0)
        container.loadingMore = false
        spin(0.8)
        XCTAssertFalse(scrollView.cyl_footer?.isRefreshing == true)
    }

    func testNoMoreDataShowsTheStateEndsALoadAndResets() {
        let (container, scrollView) = container()
        container.loadMoreEnabled = true
        scrollView.cyl_footer?.beginRefreshing()
        spin()
        XCTAssertTrue(scrollView.cyl_footer?.isRefreshing == true)
        // JavaScript ends a last load with loadingMore false and noMoreData true together, in either order.
        container.noMoreData = true
        container.loadingMore = false
        spin(0.8)
        XCTAssertEqual(scrollView.cyl_footer?.isNoMoreData, true)
        XCTAssertFalse(scrollView.cyl_footer?.isRefreshing == true)
        container.noMoreData = false
        XCTAssertEqual(scrollView.cyl_footer?.isNoMoreData, false)
    }

    func testNoMoreDataFalseFirstThenLoadingMoreFalseAlsoEndsInNoMoreData() {
        let (container, scrollView) = container()
        container.loadMoreEnabled = true
        scrollView.cyl_footer?.beginRefreshing()
        spin()
        container.loadingMore = false
        container.noMoreData = true
        spin(0.8)
        XCTAssertEqual(scrollView.cyl_footer?.isNoMoreData, true)
        XCTAssertFalse(scrollView.cyl_footer?.isRefreshing == true)
    }

    func testLoadsAfterNoMoreDataReachesTheFooter() {
        let (container, scrollView) = container()
        container.loadMoreEnabled = true
        XCTAssertEqual(scrollView.cyl_footer?.loadsAfterNoMoreData, false)
        container.loadsAfterNoMoreData = true
        XCTAssertEqual(scrollView.cyl_footer?.loadsAfterNoMoreData, true)
    }

    func testANewScrollViewReplacesTheOldOneAndTheOldOneLosesTheHeader() {
        let (container, old) = container()
        old.superview?.removeFromSuperview()
        container.layoutIfNeeded()
        XCTAssertNil(container.scrollView)
        let new = UIScrollView(frame: container.bounds)
        addScrollView(new, to: container)
        XCTAssertTrue(container.scrollView === new)
        XCTAssertTrue(new.cyl_header is CYLRefreshNormalHeader)
    }

    func testHeaderStyleAndFooterStyleChooseTheLookAndAnUnknownNameIsClassic() {
        let (container, scrollView) = container()
        container.loadMoreEnabled = true
        container.headerStyle = "phoenix"
        container.footerStyle = "taurus"
        XCTAssertTrue(scrollView.cyl_header is CYLRefreshPhoenixHeader)
        XCTAssertTrue(scrollView.cyl_footer is CYLRefreshTaurusFooter)
        container.headerStyle = "rainbow"
        container.footerStyle = nil
        XCTAssertTrue(scrollView.cyl_header is CYLRefreshNormalHeader)
        XCTAssertTrue(scrollView.cyl_footer is CYLRefreshBackNormalFooter)
        // [EN] A style set before the scroll view arrives is applied when it does. [CN] 滚动视图出现之前设置的样式，在它出现时生效。
        let (late, lateScrollView) = self.container(attach: false)
        late.headerStyle = "delivery"
        addScrollView(lateScrollView, to: late)
        XCTAssertTrue(lateScrollView.cyl_header is CYLRefreshDeliveryHeader)
    }

    func testAStyledHeaderStillCallsOnRefreshOnce() {
        let (container, scrollView) = container()
        container.headerStyle = "material"
        scrollView.cyl_header?.beginRefreshing()
        spin()
        XCTAssertEqual(refreshEvents, 1)
    }
}
