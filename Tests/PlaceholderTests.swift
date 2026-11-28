//
//  PlaceholderTests.swift
//  CYLTableViewPlaceHolder tests
//
//  [EN] Regression tests of the legacy `cylReloadData` placeholder and of CYLRefresh (insets, trailers, paging,
//       teardown, localization). Swift since 2026-11-20 (docs/Swift-Migration.md, step 13): the same tests and
//       assertions as the former `PlaceholderTests.m`, compiled into the library's module.
//  [CN] 旧版 `cylReloadData` 占位图与 CYLRefresh（inset、trailer、分页、销毁、本地化）的回归测试。自 2026-11-20 起用 Swift 编写
//       （docs/Swift-Migration.md 第 13 步）：测试与断言与原 `PlaceholderTests.m` 相同，编译进库的模块。
//

import ObjectiveC
import UIKit
import XCTest

/**
 * Upper bound for condition-based waits. UIView animation completions, even for 0-second
 * animations, have stalled for over 5 s on loaded CI runners; waits still end as soon as the
 * expectation is fulfilled, so a generous bound costs nothing when tests pass. 30 s was not enough once: on the macOS 26
 * runner (Xcode 26.6, iOS 26.6 simulator) testHeaderKeepsItsRefreshingInsetWhenTheInsetIsResetDuringARefresh took 65 s,
 * because the main thread was starved for tens of seconds (CI run 44587370593, 2026-11-19); every later assertion of that
 * test passed, so the completion was late, not lost.
 */
private let CYLTestTimeout: TimeInterval = 120

extension Bundle {

    /**
     * [EN] Exchanged with `+cyl_refreshBundle` by `testMissingRefreshBundleFallsBackWithoutException`: no bundle.
     * [CN] 由 `testMissingRefreshBundleFallsBackWithoutException` 与 `+cyl_refreshBundle` 交换：没有 bundle。
     */
    @objc fileprivate class func testMissingRefreshBundle() -> Bundle? { nil }
}

private final class CYLTestPanGestureRecognizer: UIPanGestureRecognizer {
    var testState: UIGestureRecognizer.State = .possible

    override var state: UIGestureRecognizer.State {
        get { testState }
        set { super.state = newValue }
    }
}

private final class CYLTestScrollView: UIScrollView {
    var testOffset: CGPoint = .zero
    var testPan: CYLTestPanGestureRecognizer?

    override var contentOffset: CGPoint {
        get { testOffset }
        set { super.contentOffset = newValue }
    }

    override var panGestureRecognizer: UIPanGestureRecognizer { testPan ?? super.panGestureRecognizer }
}

private final class CYLTestPagingScrollView: UIScrollView {
    var testDragging = false
    var testDecelerating = false

    override var isDragging: Bool { testDragging }
    override var isDecelerating: Bool { testDecelerating }
}

// [EN] A scroll view that reports a drag and a pan state set by the test. [CN] 由测试设置拖动与手势状态的滚动视图。
private final class CYLTestDraggingScrollView: UIScrollView {
    var testDragging = false
    var testPan: CYLTestPanGestureRecognizer?

    override var isDragging: Bool { testDragging }
    override var panGestureRecognizer: UIPanGestureRecognizer { testPan ?? super.panGestureRecognizer }
}

private final class CYLTestReentrantScrollView: UIScrollView {
    var triggerInsetFeedback = false
    var insetDepth = 0
    var maxInsetDepth = 0

    override var contentInset: UIEdgeInsets {
        get { super.contentInset }
        set {
            insetDepth += 1
            maxInsetDepth = max(maxInsetDepth, insetDepth)
            super.contentInset = newValue
            if triggerInsetFeedback && insetDepth < 8 {
                let offset: CGFloat = contentOffset.y < -15 ? -10 : -20
                contentOffset = CGPoint(x: contentOffset.x, y: offset)
            }
            insetDepth -= 1
        }
    }
}

private final class CYLTestCollectionSource: NSObject, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        40
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    }
}

private class CYLTestSource: NSObject, UITableViewDataSource, CYLTableViewPlaceHolderDelegate {
    var rows = 0
    var allowScroll = false
    var view: UIView?

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell(style: .default, reuseIdentifier: nil)
    }

    func makePlaceHolderView() -> UIView! { view }

    func enableScrollWhenPlaceHolderViewShowing() -> Bool { allowScroll }
}

private final class CYLRefreshSource: CYLTestSource {
    @objc(frameForPlaceHolderViewInTableView:)
    func frameForPlaceHolderView(in tableView: UITableView) -> CGRect {
        let top = tableView.cylFooter?.frame.maxY ?? 0
        return CGRect(x: 0, y: top, width: tableView.bounds.width, height: max(0, tableView.bounds.height - top))
    }
}

private final class CYLFramedSource: CYLTestSource {
    @objc(frameForPlaceHolderViewInTableView:)
    func frameForPlaceHolderView(in tableView: UITableView) -> CGRect {
        CGRect(x: 0, y: 40, width: tableView.bounds.size.width, height: tableView.bounds.size.height - 80)
    }
}

private final class CYLMultipleSectionsSource: CYLTestSource {
    @objc(numberOfSectionsInTableView:)
    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 1 ? rows : 0
    }
}

/**
 * Two empty sections with custom section headers; the placeholder starts below the last one (issue #16).
 */
private final class CYLSectionHeaderSource: NSObject, UITableViewDataSource, UITableViewDelegate, CYLTableViewPlaceHolderDelegate {
    var view: UIView?

    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 0 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell(style: .default, reuseIdentifier: nil)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 30 }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30))
    }

    func makePlaceHolderView() -> UIView! { view }

    func frameForPlaceHolderView(in tableView: UITableView) -> CGRect {
        let lastSection = tableView.numberOfSections - 1
        let top = lastSection >= 0 ? tableView.rectForHeader(inSection: lastSection).maxY : 0
        return CGRect(x: 0, y: top, width: tableView.bounds.width, height: max(0, tableView.bounds.height - top))
    }
}

private final class CYLTestDelegate: NSObject, UITableViewDelegate, CYLTableViewPlaceHolderDelegate {
    var view: UIView?

    func makePlaceHolderView() -> UIView! { view }
}

/**
 * [EN] A refresh control of `kind` made as `+headerWithRefreshingBlock:` / `+footerWithRefreshingBlock:` /
 *      `+trailerWithRefreshingBlock:` make it: `-init`, then an empty refreshing block.
 * [CN] 按 `+headerWithRefreshingBlock:` / `+footerWithRefreshingBlock:` / `+trailerWithRefreshingBlock:` 的方式创建 `kind`
 *      的刷新控件：先 `-init`，再设置空的刷新回调。
 */
private func CYLMakeRefreshComponent(_ kind: CYLRefreshComponent.Type) -> CYLRefreshComponent {
    let component = (kind as NSObject.Type).init() as! CYLRefreshComponent
    component.refreshingBlock = {}
    return component
}

final class PlaceholderTests: XCTestCase {
    private var table: UITableView!
    private var source: CYLTestSource!

    override func setUp() {
        super.setUp()
        table = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        source = CYLTestSource()
        source.view = UIView()
        table.dataSource = source
    }

    func testDefaultSectionAndScrollRestoration() {
        table.isScrollEnabled = true
        table.cylReloadData()
        XCTAssertIdentical(source.view?.superview, table)
        XCTAssertFalse(table.isScrollEnabled)
        XCTAssertTrue(source.view!.frame.equalTo(CGRect(x: 0, y: 0, width: 320, height: 480)))
        source.rows = 1
        table.cylReloadData()
        XCTAssertNil(source.view?.superview)
        XCTAssertTrue(table.isScrollEnabled)
    }

    func testRepeatedEmptyReloadKeepsSubviewsAndCanSwitchViews() {
        let child = UIView()
        source.view!.addSubview(child)
        let first = source.view!
        table.cylReloadData()
        table.cylReloadData()
        XCTAssertIdentical(child.superview, first)
        source.view = UIView()
        table.cylReloadData()
        XCTAssertNil(first.superview)
        XCTAssertIdentical(source.view?.superview, table)
    }

    func testOptionalScrollAndNilPlaceholder() {
        source.allowScroll = true
        let oldView = source.view!
        table.cylReloadData()
        XCTAssertTrue(table.isScrollEnabled)
        source.view = nil
        table.cylReloadData()
        XCTAssertNil(oldView.superview)
        XCTAssertTrue(table.isScrollEnabled)
    }

    func testInitiallyDisabledScrollIsRestored() {
        table.isScrollEnabled = false
        source.allowScroll = true
        table.cylReloadData()
        XCTAssertTrue(table.isScrollEnabled)
        source.rows = 1
        table.cylReloadData()
        XCTAssertFalse(table.isScrollEnabled)
    }

    func testRowsInLaterSectionRemovePlaceholder() {
        let source = CYLMultipleSectionsSource()
        source.view = UIView()
        table.dataSource = source
        table.cylReloadData()
        XCTAssertIdentical(source.view?.superview, table)
        source.rows = 1
        table.cylReloadData()
        XCTAssertNil(source.view?.superview)
    }

    func testDefaultFrameFollowsTableResize() {
        table.cylReloadData()
        table.frame = CGRect(x: 0, y: 0, width: 375, height: 700)
        table.layoutIfNeeded()
        XCTAssertEqual(source.view!.frame.width, 375, accuracy: 0.1)
        XCTAssertEqual(source.view!.frame.height, 700, accuracy: 0.1)
    }

