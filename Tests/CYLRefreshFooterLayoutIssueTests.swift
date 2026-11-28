import XCTest
import UIKit

// [EN] Regression tests for MJRefresh #1583, #1595 and #1591 (docs/issue-progress.md).
// [CN] MJRefresh #1583、#1595、#1591 的回归测试（docs/issue-progress.md）。
final class CYLRefreshFooterLayoutIssueTests: XCTestCase, UICollectionViewDataSource, UITableViewDataSource,
    UITableViewDelegate {
    private var items = 12
    private var rows = 0

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { items }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: "c", for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "h", for: indexPath)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { UITableViewCell() }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { tableView.bounds.height }

    private func spin(_ seconds: TimeInterval) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    // FIX: issue MJRefresh#1583
    // [EN] An empty table with automatic insets and a bottom safe area places its back footer in the bottom band, where
    //      nothing covers it. autoHideRefresh (on by default on iOS 26 and later) masks it there; without it, it shows.
    // [CN] 自动 inset 且有底部安全区的空表格把 back footer 放在底部条带中，那里没有遮挡。autoHideRefresh（iOS 26 及以后默认开启）在
    //      此处遮住它；关闭时它会露出。
    func testEmptyTableBackFooterInTheBottomSafeAreaIsMaskedByAutoHide() {
        for autoHide in [true, false] {
            rows = 0
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
            let controller = UIViewController()
            window.rootViewController = controller
            window.makeKeyAndVisible()
            controller.additionalSafeAreaInsets = UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0)
            let table = UITableView(frame: controller.view.bounds, style: .plain)
            table.dataSource = self
            controller.view.addSubview(table)
            let footer = CYLRefreshBackNormalFooter(refreshingBlock: {})
            table.cylFooter = footer
            table.cylAutoHideRefreshFooter = autoHide
            table.reloadData()
            spin(0.3)
            table.layoutIfNeeded()
            let visibleBottom = table.contentOffset.y + table.bounds.height
            XCTAssertLessThan(footer.frame.minY, visibleBottom, "the footer lies in the visible bottom band")
            XCTAssertEqual(footer.layer.mask != nil, autoHide, "masked exactly when autoHideRefresh is on")
            window.isHidden = true
        }
    }

    // FIX: issue MJRefresh#1595
    // [EN] A flow layout that pins its section headers keeps the header visible at the top through a whole load more, with
    //      an auto footer and with a back footer (the back footer's offset moves frame by frame since #1627).
    // [CN] 固定 section header 的 flow layout 在整个加载更多过程中保持 header 显示在顶部：auto footer 与 back footer 都是（#1627 起
    //      back footer 的 offset 逐帧移动）。
    func testPinnedFlowLayoutHeaderStaysVisibleThroughLoadMore() {
        for back in [false, true] {
            items = 12
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
            let controller = UIViewController()
            window.rootViewController = controller
            window.isHidden = false
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: 375, height: 100)
            layout.headerReferenceSize = CGSize(width: 375, height: 50)
            layout.sectionHeadersPinToVisibleBounds = true
            let collection = UICollectionView(frame: window.bounds, collectionViewLayout: layout)
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "c")
            collection.register(UICollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "h")
            collection.dataSource = self
            collection.contentInsetAdjustmentBehavior = .never
            controller.view.addSubview(collection)
            let footer: CYLRefreshFooter = back ? CYLRefreshBackNormalFooter(refreshingBlock: {})
                : CYLRefreshAutoNormalFooter(refreshingBlock: {})
            collection.cylFooter = footer
            collection.layoutIfNeeded()
            collection.contentOffset.y = collection.contentSize.height - collection.bounds.height + (back ? 60 : 0)
            collection.layoutIfNeeded()
            footer.beginRefreshing()
            spin(0.5)
            items += 12
            collection.reloadData()
            footer.endRefreshing()
            let start = Date()
            while Date().timeIntervalSince(start) < 0.8 {
                spin(0.03)
                let header = collection.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader,
                                                          at: IndexPath(item: 0, section: 0))
                XCTAssertNotNil(header, "the pinned header exists")
                guard let header = header else { break }
                XCTAssertFalse(header.isHidden)
                let gap = (header.layer.presentation()?.frame.minY ?? 0) - (collection.layer.presentation()?.bounds.minY ?? 0)
                XCTAssertLessThan(abs(gap), 1, "back=\(back): the header stays at the top")
            }
            window.isHidden = true
        }
    }

    // FIX: issue MJRefresh#1591
    // [EN] A paging table whose rows fill a page ends a back footer load on a whole page, not shifted by the pull.
    // [CN] 每行占满一页的分页表格，back footer 加载结束后停在整页上，不会偏移下拉的距离。
    func testPagingTableEndsBackFooterLoadOnAWholePage() {
        rows = 3
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        let controller = UIViewController()
        window.rootViewController = controller
        window.isHidden = false
        let table = UITableView(frame: window.bounds, style: .plain)
        table.isPagingEnabled = true
        table.estimatedRowHeight = 0
        table.contentInsetAdjustmentBehavior = .never
        table.dataSource = self
        table.delegate = self
        controller.view.addSubview(table)
        let footer = CYLRefreshBackNormalFooter(refreshingBlock: {})
        table.cylFooter = footer
        table.layoutIfNeeded()
        let page = table.bounds.height
        table.contentOffset.y = page * 2 + 60
        table.layoutIfNeeded()
        footer.state = .refreshing
        spin(0.5)
        rows = 5
        table.reloadData()
        footer.endRefreshing()
        spin(0.8)
        let position = table.contentOffset.y / page
        XCTAssertEqual(position, position.rounded(), accuracy: 0.001, "rests on a whole page (offset \(table.contentOffset.y))")
        XCTAssertEqual(table.contentInset.bottom, 0, accuracy: 0.5)
    }
}
