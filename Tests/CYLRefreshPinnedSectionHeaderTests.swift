import XCTest
import UIKit

// FIX: issue #1627 / #1507
// [EN] A plain table pins its section header; a back footer that starts or ends loading must not show it above the top.
// [CN] plain 表格固定 section header；back footer 开始或结束加载时不能让它露出顶部之外。
final class CYLRefreshPinnedSectionHeaderTests: XCTestCase, UITableViewDataSource, UITableViewDelegate,
    UICollectionViewDataSource {
    private var count = 4

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: "c") ?? UITableViewCell(style: .default, reuseIdentifier: "c")
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        tableView.dequeueReusableHeaderFooterView(withIdentifier: "h") ?? UITableViewHeaderFooterView(reuseIdentifier: "h")
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: "c", for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "h", for: indexPath)
    }

    private func spin(_ seconds: TimeInterval) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    // [EN] The largest distance between the pinned header and the visible top while the animation runs, as drawn.
    // [CN] 动画期间（按屏幕绘制）固定 header 与可见顶边的最大距离。
    private func largestHeaderGap(of table: UITableView, for seconds: TimeInterval) -> CGFloat {
        largestHeaderGap(of: table, for: seconds) { table.headerView(forSection: 0) }
    }

    private func largestHeaderGap(of scrollView: UIScrollView, for seconds: TimeInterval,
                                  header headerView: () -> UIView?) -> CGFloat {
        var gap: CGFloat = 0
        let start = Date()
        while Date().timeIntervalSince(start) < seconds {
            spin(0.016)
            guard let header = headerView(),
                  let headerY = header.layer.presentation()?.frame.minY,
                  let top = scrollView.layer.presentation()?.bounds.minY else { continue }
            gap = max(gap, abs(headerY - top))
        }
        return gap
    }

    func testBackFooterKeepsThePinnedSectionHeaderAtTheTopWhenLoadingStartsAndEnds() {
        // The table of MJRefresh #1627: rows of 150, a section header of 100, no automatic insets.
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        let controller = UIViewController()
        window.rootViewController = controller
        window.isHidden = false
        let table = UITableView(frame: CGRect(x: 0, y: 64, width: 375, height: 603), style: .plain)
        table.contentInsetAdjustmentBehavior = .never
        table.dataSource = self
        table.delegate = self
        table.rowHeight = 150
        table.sectionHeaderHeight = 100
        if #available(iOS 15.0, *) { table.sectionHeaderTopPadding = 0 }
        var completions = 0
        let footer = CYLRefreshBackNormalFooter(refreshingBlock: {})
        footer.endRefreshingCompletionBlock = { completions += 1 }
        table.cylFooter = footer
        controller.view.addSubview(table)
        table.layoutIfNeeded()
        let maxOffset = table.contentSize.height - table.bounds.height

        // Released past the footer: loading starts and the offset moves back onto the footer.
        table.contentOffset = CGPoint(x: 0, y: maxOffset + 60)
        table.layoutIfNeeded()
        footer.state = .refreshing
        XCTAssertLessThan(largestHeaderGap(of: table, for: 0.5), 1, "the header stays pinned when loading starts")
        XCTAssertEqual(table.contentOffset.y, maxOffset + footer.frame.height, accuracy: 0.5)
        XCTAssertEqual(table.contentInset.bottom, footer.frame.height, accuracy: 0.5)

        // The order of the issue: one more row, endRefreshing, reloadData. The smaller inset pulls the offset back.
        count = 5
        footer.endRefreshing()
        table.reloadData()
        XCTAssertEqual(table.contentInset.bottom, 0, accuracy: 0.5, "the inset is given back at once")
        XCTAssertLessThan(largestHeaderGap(of: table, for: 0.7), 1, "the header stays pinned when loading ends")
        XCTAssertEqual(table.contentOffset.y, maxOffset, accuracy: 0.5)
        XCTAssertEqual(completions, 1, "the end completion runs once")
    }

    func testBackFooterKeepsAPinnedFlowLayoutHeaderAtTheTopWhenLoadingStartsAndEnds() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        let controller = UIViewController()
        window.rootViewController = controller
        window.isHidden = false
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 375, height: 150)
        layout.minimumLineSpacing = 0
        layout.headerReferenceSize = CGSize(width: 375, height: 100)
        layout.sectionHeadersPinToVisibleBounds = true
        let collection = UICollectionView(frame: CGRect(x: 0, y: 64, width: 375, height: 603), collectionViewLayout: layout)
        collection.contentInsetAdjustmentBehavior = .never
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "c")
        collection.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                            withReuseIdentifier: "h")
        collection.dataSource = self
        let footer = CYLRefreshBackNormalFooter(refreshingBlock: {})
        collection.cylFooter = footer
        controller.view.addSubview(collection)
        collection.layoutIfNeeded()
        let header = { collection.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader,
                                                    at: IndexPath(item: 0, section: 0)) }
        XCTAssertNotNil(header())
        let maxOffset = collection.contentSize.height - collection.bounds.height

        collection.contentOffset = CGPoint(x: 0, y: maxOffset + 60)
        collection.layoutIfNeeded()
        footer.state = .refreshing
        XCTAssertLessThan(largestHeaderGap(of: collection, for: 0.5, header: header), 1, "pinned when loading starts")

        count = 5
        footer.endRefreshing()
        collection.reloadData()
        XCTAssertLessThan(largestHeaderGap(of: collection, for: 0.7, header: header), 1, "pinned when loading ends")
        XCTAssertEqual(collection.contentInset.bottom, 0, accuracy: 0.5)
    }

    // FIX: issue MJRefresh#1568
    // [EN] A collection view's background view stays in place while the header starts and ends refreshing.
    // [CN] 刷新头开始和结束刷新时，collection view 的背景视图保持不动。
    func testHeaderKeepsTheCollectionBackgroundViewInPlaceWhenRefreshingStartsAndEnds() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        let controller = UIViewController()
        window.rootViewController = controller
        window.isHidden = false
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 375, height: 80)
        let collection = UICollectionView(frame: window.bounds, collectionViewLayout: layout)
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "c")
        collection.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                            withReuseIdentifier: "h")
        count = 20
        collection.dataSource = self
        collection.contentInsetAdjustmentBehavior = .never
        let background = UIView()
        collection.backgroundView = background
        controller.view.addSubview(collection)
        var completions = 0
        let header = CYLRefreshNormalHeader(refreshingBlock: {})
        header.endRefreshingCompletionBlock = { completions += 1 }
        collection.cylHeader = header
        collection.layoutIfNeeded()
        collection.contentOffset.y = -120
        collection.layoutIfNeeded()
        header.state = .refreshing
        XCTAssertLessThan(largestHeaderGap(of: collection, for: 0.5) { background }, 1, "in place when refreshing starts")
        XCTAssertEqual(collection.contentOffset.y, -header.frame.height, accuracy: 0.5)
        header.endRefreshing()
        XCTAssertLessThan(largestHeaderGap(of: collection, for: 0.8) { background }, 1, "in place when refreshing ends")
        XCTAssertEqual(collection.contentOffset.y, 0, accuracy: 0.5)
        XCTAssertEqual(collection.contentInset.top, 0, accuracy: 0.5)
        XCTAssertEqual(completions, 1)
    }
}
