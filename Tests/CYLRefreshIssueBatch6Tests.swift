import XCTest
import UIKit

// [EN] Regression tests for MJRefresh #1067, #1029, #920 and #862 (docs/issue-progress.md).
// [CN] MJRefresh #1067、#1029、#920、#862 的回归测试（docs/issue-progress.md）。
final class CYLRefreshIssueBatch6Tests: XCTestCase, UITableViewDataSource, UICollectionViewDataSource {
    private var rows = 30

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { UITableViewCell() }

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { rows }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: "c", for: indexPath)
    }

    private func spin(_ seconds: TimeInterval) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    // [EN] The offsets drawn on each frame for the given time. [CN] 给定时长内每帧绘制的 offset。
    private func drawnOffsets(of scrollView: UIScrollView, for seconds: TimeInterval) -> [CGFloat] {
        var offsets: [CGFloat] = []
        let start = Date()
        while Date().timeIntervalSince(start) < seconds {
            spin(0.016)
            offsets.append(scrollView.layer.presentation()?.bounds.minY ?? scrollView.bounds.minY)
        }
        return offsets
    }

    // [EN] True when the values move one way only. [CN] 数值只朝一个方向变化时为 true。
    private func isMonotonic(_ values: [CGFloat]) -> Bool {
        let steps = zip(values.dropFirst(), values).map { $0 - $1 }.filter { abs($0) > 0.01 }
        return steps.allSatisfy { $0 > 0 } || steps.allSatisfy { $0 < 0 }
    }

    // FIX: issue MJRefresh#1067
    // [EN] A collection view with its own content and section insets moves one way, without a jolt, into refreshing and
    //      back, and keeps its own top inset.
    // [CN] 自带 content inset 与 section inset 的 collection view 进入刷新和返回时只朝一个方向移动、没有抖动，并保留自己的顶部 inset。
    func testCollectionWithContentInsetsMovesSmoothlyIntoAndOutOfRefreshing() {
        for withBackground in [false, true] {
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
            let controller = UIViewController()
            window.rootViewController = controller
            window.isHidden = false
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: 100, height: 100)
            layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
            let collection = UICollectionView(frame: window.bounds, collectionViewLayout: layout)
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "c")
            collection.contentInsetAdjustmentBehavior = .never
            collection.contentInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
            if withBackground { collection.backgroundView = UIView() }
            collection.dataSource = self
            controller.view.addSubview(collection)
            let header = CYLRefreshNormalHeader(refreshingBlock: {})
            collection.cylHeader = header
            collection.layoutIfNeeded()
            collection.contentOffset.y = -20 - 90
            collection.layoutIfNeeded()
            header.state = .refreshing
            let start = drawnOffsets(of: collection, for: 0.5)
            XCTAssertTrue(isMonotonic(start), "background \(withBackground): one way into refreshing \(start)")
            XCTAssertEqual(collection.contentOffset.y, -20 - header.frame.height, accuracy: 0.5)
            header.endRefreshing()
            let end = drawnOffsets(of: collection, for: 0.8)
            XCTAssertTrue(isMonotonic(end), "background \(withBackground): one way back \(end)")
            XCTAssertEqual(collection.contentOffset.y, -20, accuracy: 0.5)
            XCTAssertEqual(collection.contentInset.top, 20, accuracy: 0.5, "its own top inset is kept")
            window.isHidden = true
        }
    }

    // FIX: issue MJRefresh#1029
    // [EN] Under a large-title navigation bar, refreshing starts and ends without looping and the table returns to the
    //      automatic top inset.
    // [CN] 大标题导航栏下，刷新开始与结束不会死循环，表格回到自动计算的顶部 inset。
    func testLargeTitleNavigationBarRefreshesAndRestoresTheTop() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
        let controller = UIViewController()
        controller.title = "Large"
        let navigation = UINavigationController(rootViewController: controller)
        navigation.navigationBar.prefersLargeTitles = true
        controller.navigationItem.largeTitleDisplayMode = .always
        window.rootViewController = navigation
        window.isHidden = false
        let table = UITableView(frame: controller.view.bounds, style: .plain)
        table.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        table.dataSource = self
        controller.view.addSubview(table)
        var refreshes = 0
        let header = CYLRefreshNormalHeader { refreshes += 1 }
        table.cylHeader = header
        spin(0.3)
        let restingTop = table.adjustedContentInset.top
        XCTAssertGreaterThan(restingTop, 0)
        table.contentOffset.y = -restingTop - 90
        table.layoutIfNeeded()
        header.state = .refreshing
        spin(0.6)
        XCTAssertEqual(refreshes, 1)
        header.endRefreshing()
        spin(0.8)
        XCTAssertEqual(header.state, .idle)
        XCTAssertEqual(table.contentInset.top, 0, accuracy: 0.5, "no inset of the header is left")
        XCTAssertEqual(table.contentOffset.y, -table.adjustedContentInset.top, accuracy: 0.5, "back at the resting top")
        window.isHidden = true
    }

    // FIX: issue MJRefresh#920
    // [EN] UIKit lays the section index out inside the content insets, so the header's refreshing inset moves it by that
    //      inset (the issue's jump). The front scroll mode adds no inset, and the index stays where it is.
    // [CN] UIKit 在 content inset 之内布局 section index，因此刷新头的刷新 inset 会让它移动同样的距离（即 issue 中的跳动）。前置
    //      滚动模式不加 inset，index 保持不动。
    func testSectionIndexMovesWithTheRefreshingInsetAndStaysInFrontMode() {
        let headerHeight = sectionIndexShift(front: false)
        XCTAssertEqual(headerHeight.shift, headerHeight.inset, accuracy: 1, "default: the index moves by the inset")
        XCTAssertLessThan(sectionIndexShift(front: true).shift, 1, "front mode: the index stays")
    }

    // [EN] The largest on-screen move of the section index while the header refreshes, and the inset it added.
    // [CN] 刷新头刷新期间 section index 在屏幕上的最大移动距离，以及刷新头加的 inset。
    private func sectionIndexShift(front: Bool) -> (shift: CGFloat, inset: CGFloat) {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        defer { window.isHidden = true }
        let controller = UIViewController()
        window.rootViewController = controller
        window.isHidden = false
        let source = CYLBatch6IndexedSource()
        let table = UITableView(frame: window.bounds, style: .plain)
        table.contentInsetAdjustmentBehavior = .never
        table.dataSource = source
        controller.view.addSubview(table)
        let header = CYLRefreshNormalHeader(refreshingBlock: {})
        if front { header.scrollMode = .front }
        table.cylHeader = header
        table.layoutIfNeeded()
        guard let index = table.subviews.first(where: { String(describing: type(of: $0)).contains("Index") }) else {
            XCTFail("no section index view")
            return (0, 0)
        }
        let resting = index.frame.minY - table.bounds.minY
        var largest: CGFloat = 0
        var inset: CGFloat = 0
        let sample = { (seconds: TimeInterval) in
            let start = Date()
            while Date().timeIntervalSince(start) < seconds {
                self.spin(0.016)
                let frame = (index.layer.presentation() ?? index.layer).frame
                let top = (table.layer.presentation() ?? table.layer).bounds.minY
                largest = max(largest, abs(frame.minY - top - resting))
                inset = max(inset, table.contentInset.top)
            }
        }
        table.contentOffset.y = -90
        table.layoutIfNeeded()
        header.state = .refreshing
        sample(0.5)
        header.endRefreshing()
        sample(0.8)
        return (largest, inset)
    }

    // FIX: issue MJRefresh#862
    // [EN] beginRefreshing in viewDidLoad: the pushed screen starts at the refreshing position instead of moving there
    //      during the push.
    // [CN] 在 viewDidLoad 中 beginRefreshing：被 push 的页面直接从刷新位置开始，而不是在 push 期间移动过去。
    func testRefreshBegunInViewDidLoadStartsInPlaceDuringThePush() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        let navigation = UINavigationController(rootViewController: UIViewController())
        window.rootViewController = navigation
        window.isHidden = false
        spin(0.2)
        let pushed = CYLBatch6RefreshingController()
        navigation.pushViewController(pushed, animated: true)
        let table = pushed.table
        var offsets: [CGFloat] = []
        let start = Date()
        while Date().timeIntervalSince(start) < 0.6 {
            spin(0.016)
            if pushed.header.state == .refreshing {
                offsets.append(table.layer.presentation()?.bounds.minY ?? table.bounds.minY)
            }
        }
        XCTAssertEqual(pushed.header.state, .refreshing)
        XCTAssertFalse(offsets.isEmpty)
        let target = -table.adjustedContentInset.top
        XCTAssertEqual(offsets.first ?? 0, target, accuracy: 0.5, "the first drawn frame is already in place \(offsets.prefix(5))")
        XCTAssertEqual(table.contentOffset.y, target, accuracy: 0.5)
        XCTAssertEqual(pushed.refreshes, 1, "the refreshing block still runs")
        window.isHidden = true
    }
}

// [EN] A table source with a section index. [CN] 带 section index 的表格数据源。
private final class CYLBatch6IndexedSource: NSObject, UITableViewDataSource {
    let titles = (65...90).map { String(UnicodeScalar(UInt8($0))) }

    func numberOfSections(in tableView: UITableView) -> Int { titles.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 3 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { UITableViewCell() }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { titles[section] }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? { titles }
}

// [EN] A screen that begins refreshing in viewDidLoad. [CN] 在 viewDidLoad 中开始刷新的页面。
private final class CYLBatch6RefreshingController: UIViewController, UITableViewDataSource {
    let table = UITableView(frame: .zero, style: .plain)
    var refreshes = 0
    lazy var header = CYLRefreshNormalHeader { [weak self] in self?.refreshes += 1 }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        table.frame = view.bounds
        table.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        table.dataSource = self
        view.addSubview(table)
        table.cylHeader = header
        header.beginRefreshing()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 30 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { UITableViewCell() }
}