    func testDefaultFrameStaysAboveTheKeyboard() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.addSubview(table)
        table.cylReloadData()
        XCTAssertEqual(source.view!.frame.height, 480, accuracy: 0.1, "no keyboard: the whole table")
        // [EN] A 200-point keyboard at the bottom of the screen (CYLSearchViewController's report). [CN] 屏幕底部 200 点高的键盘。
        let keyboard = window.convert(CGRect(x: 0, y: 280, width: 320, height: 200), to: window.screen.coordinateSpace)
        NotificationCenter.default.post(name: UIResponder.keyboardWillChangeFrameNotification, object: nil,
                                        userInfo: [UIResponder.keyboardFrameEndUserInfoKey: NSValue(cgRect: keyboard)])
        XCTAssertEqual(source.view!.frame.height, 280, accuracy: 0.1, "above the keyboard, live")
        table.cylReloadData()
        XCTAssertEqual(source.view!.frame.height, 280, accuracy: 0.1, "a reload keeps it above the keyboard")
        NotificationCenter.default.post(name: UIResponder.keyboardWillHideNotification, object: nil, userInfo: nil)
        XCTAssertEqual(source.view!.frame.height, 480, accuracy: 0.1, "the keyboard hides: the whole table again")
        table.removeFromSuperview()
    }

    func testPlaceholderShownWhileTheKeyboardIsUpEndsAtTheKeyboard() {
        // [EN] CYLSearchViewController's search: the keyboard is up before the first empty result, and the table has a top
        //      bar inset. [CN] CYLSearchViewController 的搜索：键盘在第一次空结果之前已显示，表格有顶部栏内边距。
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.addSubview(table)
        table.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
        let keyboard = window.convert(CGRect(x: 0, y: 280, width: 320, height: 200), to: window.screen.coordinateSpace)
        NotificationCenter.default.post(name: UIResponder.keyboardWillChangeFrameNotification, object: nil,
                                        userInfo: [UIResponder.keyboardFrameEndUserInfoKey: NSValue(cgRect: keyboard)])
        table.cylReloadData()
        let inset = table.adjustedContentInset.top
        XCTAssertEqual(source.view!.frame.height, 480 - inset - 200, accuracy: 0.1,
                       "from below the top bar to the keyboard's top")
        NotificationCenter.default.post(name: UIResponder.keyboardWillHideNotification, object: nil, userInfo: nil)
        XCTAssertEqual(source.view!.frame.height, 480, accuracy: 0.1, "no keyboard: as before")
        table.removeFromSuperview()
    }

    func testDelegateTakesPrecedenceOverDataSource() {
        let delegate = CYLTestDelegate()
        delegate.view = UIView()
        table.delegate = delegate
        table.cylReloadData()
        XCTAssertIdentical(delegate.view?.superview, table)
        XCTAssertNil(source.view?.superview)
    }

    func testCustomFrameLeavesHeaderOutsidePlaceholder() {
        let source = CYLFramedSource()
        source.view = UIView()
        table.dataSource = source
        let header = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        table.tableHeaderView = header
        table.cylReloadData()
        XCTAssertTrue(source.view!.frame.equalTo(CGRect(x: 0, y: 40, width: 320, height: 400)))
        XCTAssertFalse(source.view!.frame.intersects(header.frame))
        XCTAssertIdentical(source.view?.superview, table)
    }

    func testDefaultPlaceholderKeepsRefreshControlsVisible() {
        let tableHeader = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        table.tableHeaderView = tableHeader
        table.cylHeader = CYLRefreshNormalHeader(refreshingBlock: {})
        table.cylFooter = CYLRefreshAutoNormalFooter(refreshingBlock: {})
        for _ in 0..<2 {
            table.cylReloadData()
            let subviews = table.subviews as NSArray
            let placeholderIndex = subviews.index(of: source.view!)
            XCTAssertNotEqual(placeholderIndex, NSNotFound)
            // The placeholder still covers ordinary content but stays below refresh controls (issue #8).
            XCTAssertGreaterThan(placeholderIndex, subviews.index(of: tableHeader))
            XCTAssertGreaterThan(subviews.index(of: table.cylFooter!), placeholderIndex)
            XCTAssertGreaterThan(subviews.index(of: table.cylHeader!), placeholderIndex)
            XCTAssertTrue(source.view!.frame.equalTo(CGRect(x: 0, y: 0, width: 320, height: 480)))
        }
    }

    func testCustomFrameLeavesSectionHeadersOutsidePlaceholder() {
        let source = CYLSectionHeaderSource()
        source.view = UIView()
        table.dataSource = source
        table.delegate = source
        let tableHeader = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        table.tableHeaderView = tableHeader
        for size in [CGSize(width: 320, height: 480), CGSize(width: 480, height: 320)] {
            // Rotation: the app reloads after the size changes and the frame is recomputed.
            table.frame = CGRect(origin: .zero, size: size)
            table.cylReloadData()
            table.layoutIfNeeded()
            let placeholder = source.view!.frame
            XCTAssertIdentical(source.view?.superview, table)
            XCTAssertEqual(placeholder.width, size.width, accuracy: 0.001)
            XCTAssertGreaterThan(placeholder.height, 0)
            XCTAssertFalse(placeholder.intersects(tableHeader.frame),
                           "\(NSCoder.string(for: placeholder)) vs table header \(NSCoder.string(for: tableHeader.frame))")
            for section in 0..<2 {
                let header = table.rectForHeader(inSection: section)
                XCTAssertGreaterThan(header.height, 0)
                XCTAssertFalse(placeholder.intersects(header),
                               "\(NSCoder.string(for: placeholder)) vs section \(section) header \(NSCoder.string(for: header)) at \(NSCoder.string(for: size))")
            }
        }
    }

    func testRefreshFooterCanRemainOutsidePlaceholder() {
        let source = CYLRefreshSource()
        source.view = UIView()
        table.dataSource = source
        table.cylFooter = CYLRefreshAutoNormalFooter(refreshingBlock: {})
        table.cylReloadData()
        table.layoutIfNeeded()
        XCTAssertGreaterThan(table.cylFooter!.frame.height, 0)
        XCTAssertFalse(source.view!.frame.intersects(table.cylFooter!.frame))
        XCTAssertIdentical(table.cylFooter?.superview, table)
    }

    func testRefreshResourcesAndCategoryAccessors() {
        table.cylHeader = CYLRefreshNormalHeader(refreshingBlock: {})
        XCTAssertIdentical(table.cylHeader?.superview, table)
        XCTAssertNotNil(Bundle.cylRefresh())
        XCTAssertNotNil(Bundle.cylArrowImage())
        CYLRefreshConfig.default.languageCode = "en"
        XCTAssertEqual(Bundle.cylLocalizedString(forKey: CYLRefreshHeaderIdleText), "Pull down to refresh")
        CYLRefreshConfig.default.languageCode = nil
        table.cylHeader = nil
        XCTAssertNil(table.cylHeader)
    }

    func testNormalHeaderAndArrowViewDeallocateAfterRemoval() {
        weak var weakHeader: CYLRefreshNormalHeader?
        weak var weakArrow: UIImageView?
        let cachedArrow: UIImage? = Bundle.cylArrowImage()
        XCTAssertNotNil(cachedArrow)
        autoreleasepool {
            let header = CYLRefreshNormalHeader(refreshingBlock: {})
            table.cylHeader = header
            header.layoutIfNeeded()
            var arrow: UIImageView?
            for view in header.subviews {
                if let imageView = view as? UIImageView, imageView.image === cachedArrow {
                    arrow = imageView
                    break
                }
            }
            XCTAssertNotNil(arrow)
            weakHeader = header
            weakArrow = arrow
            table.cylHeader = nil
        }
        XCTAssertNil(weakHeader)
        XCTAssertNil(weakArrow)
        XCTAssertIdentical(Bundle.cylArrowImage(), cachedArrow)
    }

    func testHeaderRefreshingCallbackAndCompletion() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = UIViewController()
        window.rootViewController!.view.addSubview(table)
        window.makeKeyAndVisible()
        let started = expectation(description: "refresh callback")
        table.cylHeader = CYLRefreshNormalHeader(refreshingBlock: {
            started.fulfill()
        })
        table.cylHeader!.fastAnimationDuration = 0
        table.cylHeader!.slowAnimationDuration = 0
        table.cylHeader!.beginRefreshing()
        wait(for: [started], timeout: CYLTestTimeout)
        XCTAssertTrue(table.cylHeader!.isRefreshing)
        let ended = expectation(description: "refresh completion")
        table.cylHeader!.endRefreshing(completionBlock: {
            ended.fulfill()
        })
        wait(for: [ended], timeout: CYLTestTimeout)
        XCTAssertFalse(table.cylHeader!.isRefreshing)
        table.cylHeader = nil
        window.isHidden = true
    }

    func testRefreshComponentDoesNotOverrideDrawing() {
        var count: UInt32 = 0
        let methods = class_copyMethodList(CYLRefreshComponent.self, &count)
        var overridesDrawRect = false
        for index in 0..<Int(count) where method_getName(methods![index]) == #selector(UIView.draw(_:)) {
            overridesDrawRect = true
            break
        }
        free(methods)
        XCTAssertFalse(overridesDrawRect)
    }

    func testPendingRefreshStartsOnceAfterWindowAttachment() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        let components: [CYLRefreshComponent] = [
            CYLRefreshNormalHeader(refreshingBlock: {}),
            CYLRefreshAutoNormalFooter(refreshingBlock: {}),
            CYLRefreshBackNormalFooter(refreshingBlock: {}),
            CYLRefreshNormalTrailer(refreshingBlock: {})
        ]
        for component in components {
            let scrollView = UIScrollView(frame: window.bounds)
            component.fastAnimationDuration = 0
            component.slowAnimationDuration = 0
            var callbacks = 0
            let started = expectation(description: "pending refresh started")
            component.refreshingBlock = {
                callbacks += 1
                started.fulfill()
            }
            scrollView.addSubview(component)
            component.beginRefreshing()
            component.beginRefreshing()
            XCTAssertEqual(component.state, .willRefresh)
            XCTAssertEqual(callbacks, 0)
            window.rootViewController!.view.addSubview(scrollView)
            wait(for: [started], timeout: CYLTestTimeout)
            XCTAssertEqual(component.state, .refreshing)
            XCTAssertEqual(callbacks, 1)
            component.endRefreshing()
            component.removeFromSuperview()
            scrollView.removeFromSuperview()
        }
        window.isHidden = true
    }

    func testPendingRefreshCanBeCancelledBeforeWindowAttachment() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        let scrollView = UIScrollView(frame: window.bounds)
        var callbacks = 0
        let footer: CYLRefreshAutoFooter = CYLRefreshAutoNormalFooter(refreshingBlock: { callbacks += 1 })
        scrollView.addSubview(footer)
        footer.beginRefreshing()
        window.rootViewController!.view.addSubview(scrollView)
        footer.endRefreshing()
        let nextTurn = expectation(description: "pending transition processed")
        DispatchQueue.main.async { nextTurn.fulfill() }
        wait(for: [nextTurn], timeout: CYLTestTimeout)
        XCTAssertEqual(footer.state, .idle)
        XCTAssertEqual(callbacks, 0)
        footer.removeFromSuperview()
        window.isHidden = true
    }

    func testPendingRefreshWaitsForReattachmentAndWorksWhenHidden() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        let scrollView = UIScrollView(frame: window.bounds)
        let started = expectation(description: "reattached refresh started")
        var callbacks = 0
        let footer: CYLRefreshAutoFooter = CYLRefreshAutoNormalFooter(refreshingBlock: {
            callbacks += 1
            started.fulfill()
        })
        footer.isHidden = true
        scrollView.addSubview(footer)
        footer.beginRefreshing()
        window.rootViewController!.view.addSubview(scrollView)
        scrollView.removeFromSuperview()
        let nextTurn = expectation(description: "detached transition processed")
        DispatchQueue.main.async { nextTurn.fulfill() }
        wait(for: [nextTurn], timeout: CYLTestTimeout)
        XCTAssertEqual(footer.state, .willRefresh)
        XCTAssertEqual(callbacks, 0)
        window.rootViewController!.view.addSubview(scrollView)
        wait(for: [started], timeout: CYLTestTimeout)
        XCTAssertEqual(callbacks, 1)
        footer.endRefreshing()
        footer.removeFromSuperview()
        scrollView.removeFromSuperview()
        window.isHidden = true
    }

    func testHeaderRestoresInsetAcrossRepeatedRefreshes() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = UIViewController()
        window.rootViewController!.view.addSubview(table)
        table.contentInsetAdjustmentBehavior = .never
        table.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 12, right: 0)
        window.makeKeyAndVisible()
        let header: CYLRefreshHeader = CYLRefreshNormalHeader(refreshingBlock: {})
        header.fastAnimationDuration = 0
        header.slowAnimationDuration = 0
        table.cylHeader = header
        for _ in 0..<3 {
            let started = expectation(description: "header started")
            header.beginRefreshing(completionBlock: { started.fulfill() })
            wait(for: [started], timeout: CYLTestTimeout)
            XCTAssertEqual(table.cylInsetT, 20 + header.cylH, accuracy: 0.001)
            let ended = expectation(description: "header ended")
            header.endRefreshing(completionBlock: { ended.fulfill() })
            wait(for: [ended], timeout: CYLTestTimeout)
            XCTAssertEqual(table.cylInsetT, 20, accuracy: 0.001)
        }
        table.cylHeader = nil
        window.isHidden = true
    }

    // FIX: issue MJRefresh#1628
    // [EN] SwiftUI's ScrollView resets the inset and the offset when its data changes during a refresh; the header adds its
    //      refreshing inset again on the new original inset and stays visible, and ending the refresh returns to that inset.
    // [CN] 刷新期间 SwiftUI 的 ScrollView 在数据变化时重置 inset 和 offset；刷新头在新的原始 inset 上重新加上刷新 inset 并保持可见，
    //      结束刷新后回到该 inset。
    func testHeaderKeepsItsRefreshingInsetWhenTheInsetIsResetDuringARefresh() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = UIViewController()
        window.rootViewController!.view.addSubview(table)
        table.contentInsetAdjustmentBehavior = .never
        table.contentInset = .zero
        window.makeKeyAndVisible()
        let header: CYLRefreshHeader = CYLRefreshNormalHeader(refreshingBlock: {})
        header.fastAnimationDuration = 0
        header.slowAnimationDuration = 0
        table.cylHeader = header
        let started = expectation(description: "header started")
        header.beginRefreshing(completionBlock: { started.fulfill() })
        wait(for: [started], timeout: CYLTestTimeout)
        XCTAssertEqual(table.cylInsetT, header.cylH, accuracy: 0.001)

        // [EN] The reset of the original issue: inset and offset back to zero. [CN] 原 issue 中的重置：inset 与 offset 归零。
        table.contentOffset = .zero
        table.contentInset = .zero
        XCTAssertTrue(header.isRefreshing)
        XCTAssertEqual(table.cylInsetT, header.cylH, accuracy: 0.001)
        XCTAssertEqual(table.contentOffset.y, -header.cylH, accuracy: 0.001)
        let headerFrame = header.convert(header.bounds, to: window)
        let viewport = table.convert(table.bounds, to: window)
        XCTAssertTrue(headerFrame.intersects(viewport))

        // [EN] A new inset written during the refresh becomes the original inset. [CN] 刷新期间写入的新 inset 成为原始 inset。
        table.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        XCTAssertEqual(table.cylInsetT, 20 + header.cylH, accuracy: 0.001)
        XCTAssertEqual(table.contentOffset.y, -(20 + header.cylH), accuracy: 0.001)

        let ended = expectation(description: "header ended")
        header.endRefreshing(completionBlock: { ended.fulfill() })
        wait(for: [ended], timeout: CYLTestTimeout)
        XCTAssertEqual(table.cylInsetT, 20, accuracy: 0.001)
        table.cylHeader = nil
        window.isHidden = true
    }

    func testHeaderInsetFeedbackDuringStartAndResetDoesNotReenterSetter() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = UIViewController()
        let scrollView = CYLTestReentrantScrollView(frame: window.bounds)
        scrollView.contentInsetAdjustmentBehavior = .never
        window.rootViewController!.view.addSubview(scrollView)
        window.makeKeyAndVisible()
        let header: CYLRefreshHeader = CYLRefreshNormalHeader(refreshingBlock: {})
        header.fastAnimationDuration = 0
        header.slowAnimationDuration = 0
        scrollView.cylHeader = header
        scrollView.triggerInsetFeedback = true
        let started = expectation(description: "header started")
        header.beginRefreshing(completionBlock: { started.fulfill() })
        wait(for: [started], timeout: CYLTestTimeout)
        scrollView.triggerInsetFeedback = false
        XCTAssertEqual(scrollView.maxInsetDepth, 1)
        XCTAssertEqual(scrollView.cylInsetT, header.cylH, accuracy: 0.001)

        scrollView.maxInsetDepth = 0
        scrollView.triggerInsetFeedback = true
        scrollView.contentOffset = CGPoint(x: 0, y: -20)
        scrollView.triggerInsetFeedback = false
        XCTAssertEqual(scrollView.maxInsetDepth, 1)
        let ended = expectation(description: "header ended")
        header.endRefreshing(completionBlock: { ended.fulfill() })
        wait(for: [ended], timeout: CYLTestTimeout)
        XCTAssertEqual(scrollView.cylInsetT, 0, accuracy: 0.001)
        scrollView.cylHeader = nil
        window.isHidden = true
    }

    func testHeaderRefreshWithNavigationSearchController() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let controller = UIViewController()
        let navigation = UINavigationController(rootViewController: controller)
        controller.navigationItem.searchController = UISearchController(searchResultsController: nil)
        controller.navigationItem.hidesSearchBarWhenScrolling = true
        window.rootViewController = navigation
        let table = UITableView(frame: controller.view.bounds, style: .plain)
        table.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        controller.view.addSubview(table)
        window.makeKeyAndVisible()
        controller.view.layoutIfNeeded()
        let initialInset = table.contentInset.top
        let header: CYLRefreshHeader = CYLRefreshNormalHeader(refreshingBlock: {})
        header.fastAnimationDuration = 0
        header.slowAnimationDuration = 0
        table.cylHeader = header
        let started = expectation(description: "search header started")
        header.beginRefreshing(completionBlock: { started.fulfill() })
        wait(for: [started], timeout: CYLTestTimeout)
        table.contentOffset = CGPoint(x: 0, y: 100)
        controller.view.layoutIfNeeded()
        header.endRefreshing()
        XCTAssertEqual(table.contentInset.top, initialInset, accuracy: 0.01)
        table.cylHeader = nil
        window.isHidden = true
    }

    func testHiddenHeaderRestoresInsetAfterProgrammaticRefresh() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = UIViewController()
        window.rootViewController!.view.addSubview(table)
        table.contentInsetAdjustmentBehavior = .never
        table.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        window.makeKeyAndVisible()
        let header: CYLRefreshHeader = CYLRefreshNormalHeader(refreshingBlock: {})
        header.fastAnimationDuration = 0
        header.slowAnimationDuration = 0
        header.isHidden = true
        table.cylHeader = header
        XCTAssertEqual(header.cylY, -header.cylH, accuracy: 0.001)
        for _ in 0..<3 {
            let started = expectation(description: "hidden header started")
            header.beginRefreshing(completionBlock: { started.fulfill() })
            wait(for: [started], timeout: CYLTestTimeout)
            XCTAssertEqual(table.cylInsetT, 20 + header.cylH, accuracy: 0.001)
            let ended = expectation(description: "hidden header ended")
            header.endRefreshing(completionBlock: { ended.fulfill() })
            wait(for: [ended], timeout: CYLTestTimeout)
            XCTAssertEqual(table.cylInsetT, 20, accuracy: 0.001)
        }
        table.cylHeader = nil
        window.isHidden = true
    }

    func testCollectionHeaderRestoresInsetForVisibleAndHiddenRefreshes() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = UIViewController()
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: window.bounds, collectionViewLayout: layout)
        collection.contentInsetAdjustmentBehavior = .never
        collection.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        window.rootViewController!.view.addSubview(collection)
        window.makeKeyAndVisible()
        let header: CYLRefreshHeader = CYLRefreshNormalHeader(refreshingBlock: {})
        header.isCollectionViewAnimationBug = true
        header.fastAnimationDuration = 0.01
        header.slowAnimationDuration = 0.01
        collection.cylHeader = header
        for index in 0..<4 {
            header.isHidden = index % 2 == 0
            let started = expectation(description: "collection header started")
            header.beginRefreshing(completionBlock: { started.fulfill() })
            wait(for: [started], timeout: CYLTestTimeout)
            XCTAssertEqual(collection.cylInsetT, 20 + header.cylH, accuracy: 0.001)
            let ended = expectation(description: "collection header ended")
            header.endRefreshing(completionBlock: { ended.fulfill() })
            wait(for: [ended], timeout: CYLTestTimeout)
            XCTAssertEqual(collection.cylInsetT, 20, accuracy: 0.001)
            XCTAssertTrue(collection.isUserInteractionEnabled)
        }
        collection.cylHeader = nil
        window.isHidden = true
    }

    func testRefreshLocaleCanChange() {
        CYLRefreshConfig.default.languageCode = "zh-Hans"
        let chinese = Bundle.cylLocalizedString(forKey: CYLRefreshHeaderIdleText)
        CYLRefreshConfig.default.languageCode = "en"
        let english = Bundle.cylLocalizedString(forKey: CYLRefreshHeaderIdleText)
        XCTAssertNotEqual(chinese, english)
        XCTAssertEqual(english, "Pull down to refresh")
        CYLRefreshConfig.default.languageCode = nil
    }

    func testRefreshUnsupportedLocaleFallsBackToEnglish() {
        CYLRefreshConfig.default.languageCode = "zz-XX"
        XCTAssertEqual(Bundle.cylLocalizedString(forKey: CYLRefreshHeaderIdleText), "Pull down to refresh")
        CYLRefreshConfig.default.languageCode = nil
    }

    func testRefreshResourcesLiveInTheSingleLibraryBundle() {
        let bundle: Bundle? = Bundle.cylRefresh()
        XCTAssertNotNil(bundle)
        XCTAssertEqual((bundle?.bundlePath as NSString?)?.lastPathComponent, "CYLTableViewPlaceHolder.bundle")
        // The former separate resource bundle is gone everywhere it used to be copied.
        let container = Bundle(for: CYLRefreshComponent.self)
        XCTAssertNil(container.path(forResource: "CYLRefresh", ofType: "bundle"))
        XCTAssertNil(Bundle.main.path(forResource: "CYLRefresh", ofType: "bundle"))
        XCTAssertNotNil(Bundle.cylArrowImage())
        XCTAssertNotNil(Bundle.cylTrailArrowImage())
        let keys = ["CYLRefreshHeaderIdleText", "CYLRefreshHeaderPullingText",
                    "CYLRefreshHeaderRefreshingText", "CYLRefreshTrailerIdleText", "CYLRefreshTrailerPullingText",
                    "CYLRefreshAutoFooterIdleText", "CYLRefreshAutoFooterRefreshingText", "CYLRefreshAutoFooterNoMoreDataText",
                    "CYLRefreshBackFooterIdleText", "CYLRefreshBackFooterPullingText", "CYLRefreshBackFooterRefreshingText",
                    "CYLRefreshBackFooterNoMoreDataText", "CYLRefreshHeaderLastTimeText", "CYLRefreshHeaderDateTodayText",
                    "CYLRefreshHeaderNoneLastDateText", "CYLRefreshHeaderFinishedText", "CYLRefreshHeaderFailedText",
                    "CYLRefreshFooterFinishedText", "CYLRefreshFooterFailedText"]
        for language in ["en", "zh-Hans", "zh-Hant", "ja", "ko", "ru", "uk"] {
            let path = bundle?.path(forResource: language, ofType: "lproj")
            XCTAssertNotNil(path, "Missing localization \(language)")
            guard let path, let languageBundle = Bundle(path: path) else { continue }
            for key in keys {
                let text = languageBundle.localizedString(forKey: key, value: nil, table: "CYLRefresh")
                XCTAssertNotEqual(text, key, "Missing \(key) in \(language)")
                XCTAssertTrue(text.count > 0)
            }
        }
    }

    func testRefreshTrailerAndJapaneseTextsAreLocalized() {
        defer { CYLRefreshConfig.default.languageCode = nil }
        // Before the bundles were merged, the trailer texts existed only in Chinese.
        CYLRefreshConfig.default.languageCode = "en"
        XCTAssertEqual(Bundle.cylLocalizedString(forKey: CYLRefreshTrailerIdleText), "Swipe to see details")
        CYLRefreshConfig.default.languageCode = "ja-JP"
        XCTAssertEqual(Bundle.cylLocalizedString(forKey: CYLRefreshHeaderIdleText), "下に引っ張って更新")
        CYLRefreshConfig.default.languageCode = "ko"
        XCTAssertEqual(Bundle.cylLocalizedString(forKey: CYLRefreshTrailerPullingText), "놓으면 상세 정보 보기")
    }

    func testLastUpdatedTimeIsLocaleAwareAndComparesWholeDates() {
        let key = "CYLTestLastUpdatedTime"
        let header = CYLRefreshNormalHeader(refreshingBlock: {})
        let calendar = Calendar(identifier: .gregorian)
        defer {
            UserDefaults.standard.removeObject(forKey: key)
            CYLRefreshConfig.default.languageCode = nil
        }
        CYLRefreshConfig.default.languageCode = "en-US"
        UserDefaults.standard.set(Date(), forKey: key)
        header.lastUpdatedTimeKey = key
        let today = header.lastUpdatedTimeLabel.text
        XCTAssertTrue(today?.contains("Today") ?? false, "\(String(describing: today))")

        // A month ago is usually the same day of the month; it used to be shown as "Today".
        let lastMonth = calendar.date(byAdding: .month, value: -1, to: Date())!
        UserDefaults.standard.set(lastMonth, forKey: key)
        header.lastUpdatedTimeKey = key
        let english = header.lastUpdatedTimeLabel.text ?? ""
        XCTAssertFalse(english.contains("Today"), english)
        // en-US uses a 12-hour clock.
        XCTAssertTrue(english.contains("AM") || english.contains("PM"), english)

        // German has no built-in strings (English is used) but its locale formats a 24-hour clock.
        CYLRefreshConfig.default.languageCode = "de-DE"
        header.lastUpdatedTimeKey = key
        let german = header.lastUpdatedTimeLabel.text ?? ""
        XCTAssertTrue(german.hasPrefix("Last update: "), german)
        XCTAssertFalse(german.contains("AM") || german.contains("PM"), german)
    }

    func testMissingRefreshBundleFallsBackWithoutException() {
        let original = class_getClassMethod(Bundle.self, #selector(Bundle.cylRefresh))!
        let missing = class_getClassMethod(Bundle.self, #selector(Bundle.testMissingRefreshBundle))!
        method_exchangeImplementations(original, missing)
        defer {
            method_exchangeImplementations(original, missing)
            CYLRefreshConfig.default.languageCode = nil
        }
        CYLRefreshConfig.default.languageCode = "zz-test-missing"
        // [EN] An Objective-C exception here would end the test run (Swift cannot catch it), which fails as well.
        // [CN] 此处若抛出 Objective-C 异常会终止测试运行（Swift 无法捕获），同样算作失败。
        XCTAssertEqual(Bundle.cylLocalizedString(forKey: CYLRefreshHeaderIdleText, value: "Fallback"), "Fallback")
    }

    func testResetNoMoreDataBeforeBeginningRefresh() {
        let footer: CYLRefreshFooter = CYLRefreshAutoNormalFooter(refreshingBlock: {})
        table.cylFooter = footer
        footer.endRefreshingWithNoMoreData()
        XCTAssertEqual(footer.state, .noMoreData)
        footer.resetNoMoreData()
        footer.beginRefreshing()
        XCTAssertTrue(footer.isRefreshing)
        table.cylFooter = nil
    }

    func testAutoFooterDoesNotTriggerWhileHeaderRefreshes() {
        table.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
        table.contentSize = CGSize(width: 320, height: 390)
        let header: CYLRefreshHeader = CYLRefreshNormalHeader(refreshingBlock: {})
        let footer: CYLRefreshAutoFooter = CYLRefreshAutoNormalFooter(refreshingBlock: {})
        table.cylHeader = header
        table.cylFooter = footer
        header.beginRefreshing()
        table.contentOffset = CGPoint(x: 0, y: -30)
        table.contentOffset = CGPoint(x: 0, y: -20)
        XCTAssertTrue(header.isRefreshing)
        XCTAssertFalse(footer.isRefreshing)
        header.state = .idle
        table.contentOffset = CGPoint(x: 0, y: -30)
        table.contentOffset = CGPoint(x: 0, y: -20)
        XCTAssertTrue(footer.isRefreshing)
        table.cylFooter = nil
        table.cylHeader = nil
    }

    func testScrollMetricsAreStableAndUseOffsetDeltas() {
        let scrollView = UIScrollView()
        scrollView.contentOffset = CGPoint(x: 10, y: -20)
        scrollView.cylUpdateScrollMetrics()
        XCTAssertEqual(scrollView.cylScrollDirection, .none)
        XCTAssertEqual(scrollView.cylScrollDistance, 0)
        let previousY = scrollView.contentOffset.y
        scrollView.contentOffset = CGPoint(x: 10, y: -17.5)
        let expectedDistance = scrollView.contentOffset.y - previousY
        scrollView.cylUpdateScrollMetrics()
        XCTAssertEqual(scrollView.cylScrollDirection, .down)
        XCTAssertEqual(scrollView.cylScrollDistance, expectedDistance, accuracy: 0.001)
        XCTAssertEqual(scrollView.cylScrollDirection, .down)
        scrollView.contentOffset = CGPoint(x: 5, y: -17)
        scrollView.cylUpdateScrollMetrics()
        XCTAssertEqual(scrollView.cylScrollDirection, .left)
        XCTAssertEqual(scrollView.cylScrollDistance, -5, accuracy: 0.001)
        scrollView.cylUpdateScrollMetrics()
        XCTAssertEqual(scrollView.cylScrollDirection, .none)
        XCTAssertEqual(scrollView.cylScrollDistance, 0)
    }

    func testRefreshComponentMovesBetweenScrollAndOrdinaryViews() {
        let component = CYLRefreshComponent()
        let container = UIView()
        // [EN] The Objective-C test wrapped each step in XCTAssertNoThrow; an Objective-C exception now ends the run
        //      (Swift cannot catch it), which fails as well. [CN] Objective-C 测试用 XCTAssertNoThrow 包裹每一步；现在
        //      Objective-C 异常会终止测试运行（Swift 无法捕获），同样算作失败。
        container.addSubview(component)
        component.removeFromSuperview()
        table.addSubview(component)
        XCTAssertIdentical(component.scrollView, table)
        container.addSubview(component)
        XCTAssertNil(component.scrollView)
        component.removeFromSuperview()
        table.addSubview(component)
        component.removeFromSuperview()
    }

    func testRefreshFooterRepeatedlyMovesBetweenContainerAndScrollViews() {
        let footer: CYLRefreshAutoFooter = CYLRefreshAutoNormalFooter(refreshingBlock: {})
        let container = UIView()
        let secondScrollView = UIScrollView(frame: table.frame)
        let initialInset = table.cylInsetB
        for _ in 0..<100 {
            container.addSubview(footer)
            XCTAssertNil(footer.scrollView)
            table.addSubview(footer)
            XCTAssertIdentical(footer.scrollView, table)
            secondScrollView.addSubview(footer)
            XCTAssertEqual(table.cylInsetB, initialInset, accuracy: 0.001)
            footer.removeFromSuperview()
            XCTAssertNil(footer.scrollView)
        }
    }

    // FIX: issue MJRefresh#1630
    // [EN] A controller torn down while its table's header and footer refresh, after the footer moved to another table and
    //      back, 100 times: no "not registered as an observer" exception, and the table, the header and the footer are
    //      released.
    // [CN] 控制器在表格的刷新头和刷新尾正在刷新时销毁（刷新尾先移到另一个表格再移回），重复 100 次：不抛出“未注册为观察者”的异常，
    //      表格、刷新头和刷新尾都被释放。
    func testControllerTeardownWhileRefreshingReleasesWithoutObserverExceptions() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let navigation = UINavigationController(rootViewController: UIViewController())
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        weak var weakTable: UITableView?
        weak var weakHeader: CYLRefreshComponent?
        weak var weakFooter: CYLRefreshComponent?
        for index in 0..<100 {
            autoreleasepool {
                let controller = UIViewController()
                let table = UITableView(frame: controller.view.bounds, style: .plain)
                let other = UITableView(frame: controller.view.bounds, style: .plain)
                controller.view.addSubview(table)
                controller.view.addSubview(other)
                let header: CYLRefreshHeader = CYLRefreshNormalHeader(refreshingBlock: {})
                let footer: CYLRefreshFooter = index % 2 != 0 ? CYLRefreshAutoNormalFooter(refreshingBlock: {})
                                                              : CYLRefreshBackNormalFooter(refreshingBlock: {})
                for component in [header, footer] as [CYLRefreshComponent] {
                    component.fastAnimationDuration = 0
                    component.slowAnimationDuration = 0
                }
                table.cylHeader = header
                table.cylFooter = footer
                navigation.pushViewController(controller, animated: false)
                controller.view.layoutIfNeeded()
                // [EN] An observer exception (XCTAssertNoThrow in the Objective-C test) now ends the run, which fails as well.
                // [CN] 观察者异常（Objective-C 测试中的 XCTAssertNoThrow）现在会终止测试运行，同样算作失败。
                other.addSubview(footer)
                table.addSubview(footer)
                header.beginRefreshing()
                footer.beginRefreshing()
                weakTable = table
                weakHeader = header
                weakFooter = footer
                navigation.popViewController(animated: false)
                table.removeFromSuperview()
            }
            // [EN] Let the queued start, animation and layout work run after the teardown; then the table and header are released.
            // [CN] 让排队的开始、动画与布局任务在销毁后执行；之后表格和刷新头被释放。
            let deadline = Date(timeIntervalSinceNow: CYLTestTimeout)
            while (weakTable != nil || weakHeader != nil || weakFooter != nil) && deadline.timeIntervalSinceNow > 0 {
                RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.01))
            }
            XCTAssertNil(weakTable)
            XCTAssertNil(weakHeader)
            XCTAssertNil(weakFooter, "iteration \(index)")
        }
        window.isHidden = true
    }

    /**
     * [EN] Tears down a controller whose table refreshes with `component` (a footer, a trailer or a header) and waits, at
     *      most CYLTestTimeout, for the table and the component to be released. Returns true when both were released.
     * [CN] 销毁一个控制器，其表格正在用 `component`（刷新尾、trailer 或刷新头）刷新，并最多等待 CYLTestTimeout，直到表格与该控件都被释放。
     *      两者都释放时返回 true。
     */
    private func tearDownWhileRefreshing(_ makeComponent: () -> CYLRefreshComponent,
                                             navigation: UINavigationController,
                                             zeroDurations: Bool) -> Bool {
        weak var weakComponent: CYLRefreshComponent?
        weak var weakTable: UITableView?
        autoreleasepool {
            let controller = UIViewController()
            let table = UITableView(frame: controller.view.bounds, style: .plain)
            let other = UITableView(frame: controller.view.bounds, style: .plain)
            controller.view.addSubview(table)
            controller.view.addSubview(other)
            let component = makeComponent()
            component.refreshingBlock = {}
            let isHeader = component is CYLRefreshHeader
            let header: CYLRefreshHeader = isHeader ? component as! CYLRefreshHeader
                                                    : CYLRefreshNormalHeader(refreshingBlock: {})
            for each in [header, component] where zeroDurations {
                each.fastAnimationDuration = 0
                each.slowAnimationDuration = 0
            }
            table.cylHeader = header
            if let trailer = component as? CYLRefreshTrailer {
                table.cylTrailer = trailer
            } else if let footer = component as? CYLRefreshFooter {
                table.cylFooter = footer
            }
            navigation.pushViewController(controller, animated: false)
            controller.view.layoutIfNeeded()
            if !isHeader {
                other.addSubview(component)
                table.addSubview(component)
            }
            header.beginRefreshing()
            component.beginRefreshing()
            // [EN] Let the refresh start and its animations, timers and display links run. [CN] 让刷新开始，并让其动画、定时器与 display link 运行。
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.3))
            weakComponent = component
            weakTable = table
            navigation.popViewController(animated: false)
            table.removeFromSuperview()
        }
        let deadline = Date(timeIntervalSinceNow: CYLTestTimeout)
        while (weakTable != nil || weakComponent != nil) && deadline.timeIntervalSinceNow > 0 {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.01))
        }
        return weakTable == nil && weakComponent == nil
    }

    // FIX: issue MJRefresh#1630
    // [EN] Every footer kind and both trailers (with icon images where the kind takes them, and a drawn footer hosting the
    //      StoreHouse style, which runs a timer), torn down while refreshing, with zero and with default animation
    //      durations: the table and the footer are released.
    // [CN] 每种刷新尾和两种 trailer（支持图标图片的设置图片，另加一个内嵌 StoreHouse 样式、会运行定时器的手绘刷新尾），在刷新中销毁，动画时长为 0
    //      与默认值各一次：表格和刷新尾都被释放。
    func testEveryFooterKindIsReleasedAfterTeardownWhileRefreshing() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let navigation = UINavigationController(rootViewController: UIViewController())
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        let image = UIImage(systemName: "star")!
        let kinds: [CYLRefreshComponent.Type] = [
            CYLRefreshAutoFooter.self, CYLRefreshAutoStateFooter.self, CYLRefreshAutoNormalFooter.self,
            CYLRefreshAutoAnimationFooter.self, CYLRefreshAutoGifFooter.self,
            CYLRefreshBackFooter.self, CYLRefreshBackStateFooter.self, CYLRefreshBackNormalFooter.self,
            CYLRefreshBackAnimationFooter.self, CYLRefreshBackGifFooter.self,
            CYLRefreshCupertinoFooter.self, CYLRefreshBallPulseFooter.self,
            CYLRefreshBezierRadarFooter.self, CYLRefreshMaterialFooter.self, CYLRefreshDeliveryFooter.self,
            CYLRefreshPhoenixFooter.self, CYLRefreshTaurusFooter.self, CYLRefreshDrawnFooter.self,
            CYLRefreshStateTrailer.self, CYLRefreshNormalTrailer.self,
        ]
        for zero in [true, false] {
            for kind in kinds {
                let released = tearDownWhileRefreshing({
                    if kind === CYLRefreshDrawnFooter.self {
                        return CYLRefreshDrawnFooter(style: CYLRefreshStoreHouseHeader(string: "CYL"))
                    }
                    if kind.isSubclass(of: CYLRefreshTrailer.self) { return CYLMakeRefreshComponent(kind) }
                    let footer = CYLMakeRefreshComponent(kind)
                    if footer.conforms(to: CYLRefreshIconAnimating.self) {
                        footer.setIconImages([image, image], duration: 0.2, for: .idle)
                        footer.setIconImages([image, image], duration: 0.2, for: .refreshing)
                    }
                    return footer
                }, navigation: navigation, zeroDurations: zero)
                XCTAssertTrue(released, "\(NSStringFromClass(kind)) (zero durations: \(NSNumber(value: zero))) is still alive")
            }
        }
        window.isHidden = true
    }

    // [EN] Every header kind torn down while refreshing is released. The StoreHouse header was not: its loading timer was a
    //      target-action NSTimer, which retains the header, and it was invalidated only on a tick after the refresh ended.
    // [CN] 每种刷新头在刷新中销毁后都被释放。StoreHouse 刷新头此前不会：其加载定时器是强持有刷新头的 target-action NSTimer，只在刷新结束后的某次
    //      触发时才失效。
    func testEveryHeaderKindIsReleasedAfterTeardownWhileRefreshing() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let navigation = UINavigationController(rootViewController: UIViewController())
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        let kinds: [CYLRefreshComponent.Type] = [
            CYLRefreshStateHeader.self, CYLRefreshNormalHeader.self, CYLRefreshAnimationHeader.self,
            CYLRefreshGifHeader.self, CYLRefreshCupertinoHeader.self, CYLRefreshBezierCircleHeader.self,
            CYLRefreshBezierRadarHeader.self, CYLRefreshDeliveryHeader.self, CYLRefreshDropBoxHeader.self,
            CYLRefreshFlyHeader.self, CYLRefreshGameBattleCityHeader.self, CYLRefreshGameHitBlockHeader.self,
            CYLRefreshMaterialHeader.self, CYLRefreshOriginalHeader.self, CYLRefreshPhoenixHeader.self,
            CYLRefreshStoreHouseHeader.self, CYLRefreshTaurusHeader.self, CYLRefreshWaveSwipeHeader.self,
        ]
        for kind in kinds {
            let released = tearDownWhileRefreshing({
                if kind === CYLRefreshStoreHouseHeader.self { return CYLRefreshStoreHouseHeader(string: "CYL") }
                return CYLMakeRefreshComponent(kind)
            }, navigation: navigation, zeroDurations: false)
            XCTAssertTrue(released, "\(NSStringFromClass(kind)) is still alive")
        }
        window.isHidden = true
    }

    // [EN] An endless value animator (repeatCount INFINITY) stops once its weak target is released, so its display link and
    //      the animator itself are released instead of ticking for ever.
    // [CN] 无限重复（repeatCount INFINITY）的数值动画器在其弱引用 target 释放后停止，使 display link 与动画器本身被释放，而不是永远空转。
    func testEndlessValueAnimatorStopsWhenItsTargetIsReleased() {
        weak var weakAnimator: CYLRefreshValueAnimator?
        autoreleasepool {
            let target = UIView()
            let animator = CYLRefreshValueAnimator.newWith(target: target, selector: #selector(UIView.setNeedsDisplay as (UIView) -> () -> Void))
            animator.repeatCount = .infinity
            animator.duration = 0.1
            animator.start()
            XCTAssertTrue(animator.isRunning)
            weakAnimator = animator
        }
        let deadline = Date(timeIntervalSinceNow: CYLTestTimeout)
        while weakAnimator != nil && deadline.timeIntervalSinceNow > 0 {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.01))
        }
        XCTAssertNil(weakAnimator)
    }

    // FIX: MJRefresh PR #1444 (device rotation)
    // [EN] The system part of the top inset changes while the header refreshes (a rotation changes the bars' height and the
    //      safe area; here additionalSafeAreaInsets), then the user scrolls and the refresh ends: the header works from the
    //      new system inset, never adds more than its own height, and gives back exactly what it added.
    // [CN] 刷新头刷新期间顶部 inset 的系统部分发生变化（旋转会改变栏高与安全区；这里用 additionalSafeAreaInsets 模拟），随后用户滚动、刷新
    //      结束：刷新头以新的系统 inset 为准，增加的量不超过自身高度，结束时恰好归还所增加的量。
    func testSystemInsetChangeDuringRefreshRestoresTheContentInset() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let controller = UIViewController()
        window.rootViewController = controller
        window.makeKeyAndVisible()
        let table = UITableView(frame: controller.view.bounds, style: .plain)
        table.contentInsetAdjustmentBehavior = .always
        table.contentSize = CGSize(width: 320, height: 2000)
        controller.view.addSubview(table)
        controller.additionalSafeAreaInsets = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
        controller.view.layoutIfNeeded()
        let systemTop = table.adjustedContentInset.top - table.contentInset.top
        let header: CYLRefreshHeader = CYLRefreshNormalHeader(refreshingBlock: {})
        header.fastAnimationDuration = 0
        header.slowAnimationDuration = 0
        table.cylHeader = header
        table.contentOffset = CGPoint(x: 0, y: -table.adjustedContentInset.top)
        header.beginRefreshing()
        var deadline = Date(timeIntervalSinceNow: CYLTestTimeout)
        while header.state != .refreshing && deadline.timeIntervalSinceNow > 0 {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.01))
        }
        XCTAssertEqual(header.state, .refreshing)
        XCTAssertEqual(table.contentInset.top, header.cylH, accuracy: 0.5)

        // [EN] "Rotate": the system inset shrinks from 100 to 30 + the safe area. [CN] “旋转”：系统 inset 从 100 缩小到 30 + 安全区。
        controller.additionalSafeAreaInsets = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
        controller.view.layoutIfNeeded()
        let newSystemTop = table.adjustedContentInset.top - table.contentInset.top
        XCTAssertEqual(systemTop - newSystemTop, 70, accuracy: 0.5)
        // [EN] The user scrolls 20 pt up into the header, then back to the refreshing position.
        // [CN] 用户向上滚入刷新头 20 点，然后回到刷新位置。
        table.contentOffset = CGPoint(x: 0, y: -(newSystemTop + header.cylH) + 20)
        XCTAssertLessThanOrEqual(table.contentInset.top, header.cylH + 0.5, "never more than the header's own height")
        table.contentOffset = CGPoint(x: 0, y: -(newSystemTop + header.cylH))
        XCTAssertEqual(table.contentInset.top, header.cylH, accuracy: 0.5)

        header.endRefreshing()
        deadline = Date(timeIntervalSinceNow: CYLTestTimeout)
        while header.state != .idle && deadline.timeIntervalSinceNow > 0 {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.01))
        }
        XCTAssertEqual(table.contentInset.top, 0, accuracy: 0.5, "the header gives back exactly what it added")
        window.isHidden = true
    }

    // FIX: issue MJRefresh#1483
    // [EN] While the header refreshes, the user drags on to the end and the back footer starts loading too; the header ends
    //      first, then the footer. Both insets come back to what they were (with and without isCollectionViewAnimationBug),
    //      so repeated refreshes do not move the content.
    // [CN] 刷新头刷新期间，用户继续拖到底部，返回式刷新尾也开始加载；刷新头先结束，刷新尾后结束。两个 inset 都恢复原值（开启与关闭
    //      isCollectionViewAnimationBug 都如此），反复刷新不会移动内容。
    func testHeaderEndingWhileTheFooterLoadsRestoresBothInsets() {
        for animationBug in [false, true] {
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
            window.rootViewController = UIViewController()
            window.makeKeyAndVisible()
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: 80, height: 80)
            let collection = UICollectionView(frame: window.bounds, collectionViewLayout: layout)
            collection.contentInsetAdjustmentBehavior = .never
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
            let source = CYLTestCollectionSource()
            collection.dataSource = source
            window.rootViewController!.view.addSubview(collection)
            let header: CYLRefreshHeader = CYLRefreshNormalHeader(refreshingBlock: {})
            header.isCollectionViewAnimationBug = animationBug
            let footer: CYLRefreshBackFooter = CYLRefreshBackNormalFooter(refreshingBlock: {})
            for component in [header, footer] as [CYLRefreshComponent] {
                component.fastAnimationDuration = 0.05
                component.slowAnimationDuration = 0.05
            }
            collection.cylHeader = header
            collection.cylFooter = footer
            collection.layoutIfNeeded()
            let initial = collection.contentInset
            for round in 0..<3 {
                header.beginRefreshing()
                spinUntil { header.state == .refreshing && collection.isUserInteractionEnabled }
                footer.isExclusiveWithOtherRefresh = false
                footer.beginRefreshing()
                spinUntil { footer.state == .refreshing }
                header.endRefreshing()
                spinUntil { header.state == .idle && collection.isUserInteractionEnabled }
                RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.2))
                footer.endRefreshing()
                spinUntil { footer.state == .idle }
                RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.2))
                XCTAssertEqual(collection.contentInset.top, initial.top, accuracy: 0.5, "bug path \(NSNumber(value: animationBug)), round \(round)")
                XCTAssertEqual(collection.contentInset.bottom, initial.bottom, accuracy: 0.5, "bug path \(NSNumber(value: animationBug)), round \(round)")
            }
            window.isHidden = true
        }
    }

    // [EN] The pull is released past the refreshing position, so the header's inset follows the content (resetInset)
    //      before the start animation ends; three refreshes in a row give back exactly the inset they added (with and
    //      without isCollectionViewAnimationBug), so the content does not move (MJRefresh #1483, PR #1444).
    // [CN] 松手位置超过刷新位置，刷新头的 inset 在开始动画结束前就随内容变化（resetInset）；连续三次刷新恰好归还所增加的 inset（开启与关闭
    //      isCollectionViewAnimationBug 都如此），内容不会移动（MJRefresh #1483、PR #1444）。
    func testRefreshReleasedPastTheRefreshingPositionGivesBackItsInset() {
        for animationBug in [false, true] {
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
            window.rootViewController = UIViewController()
            window.makeKeyAndVisible()
            let layout = UICollectionViewFlowLayout()
            let collection = UICollectionView(frame: window.bounds, collectionViewLayout: layout)
            collection.contentInsetAdjustmentBehavior = .never
            collection.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
            let source = CYLTestCollectionSource()
            collection.dataSource = source
            window.rootViewController!.view.addSubview(collection)
            let header: CYLRefreshHeader = CYLRefreshNormalHeader(refreshingBlock: {})
            header.isCollectionViewAnimationBug = animationBug
            header.fastAnimationDuration = 0.1
            header.slowAnimationDuration = 0.1
            collection.cylHeader = header
            collection.layoutIfNeeded()
            for round in 0..<3 {
                collection.contentOffset = CGPoint(x: 0, y: -30 - 90)
                header.beginRefreshing()
                collection.contentOffset = CGPoint(x: 0, y: -30 - 80)
                spinUntil { header.state == .refreshing && collection.isUserInteractionEnabled }
                RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.2))
                XCTAssertEqual(collection.contentInset.top, 30 + header.cylH, accuracy: 0.5, "bug path \(NSNumber(value: animationBug)), round \(round)")
                header.endRefreshing()
                spinUntil { header.state == .idle && collection.isUserInteractionEnabled }
                RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.2))
                XCTAssertEqual(collection.contentInset.top, 30, accuracy: 0.5, "bug path \(NSNumber(value: animationBug)), round \(round)")
            }
            window.isHidden = true
        }
    }

    private func spinUntil(_ condition: () -> Bool) {
        let deadline = Date(timeIntervalSinceNow: CYLTestTimeout)
        while !condition() && deadline.timeIntervalSinceNow > 0 {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.01))
        }
    }

    func testAutoFooterRestoresInsetWhenRemoved() {
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0)
        let initialInset = table.cylInsetB
        table.cylFooter = CYLRefreshAutoNormalFooter(refreshingBlock: {})
        XCTAssertGreaterThan(table.cylInsetB, initialInset)
        table.cylFooter = nil
        XCTAssertEqual(table.cylInsetB, initialInset, accuracy: 0.001)
    }

    func testRemovingActiveTrailerRestoresHorizontalInsetAndBounce() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = UIViewController()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collection = UICollectionView(frame: window.bounds, collectionViewLayout: layout)
        collection.contentInsetAdjustmentBehavior = .never
        collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 17)
        window.rootViewController!.view.addSubview(collection)
        window.makeKeyAndVisible()
        let trailer: CYLRefreshTrailer = CYLRefreshNormalTrailer(refreshingBlock: {})
        trailer.fastAnimationDuration = 0
        trailer.slowAnimationDuration = 0
        collection.cylTrailer = trailer
        trailer.layoutIfNeeded()
        let started = expectation(description: "trailer started")
        trailer.beginRefreshing(completionBlock: { started.fulfill() })
        wait(for: [started], timeout: CYLTestTimeout)
        XCTAssertGreaterThan(collection.cylInsetR, 17)
        collection.cylInsetR += 8
        collection.cylTrailer = nil
        XCTAssertEqual(collection.cylInsetR, 25, accuracy: 0.001)
        XCTAssertEqual(trailer.state, .idle)
        XCTAssertFalse(collection.alwaysBounceHorizontal)
        layout.scrollDirection = .vertical
        collection.cylFooter = CYLRefreshAutoNormalFooter(refreshingBlock: {})
        XCTAssertTrue(collection.alwaysBounceVertical)
        XCTAssertFalse(collection.alwaysBounceHorizontal)
        collection.cylFooter = nil
        window.isHidden = true
    }

    func testTrailerRemovalRestoresPriorBounceWithoutDoubleInsetReset() {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = true
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        let trailer: CYLRefreshTrailer = CYLRefreshNormalTrailer(refreshingBlock: {})
        scrollView.cylTrailer = trailer
        scrollView.cylTrailer = nil
        XCTAssertTrue(scrollView.alwaysBounceHorizontal)
        XCTAssertTrue(scrollView.alwaysBounceVertical)
        XCTAssertEqual(scrollView.cylInsetR, 15, accuracy: 0.001)
        trailer.beginRefreshing()
        XCTAssertEqual(trailer.state, .willRefresh)
        scrollView.cylTrailer = trailer
        scrollView.cylTrailer = nil
        XCTAssertEqual(trailer.state, .idle)
        XCTAssertEqual(scrollView.cylInsetR, 15, accuracy: 0.001)
    }

    func testReparentingActiveTrailerRestoresOldScrollView() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = UIViewController()
        let oldView = UIScrollView(frame: window.bounds)
        let newView = UIScrollView(frame: window.bounds)
        oldView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        newView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 24)
        window.rootViewController!.view.addSubview(oldView)
        window.rootViewController!.view.addSubview(newView)
        window.makeKeyAndVisible()
        let trailer: CYLRefreshTrailer = CYLRefreshNormalTrailer(refreshingBlock: {})
        trailer.fastAnimationDuration = 0
        trailer.slowAnimationDuration = 0
        oldView.addSubview(trailer)
        trailer.layoutIfNeeded()
        let started = expectation(description: "active trailer")
        trailer.beginRefreshing(completionBlock: { started.fulfill() })
        wait(for: [started], timeout: CYLTestTimeout)
        newView.addSubview(trailer)
        XCTAssertEqual(oldView.cylInsetR, 12, accuracy: 0.001)
        XCTAssertEqual(newView.cylInsetR, 24, accuracy: 0.001)
        XCTAssertFalse(oldView.alwaysBounceHorizontal)
        XCTAssertTrue(newView.alwaysBounceHorizontal)
        XCTAssertEqual(trailer.state, .idle)
        trailer.removeFromSuperview()
        XCTAssertFalse(newView.alwaysBounceHorizontal)
        window.isHidden = true
    }

    func testCollectionContentSizeAfterRemovingTrailerAndChangingDirection() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = UIViewController()
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.scrollDirection = .horizontal
        let collection = UICollectionView(frame: window.bounds, collectionViewLayout: layout)
        collection.contentInsetAdjustmentBehavior = .never
        let source = CYLTestCollectionSource()
        collection.dataSource = source
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        window.rootViewController!.view.addSubview(collection)
        window.makeKeyAndVisible()
        collection.reloadData()
        collection.layoutIfNeeded()
        XCTAssertGreaterThan(collection.contentSize.width, collection.bounds.size.width)
        let trailer: CYLRefreshTrailer = CYLRefreshNormalTrailer(refreshingBlock: {})
        trailer.fastAnimationDuration = 0
        trailer.slowAnimationDuration = 0
        collection.cylTrailer = trailer
        trailer.layoutIfNeeded()
        let started = expectation(description: "collection trailer started")
        trailer.beginRefreshing(completionBlock: { started.fulfill() })
        wait(for: [started], timeout: CYLTestTimeout)
        collection.cylTrailer = nil
        layout.scrollDirection = .vertical
        layout.invalidateLayout()
        collection.cylFooter = CYLRefreshAutoNormalFooter(refreshingBlock: {})
        collection.layoutIfNeeded()
        XCTAssertEqual(collection.contentSize.width, collection.bounds.size.width, accuracy: 0.001)
        XCTAssertEqual(collection.cylInsetR, 0, accuracy: 0.001)
        XCTAssertFalse(collection.alwaysBounceHorizontal)
        XCTAssertGreaterThan(collection.contentSize.height, collection.bounds.size.height)
        collection.cylFooter = nil
        window.isHidden = true
    }

    func testRemovingTrailerAfterEndingDoesNotRestoreInsetTwice() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = UIViewController()
        let scrollView = UIScrollView(frame: window.bounds)
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 18)
        window.rootViewController!.view.addSubview(scrollView)
        window.makeKeyAndVisible()
        let trailer: CYLRefreshTrailer = CYLRefreshNormalTrailer(refreshingBlock: {})
        trailer.fastAnimationDuration = 0
        trailer.slowAnimationDuration = 0
        scrollView.cylTrailer = trailer
        trailer.layoutIfNeeded()
        let started = expectation(description: "trailer began")
        trailer.beginRefreshing(completionBlock: { started.fulfill() })
        wait(for: [started], timeout: CYLTestTimeout)
        let ended = expectation(description: "trailer ended")
        trailer.endRefreshing(completionBlock: { ended.fulfill() })
        wait(for: [ended], timeout: CYLTestTimeout)
        XCTAssertEqual(scrollView.cylInsetR, 18, accuracy: 0.001)
        scrollView.cylTrailer = nil
        XCTAssertEqual(scrollView.cylInsetR, 18, accuracy: 0.001)
        window.isHidden = true
    }

    private func wideScrollView(in window: UIWindow, contentWidth: CGFloat) -> UIScrollView {
        window.rootViewController = UIViewController()
        let scrollView = UIScrollView(frame: window.bounds)
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentSize = CGSize(width: contentWidth, height: window.bounds.size.height)
        window.rootViewController!.view.addSubview(scrollView)
        window.makeKeyAndVisible()
        return scrollView
    }

    func testTrailerRefreshesAutomaticallyAtTheEndWhenEnabled() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let scrollView = wideScrollView(in: window, contentWidth: 1000)
        let refreshed = expectation(description: "automatic trailer refresh")
        var callbacks = 0
        let trailer: CYLRefreshTrailer = CYLRefreshNormalTrailer(refreshingBlock: {
            callbacks += 1
            refreshed.fulfill()
        })
        trailer.fastAnimationDuration = 0
        trailer.slowAnimationDuration = 0
        XCTAssertFalse(trailer.isAutomaticallyRefresh)
        XCTAssertEqual(trailer.triggerAutomaticallyRefreshPercent, 1.0, accuracy: 0.001)
        XCTAssertEqual(trailer.autoTriggerTimes, 1)
        trailer.isAutomaticallyRefresh = true
        trailer.triggerAutomaticallyRefreshPercent = 0.5
        scrollView.cylTrailer = trailer
        trailer.layoutIfNeeded()
        // The end of the content is at 680; half of the 60 pt trailer is 30 pt.
        scrollView.contentOffset = CGPoint(x: 700, y: 0)
        XCTAssertEqual(trailer.state, .idle)
        scrollView.contentOffset = CGPoint(x: 711, y: 0)
        wait(for: [refreshed], timeout: CYLTestTimeout)
        XCTAssertEqual(trailer.state, .refreshing)
        XCTAssertEqual(callbacks, 1)
        let ended = expectation(description: "automatic trailer ended")
        trailer.endRefreshing(completionBlock: { ended.fulfill() })
        wait(for: [ended], timeout: CYLTestTimeout)
        XCTAssertEqual(scrollView.cylInsetR, 0, accuracy: 0.001)
        XCTAssertEqual(callbacks, 1)
        scrollView.cylTrailer = nil
        window.isHidden = true
    }

    // FIX: issue MJRefresh#1623
    // [EN] autoTriggerTimes: one drag triggers the automatic trailer once (default 1); moving back and forth in the same
    //      drag does not load again, and the next drag (pan began) may trigger once more.
    // [CN] autoTriggerTimes：一次拖动只自动触发一次 trailer（默认 1）；同一次拖动中来回移动不会再次加载，下一次拖动（手势开始）可以再触发一次。
    func testAutomaticTrailerTriggersOncePerDrag() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = UIViewController()
        let scrollView = CYLTestDraggingScrollView(frame: window.bounds)
        let pan = CYLTestPanGestureRecognizer()
        scrollView.testPan = pan
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentSize = CGSize(width: 1000, height: window.bounds.size.height)
        window.rootViewController!.view.addSubview(scrollView)
        window.makeKeyAndVisible()
        var callbacks = 0
        var refreshed: XCTestExpectation?
        let trailer: CYLRefreshTrailer = CYLRefreshNormalTrailer(refreshingBlock: {
            callbacks += 1
            refreshed?.fulfill()
        })
        trailer.fastAnimationDuration = 0
        trailer.slowAnimationDuration = 0
        trailer.isAutomaticallyRefresh = true
        trailer.triggerAutomaticallyRefreshPercent = 0.5
        scrollView.cylTrailer = trailer
        trailer.layoutIfNeeded()

        for drag in 1...2 {
            // [EN] A new drag begins. [CN] 新的一次拖动开始。
            pan.testState = .began
            trailer.scrollViewPanStateDidChange(nil)
            scrollView.testDragging = true
            scrollView.contentOffset = CGPoint(x: 690, y: 0)
            let expectation = expectation(description: "automatic trailer refresh")
            refreshed = expectation
            scrollView.contentOffset = CGPoint(x: 711, y: 0)
            XCTAssertEqual(trailer.state, .refreshing)
            wait(for: [expectation], timeout: CYLTestTimeout)
            refreshed = nil
            let ended = self.expectation(description: "automatic trailer ended")
            trailer.endRefreshing(completionBlock: { ended.fulfill() })
            wait(for: [ended], timeout: CYLTestTimeout)
            XCTAssertEqual(callbacks, drag)

            // [EN] Back and forth in the same drag: no second load. [CN] 同一次拖动中来回移动：不再加载。
            scrollView.contentOffset = CGPoint(x: 690, y: 0)
            scrollView.contentOffset = CGPoint(x: 711, y: 0)
            XCTAssertNotEqual(trailer.state, .refreshing)
            XCTAssertEqual(callbacks, drag)

            // [EN] The drag ends back inside the content. [CN] 拖动在内容范围内结束。
            scrollView.contentOffset = CGPoint(x: 600, y: 0)
            scrollView.testDragging = false
            pan.testState = .ended
            trailer.scrollViewPanStateDidChange(nil)
        }
        scrollView.cylTrailer = nil
        window.isHidden = true
    }

    // CoderMJLee/MJRefresh#1587: pull-down refresh and pull-up load exclude each other when asked to.
    func testHeaderAndFooterExcludeEachOtherWhenEnabled() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = UIViewController()
        window.rootViewController!.view.addSubview(table)
        window.makeKeyAndVisible()
        var headerCalls = 0, footerCalls = 0, blocked = 0
        let header: CYLRefreshHeader = CYLRefreshNormalHeader(refreshingBlock: { headerCalls += 1 })
        let footer: CYLRefreshFooter = CYLRefreshBackNormalFooter(refreshingBlock: { footerCalls += 1 })
        for component in [header, footer] as [CYLRefreshComponent] {
            component.fastAnimationDuration = 0
            component.slowAnimationDuration = 0
            component.isExclusiveWithOtherRefresh = true
            component.blockedByOtherRefreshBlock = { blocked += 1 }
        }
        table.cylHeader = header
        table.cylFooter = footer

        // The header refreshes: loading more is held back and reported.
        let headerStarted = expectation(description: "header started")
        header.refreshingBlock = { headerCalls += 1; headerStarted.fulfill() }
        header.beginRefreshing()
        wait(for: [headerStarted], timeout: CYLTestTimeout)
        footer.state = .pulling
        footer.beginRefreshing()
        XCTAssertEqual(footer.state, .idle, "the held-back pull is dropped, not left on 'release to load'")
        XCTAssertEqual(footerCalls, 0)
        XCTAssertEqual(blocked, 1)
        XCTAssertTrue(header.isRefreshing)

        // After the header ends, loading more works; now the header is held back.
        let headerEnded = expectation(description: "header ended")
        header.endRefreshing(completionBlock: { headerEnded.fulfill() })
        wait(for: [headerEnded], timeout: CYLTestTimeout)
        let footerStarted = expectation(description: "footer started")
        footer.refreshingBlock = { footerCalls += 1; footerStarted.fulfill() }
        footer.beginRefreshing()
        wait(for: [footerStarted], timeout: CYLTestTimeout)
        XCTAssertEqual(footerCalls, 1)
        let headerCallsBefore = headerCalls
        header.beginRefreshing()
        XCTAssertFalse(header.isRefreshing)
        XCTAssertEqual(headerCalls, headerCallsBefore)
        XCTAssertEqual(blocked, 2)

        let footerEnded = expectation(description: "footer ended")
        footer.endRefreshing(completionBlock: { footerEnded.fulfill() })
        wait(for: [footerEnded], timeout: CYLTestTimeout)
        table.cylHeader = nil
        table.cylFooter = nil
        window.isHidden = true
    }

    func testHeaderAndFooterRunIndependentlyByDefault() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = UIViewController()
        window.rootViewController!.view.addSubview(table)
        window.makeKeyAndVisible()
        XCTAssertFalse(CYLRefreshNormalHeader().isExclusiveWithOtherRefresh)
        var footerCalls = 0
        let header: CYLRefreshHeader = CYLRefreshNormalHeader(refreshingBlock: {})
        let footer: CYLRefreshFooter = CYLRefreshBackNormalFooter(refreshingBlock: { footerCalls += 1 })
        footer.fastAnimationDuration = 0
        header.fastAnimationDuration = footer.fastAnimationDuration
        table.cylHeader = header
        table.cylFooter = footer
        header.beginRefreshing()
        footer.beginRefreshing()
        XCTAssertTrue(header.isRefreshing)
        XCTAssertTrue(footer.isRefreshing, "unchanged default: the footer starts while the header refreshes")
        table.cylHeader = nil
        table.cylFooter = nil
        window.isHidden = true
    }

    func testTrailerKeepsPullAndReleaseBehaviorByDefault() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let scrollView = wideScrollView(in: window, contentWidth: 1000)
        var callbacks = 0
        let trailer: CYLRefreshTrailer = CYLRefreshNormalTrailer(refreshingBlock: { callbacks += 1 })
        trailer.fastAnimationDuration = 0
        trailer.slowAnimationDuration = 0
        scrollView.cylTrailer = trailer
        trailer.layoutIfNeeded()
        scrollView.contentOffset = CGPoint(x: 760, y: 0)
        let nextTurn = expectation(description: "no automatic refresh")
        DispatchQueue.main.async { nextTurn.fulfill() }
        wait(for: [nextTurn], timeout: CYLTestTimeout)
        XCTAssertEqual(trailer.state, .idle)
        XCTAssertEqual(callbacks, 0)
        scrollView.cylTrailer = nil
        window.isHidden = true
    }

    func testAutomaticTrailerIgnoresBounceBackShortContentAndActiveHeader() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let scrollView = wideScrollView(in: window, contentWidth: 1000)
        let trailer: CYLRefreshTrailer = CYLRefreshNormalTrailer(refreshingBlock: {})
        trailer.fastAnimationDuration = 0
        trailer.slowAnimationDuration = 0
        scrollView.cylTrailer = trailer
        trailer.layoutIfNeeded()
        // Moving back toward the start must not trigger, even past the threshold.
        scrollView.contentOffset = CGPoint(x: 780, y: 0)
        trailer.isAutomaticallyRefresh = true
        scrollView.contentOffset = CGPoint(x: 770, y: 0)
        XCTAssertEqual(trailer.state, .idle)
        // While the header refreshes, the trailer waits.
        let header = CYLRefreshNormalHeader(refreshingBlock: {})
        scrollView.cylHeader = header
        header.beginRefreshing()
        scrollView.contentOffset = CGPoint(x: 790, y: 0)
        XCTAssertEqual(trailer.state, .idle)
        header.endRefreshing()
        scrollView.cylHeader = nil
        // Content narrower than the view keeps pull-and-release.
        scrollView.contentOffset = .zero
        scrollView.contentSize = CGSize(width: 200, height: 480)
        scrollView.contentOffset = CGPoint(x: 80, y: 0)
        XCTAssertEqual(trailer.state, .idle)
        scrollView.cylTrailer = nil
        window.isHidden = true
    }

    func testReusingTrailerDuringStartAnimationDoesNotRunOldRefreshCallback() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = UIViewController()
        let oldView = UIScrollView(frame: window.bounds)
        let newView = UIScrollView(frame: window.bounds)
        window.rootViewController!.view.addSubview(oldView)
        window.rootViewController!.view.addSubview(newView)
        window.makeKeyAndVisible()
        var callbacks = 0
        let newRefresh = expectation(description: "new start animation finished")
        let trailer: CYLRefreshTrailer = CYLRefreshNormalTrailer(refreshingBlock: {
            callbacks += 1
            if callbacks == 1 { newRefresh.fulfill() }
        })
        trailer.fastAnimationDuration = 0.5
        trailer.slowAnimationDuration = 0.2
        oldView.addSubview(trailer)
        trailer.layoutIfNeeded()
        trailer.beginRefreshing()
        XCTAssertEqual(trailer.state, .refreshing)
        newView.addSubview(trailer)
        trailer.layoutIfNeeded()
        trailer.beginRefreshing()
        // Wait for the new refresh's callback itself rather than a fixed delay, which slow CI runners miss.
        wait(for: [newRefresh], timeout: CYLTestTimeout)
        // The old animation finishes no later than the new one; give a stale callback time to show up.
        let settled = expectation(description: "no stale callback")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            settled.fulfill()
        }
        wait(for: [settled], timeout: CYLTestTimeout)
        XCTAssertEqual(callbacks, 1)
        trailer.removeFromSuperview()
        window.isHidden = true
    }

    func testRemovingTrailerDuringStartCancelsStartCallbacksButCompletesEnding() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = UIViewController()
        let scrollView = UIScrollView(frame: window.bounds)
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 19)
        window.rootViewController!.view.addSubview(scrollView)
        window.makeKeyAndVisible()
        var refreshCallbacks = 0
        var beginCallbacks = 0
        let trailer: CYLRefreshTrailer = CYLRefreshNormalTrailer(refreshingBlock: { refreshCallbacks += 1 })
        trailer.fastAnimationDuration = 0.5
        trailer.slowAnimationDuration = 0.2
        scrollView.cylTrailer = trailer
        trailer.layoutIfNeeded()
        let ended = expectation(description: "detached refresh ended")
        trailer.endRefreshingCompletionBlock = { ended.fulfill() }
        trailer.beginRefreshing(completionBlock: { beginCallbacks += 1 })
        scrollView.cylTrailer = nil
        XCTAssertEqual(scrollView.cylInsetR, 19, accuracy: 0.001)
        let startAnimationFinished = expectation(description: "cancelled start animation finished")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            startAnimationFinished.fulfill()
        }
        wait(for: [ended, startAnimationFinished], timeout: CYLTestTimeout)
        XCTAssertEqual(refreshCallbacks, 0)
        XCTAssertEqual(beginCallbacks, 0)
        window.isHidden = true
    }

    func testOldTrailerEndAnimationDoesNotResetNewRefreshProgress() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = UIViewController()
        let scrollView = UIScrollView(frame: window.bounds)
        window.rootViewController!.view.addSubview(scrollView)
        window.makeKeyAndVisible()
        let trailer: CYLRefreshTrailer = CYLRefreshNormalTrailer(refreshingBlock: {})
        trailer.fastAnimationDuration = 0
        trailer.slowAnimationDuration = 0.5
        scrollView.cylTrailer = trailer
        trailer.layoutIfNeeded()
        let started = expectation(description: "first refresh started")
        trailer.beginRefreshing(completionBlock: { started.fulfill() })
        wait(for: [started], timeout: CYLTestTimeout)
        let ended = expectation(description: "first refresh ended")
        trailer.endRefreshing(completionBlock: { ended.fulfill() })
        trailer.beginRefreshingCompletionBlock = nil
        trailer.beginRefreshing()
        wait(for: [ended], timeout: CYLTestTimeout)
        XCTAssertTrue(trailer.isRefreshing)
        XCTAssertEqual(trailer.pullingPercent, 1, accuracy: 0.001)
        trailer.endRefreshingCompletionBlock = nil
        scrollView.cylTrailer = nil
        window.isHidden = true
    }

    func testOverlappingTrailerEndsCallTheirOwnCompletions() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = UIViewController()
        let scrollView = UIScrollView(frame: window.bounds)
        window.rootViewController!.view.addSubview(scrollView)
        window.makeKeyAndVisible()
        let trailer: CYLRefreshTrailer = CYLRefreshNormalTrailer(refreshingBlock: {})
        trailer.fastAnimationDuration = 0
        trailer.slowAnimationDuration = 0.5
        scrollView.cylTrailer = trailer
        trailer.layoutIfNeeded()
        var firstEnds = 0
        var secondEnds = 0
        let firstEnded = expectation(description: "first end completion")
        let secondEnded = expectation(description: "second end completion")
        trailer.beginRefreshing()
        trailer.endRefreshing(completionBlock: { firstEnds += 1; if firstEnds == 1 { firstEnded.fulfill() } })
        trailer.beginRefreshing()
        trailer.endRefreshing(completionBlock: { secondEnds += 1; if secondEnds == 1 { secondEnded.fulfill() } })
        // Wait for both completions themselves, then allow time for a duplicate call to show up.
        wait(for: [firstEnded, secondEnded], timeout: CYLTestTimeout)
        let settled = expectation(description: "no duplicate completion")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            settled.fulfill()
        }
        wait(for: [settled], timeout: CYLTestTimeout)
        XCTAssertEqual(firstEnds, 1)
        XCTAssertEqual(secondEnds, 1)
        scrollView.cylTrailer = nil
        window.isHidden = true
    }

    func testAutoFooterPanEndToleratesFloatingPointRounding() {
        let scrollView = CYLTestScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let pan = CYLTestPanGestureRecognizer()
        scrollView.testPan = pan
        pan.testState = .ended
        scrollView.contentSize = CGSize(width: 320, height: 1800)
        let footer: CYLRefreshAutoFooter = CYLRefreshAutoNormalFooter(refreshingBlock: {})
        scrollView.cylFooter = footer
        let threshold = scrollView.cylContentH + scrollView.cylInsetB - scrollView.cylH

        scrollView.testOffset = CGPoint(x: 0, y: threshold - 0.01)
        footer.scrollViewPanStateDidChange(nil)
        XCTAssertFalse(footer.isRefreshing)

        scrollView.testOffset = CGPoint(x: 0, y: threshold - 1e-11)
        footer.scrollViewPanStateDidChange(nil)
        XCTAssertTrue(footer.isRefreshing)
        footer.state = .idle
        pan.testState = .began
        footer.scrollViewPanStateDidChange(nil)
        pan.testState = .ended
        scrollView.testOffset = CGPoint(x: 0, y: threshold)
        footer.scrollViewPanStateDidChange(nil)
        XCTAssertTrue(footer.isRefreshing)
        scrollView.cylFooter = nil
    }

    func testPagingAutoFooterAcceptsReportedFloatingPointValues() {
        let scrollView = CYLTestScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let pan = CYLTestPanGestureRecognizer()
        scrollView.testPan = pan
        pan.testState = .ended
        scrollView.isPagingEnabled = true
        let footer: CYLRefreshAutoFooter = CYLRefreshAutoNormalFooter(refreshingBlock: {})
        scrollView.cylFooter = footer

        let reportedThreshold: CGFloat = 1367.666666666698
        let reportedOffset: CGFloat = 1367.666666666687
        scrollView.contentSize = CGSize(width: 320, height: reportedThreshold + scrollView.cylH - scrollView.cylInsetB)
        let actualThreshold = scrollView.cylContentH + scrollView.cylInsetB - scrollView.cylH
        XCTAssertEqual(actualThreshold, reportedThreshold, accuracy: 1e-12)
        XCTAssertLessThan(reportedOffset, actualThreshold)
        scrollView.testOffset = CGPoint(x: 0, y: reportedOffset)
        footer.scrollViewPanStateDidChange(nil)
        XCTAssertTrue(footer.isRefreshing)
        scrollView.cylFooter = nil
    }

    func testPagingAutoFooterEndPreservesValidAndInteractiveOffsets() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = UIViewController()
        let scrollView = CYLTestPagingScrollView(frame: window.bounds)
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        scrollView.contentSize = CGSize(width: 320, height: 960)
        scrollView.isPagingEnabled = true
        window.rootViewController!.view.addSubview(scrollView)
        window.makeKeyAndVisible()
        let footer: CYLRefreshAutoFooter = CYLRefreshAutoNormalFooter(refreshingBlock: {})
        footer.fastAnimationDuration = 0
        footer.slowAnimationDuration = 0
        scrollView.cylFooter = footer

        footer.beginRefreshing()
        scrollView.contentOffset = CGPoint(x: 0, y: 480)
        footer.endRefreshing()
        XCTAssertEqual(scrollView.contentOffset.y, 480, accuracy: 0.001)

        footer.beginRefreshing()
        scrollView.contentOffset = CGPoint(x: 0, y: 550)
        footer.endRefreshing()
        XCTAssertEqual(scrollView.contentOffset.y, 510, accuracy: 0.001)

        footer.beginRefreshing()
        scrollView.contentOffset = CGPoint(x: 0, y: 550)
        scrollView.testDragging = true
        footer.endRefreshing()
        XCTAssertEqual(scrollView.contentOffset.y, 550, accuracy: 0.001)
        scrollView.testDragging = false

        footer.beginRefreshing()
        scrollView.contentOffset = CGPoint(x: 0, y: 550)
        scrollView.testDecelerating = true
        footer.endRefreshing()
        XCTAssertEqual(scrollView.contentOffset.y, 550, accuracy: 0.001)
        scrollView.testDecelerating = false

        scrollView.cylFooter = nil
        window.isHidden = true
    }

    // FIX: issue MJRefresh#1610 (page alignment)
    // [EN] A paging auto footer starts loading with its space showing past the last page; the load adds a page. When it
    //      ends at rest, the scroll view goes back to the page boundary instead of keeping the page shifted by the
    //      footer's height (an Example-objc-02 UI test drives the same case with real swipes).
    // [CN] 分页的自动刷新尾在最后一页之后露出自身空间时开始加载，加载新增一页。静止时结束，滚动视图回到分页边界，而不是让该页错开刷新尾的高度
    //      （Example-objc-02 的 UI 测试以真实滑动覆盖同一场景）。
    func testPagingAutoFooterEndAfterNewPageReturnsToThePageBoundary() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = UIViewController()
        let scrollView = CYLTestPagingScrollView(frame: window.bounds)
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentSize = CGSize(width: 320, height: 960)
        scrollView.isPagingEnabled = true
        window.rootViewController!.view.addSubview(scrollView)
        window.makeKeyAndVisible()
        let footer: CYLRefreshAutoFooter = CYLRefreshAutoNormalFooter(refreshingBlock: {})
        footer.fastAnimationDuration = 0
        footer.slowAnimationDuration = 0
        scrollView.cylFooter = footer
        footer.beginRefreshing()
        scrollView.contentOffset = CGPoint(x: 0, y: 480 + footer.cylH)
        scrollView.contentSize = CGSize(width: 320, height: 1440)
        footer.endRefreshing()
        XCTAssertEqual(scrollView.contentOffset.y, 480, accuracy: 0.001)
        scrollView.cylFooter = nil
        window.isHidden = true
    }

    // CoderMJLee/MJRefresh#1585 (case 2): keep "no more data" visible for a while after the last load, then rebound.
    private func scrollViewAtBottomWithBackFooter(in window: UIWindow) -> (UIScrollView, CYLRefreshBackFooter) {
        window.rootViewController = UIViewController()
        let scrollView = UIScrollView(frame: window.bounds)
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentSize = CGSize(width: 320, height: 1440)
        window.rootViewController!.view.addSubview(scrollView)
        window.makeKeyAndVisible()
        let footer: CYLRefreshBackFooter = CYLRefreshBackNormalFooter(refreshingBlock: {})
        footer.fastAnimationDuration = 0
        footer.slowAnimationDuration = 0
        scrollView.cylFooter = footer
        scrollView.contentOffset = CGPoint(x: 0, y: 960)
        let started = expectation(description: "back footer started")
        footer.beginRefreshing(completionBlock: { started.fulfill() })
        wait(for: [started], timeout: CYLTestTimeout)
        // The block stays attached and would fulfill the finished expectation again on every later start.
        footer.beginRefreshingCompletionBlock = nil
        return (scrollView, footer)
    }

    func testBackFooterHoldsNoMoreDataForTheConfiguredDuration() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let (scrollView, footer) = scrollViewAtBottomWithBackFooter(in: window)
        footer.noMoreDataDisplayDuration = 0.6
        let refreshingInset = scrollView.cylInsetB
        XCTAssertGreaterThan(refreshingInset, 0)
        let began = CACurrentMediaTime()
        footer.endRefreshingWithNoMoreData()
        XCTAssertEqual(footer.state, .noMoreData)
        XCTAssertEqual(scrollView.cylInsetB, refreshingInset, accuracy: 0.01, "the footer stays held open")
        expectation(for: NSPredicate { _, _ in
            abs(scrollView.cylInsetB) < 0.01
        }, evaluatedWith: scrollView, handler: nil)
        waitForExpectations(timeout: CYLTestTimeout, handler: nil)
        XCTAssertGreaterThanOrEqual(CACurrentMediaTime() - began, 0.5, "released only after the configured time")
        XCTAssertEqual(footer.state, .noMoreData, "the state itself is unchanged")
        scrollView.cylFooter = nil
        window.isHidden = true
    }

    func testBackFooterNoMoreDataReboundsAtOnceByDefault() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let (scrollView, footer) = scrollViewAtBottomWithBackFooter(in: window)
        XCTAssertEqual(footer.noMoreDataDisplayDuration, 0, accuracy: 0.0001)
        footer.endRefreshingWithNoMoreData()
        XCTAssertEqual(scrollView.cylInsetB, 0, accuracy: 0.01, "unchanged default")
        scrollView.cylFooter = nil
        window.isHidden = true
    }

    func testBackFooterNoMoreDataHoldEndsOnResetNewLoadAndRemoval() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let (scrollView, footer) = scrollViewAtBottomWithBackFooter(in: window)
        footer.noMoreDataDisplayDuration = 60
        footer.endRefreshingWithNoMoreData()
        XCTAssertGreaterThan(scrollView.cylInsetB, 0)
        footer.resetNoMoreData()
        XCTAssertEqual(footer.state, .idle)
        XCTAssertEqual(scrollView.cylInsetB, 0, accuracy: 0.01, "reset gives the held inset back")

        // A new load after the hold: the inset is neither lost nor doubled.
        footer.beginRefreshing()
        let refreshingInset = scrollView.cylInsetB
        footer.endRefreshingWithNoMoreData()
        XCTAssertEqual(scrollView.cylInsetB, refreshingInset, accuracy: 0.01)
        footer.beginRefreshing()
        XCTAssertEqual(footer.state, .refreshing)
        XCTAssertEqual(scrollView.cylInsetB, refreshingInset, accuracy: 0.01, "one footer height, not two")
        footer.endRefreshing()
        XCTAssertEqual(scrollView.cylInsetB, 0, accuracy: 0.01)

        footer.beginRefreshing()
        footer.endRefreshingWithNoMoreData()
        XCTAssertGreaterThan(scrollView.cylInsetB, 0)
        scrollView.cylFooter = nil
        XCTAssertEqual(scrollView.cylInsetB, 0, accuracy: 0.01, "removing the footer gives the held inset back")
        window.isHidden = true
    }

    func testPagingBackFooterReturnsToLastPageAfterRefresh() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = UIViewController()
        let scrollView = CYLTestPagingScrollView(frame: window.bounds)
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentSize = CGSize(width: 320, height: 1440)
        scrollView.isPagingEnabled = true
        window.rootViewController!.view.addSubview(scrollView)
        window.makeKeyAndVisible()
        let footer: CYLRefreshBackFooter = CYLRefreshBackNormalFooter(refreshingBlock: {})
        footer.fastAnimationDuration = 0
        footer.slowAnimationDuration = 0
        scrollView.cylFooter = footer
        scrollView.contentOffset = CGPoint(x: 0, y: 960)
        let started = expectation(description: "paging back footer started")
        footer.beginRefreshing(completionBlock: { started.fulfill() })
        wait(for: [started], timeout: CYLTestTimeout)
        XCTAssertGreaterThan(scrollView.contentOffset.y, 960)
        let ended = expectation(description: "paging back footer ended")
        footer.endRefreshing(completionBlock: { ended.fulfill() })
        wait(for: [ended], timeout: CYLTestTimeout)
        XCTAssertEqual(scrollView.contentOffset.y, 960, accuracy: 0.01)
        scrollView.cylFooter = nil
        window.isHidden = true
    }

    func testPagingBackFooterPreservesPreviousPageWhenContentGrows() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = UIViewController()
        let scrollView = CYLTestPagingScrollView(frame: window.bounds)
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentSize = CGSize(width: 320, height: 1440)
        scrollView.isPagingEnabled = true
        window.rootViewController!.view.addSubview(scrollView)
        window.makeKeyAndVisible()
        let footer: CYLRefreshBackFooter = CYLRefreshBackNormalFooter(refreshingBlock: {})
        footer.fastAnimationDuration = 0
        footer.slowAnimationDuration = 0
        scrollView.cylFooter = footer
        scrollView.contentOffset = CGPoint(x: 0, y: 960)
        let started = expectation(description: "paging back footer started")
        footer.beginRefreshing(completionBlock: { started.fulfill() })
        wait(for: [started], timeout: CYLTestTimeout)
        scrollView.contentSize = CGSize(width: 320, height: 1920)
        let ended = expectation(description: "paging back footer ended")
        footer.endRefreshing(completionBlock: { ended.fulfill() })
        wait(for: [ended], timeout: CYLTestTimeout)
        XCTAssertEqual(scrollView.contentOffset.y, 960, accuracy: 0.01)
        scrollView.cylFooter = nil
        window.isHidden = true
    }

    func testPagingBackFooterReturnsToItsPageWhenLeftBetweenPages() {
        // MJRefresh #1430: UIKit's paging deceleration left the table about 0.22 of a page off the page boundary after the
        // footer's refresh, so the restore (which needed the refresh's exact offset) was skipped.
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = UIViewController()
        let scrollView = CYLTestPagingScrollView(frame: window.bounds)
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentSize = CGSize(width: 320, height: 1440)
        scrollView.isPagingEnabled = true
        window.rootViewController!.view.addSubview(scrollView)
        window.makeKeyAndVisible()
        let footer: CYLRefreshBackFooter = CYLRefreshBackNormalFooter(refreshingBlock: {})
        footer.fastAnimationDuration = 0
        footer.slowAnimationDuration = 0
        scrollView.cylFooter = footer
        scrollView.contentOffset = CGPoint(x: 0, y: 960)
        let started = expectation(description: "paging back footer started")
        footer.beginRefreshing(completionBlock: { started.fulfill() })
        wait(for: [started], timeout: CYLTestTimeout)
        scrollView.contentSize = CGSize(width: 320, height: 1920)
        scrollView.contentOffset = CGPoint(x: 0, y: 960 - 0.22 * 480)
        let ended = expectation(description: "paging back footer ended")
        footer.endRefreshing(completionBlock: { ended.fulfill() })
        wait(for: [ended], timeout: CYLTestTimeout)
        XCTAssertEqual(scrollView.contentOffset.y, 960, accuracy: 0.01, "back on the page shown before the refresh")
        scrollView.cylFooter = nil
        window.isHidden = true
    }

    func testPagingBackFooterDoesNotOverrideCallerOrActiveScrolling() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = UIViewController()
        let scrollView = CYLTestPagingScrollView(frame: window.bounds)
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentSize = CGSize(width: 320, height: 1440)
        scrollView.isPagingEnabled = true
        window.rootViewController!.view.addSubview(scrollView)
        window.makeKeyAndVisible()
        let footer: CYLRefreshBackFooter = CYLRefreshBackNormalFooter(refreshingBlock: {})
        footer.fastAnimationDuration = 0
        footer.slowAnimationDuration = 0
        scrollView.cylFooter = footer
        for scenario in 0..<3 {
            scrollView.testDragging = false
            scrollView.testDecelerating = false
            scrollView.contentSize = CGSize(width: 320, height: 1440)
            scrollView.contentOffset = CGPoint(x: 0, y: 960)
            let started = expectation(description: "paging footer started")
            footer.beginRefreshing(completionBlock: { started.fulfill() })
            wait(for: [started], timeout: CYLTestTimeout)
            scrollView.contentSize = CGSize(width: 320, height: 1920)
            if scenario == 0 { scrollView.contentOffset = CGPoint(x: 0, y: 1440) }
            if scenario == 1 { scrollView.testDragging = true }
            if scenario == 2 { scrollView.testDecelerating = true }
            let expectedOffset = scrollView.contentOffset.y
            let ended = expectation(description: "paging footer ended")
            footer.endRefreshing(completionBlock: { ended.fulfill() })
            wait(for: [ended], timeout: CYLTestTimeout)
            XCTAssertEqual(scrollView.contentOffset.y, expectedOffset, accuracy: 0.01)
        }
        scrollView.cylFooter = nil
        window.isHidden = true
    }

    func testEndRefreshingDoesNotOverrideImmediateStateChange() {
        let footer: CYLRefreshFooter = CYLRefreshAutoNormalFooter(refreshingBlock: {})
        table.cylFooter = footer
        footer.beginRefreshing()
        footer.endRefreshing()
        footer.state = .noMoreData
        let nextTurn = expectation(description: "main queue turn")
        DispatchQueue.main.async { nextTurn.fulfill() }
        wait(for: [nextTurn], timeout: CYLTestTimeout)
        XCTAssertEqual(footer.state, .noMoreData)
        table.cylFooter = nil
    }
}
