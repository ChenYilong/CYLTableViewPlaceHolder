import XCTest
import UIKit

// [EN] A table that can claim a finger is down, so a test can drag past the back footer and release it.
// [CN] 可以声称手指按下的表格，使测试能拖过 back footer 再松手。
private final class CYLBatch5DraggingTable: UITableView {
    var fakeDragging = false

    override var isDragging: Bool { fakeDragging || super.isDragging }
}

// [EN] Regression tests for MJRefresh #1564, #1540, #1535, #1238 and #1146 (docs/issue-progress.md).
// [CN] MJRefresh #1564、#1540、#1535、#1238、#1146 的回归测试（docs/issue-progress.md）。
final class CYLRefreshIssueBatch5Tests: XCTestCase, UITableViewDataSource, UITableViewDelegate,
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var rows = 20
    private var fullPageRows = false
    private var selfSizing = false

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        if selfSizing {
            cell.textLabel?.numberOfLines = 0
            cell.detailTextLabel?.numberOfLines = 0
            cell.textLabel?.text = String(repeating: "Row \(indexPath.row) title ", count: 1 + indexPath.row % 4)
            cell.detailTextLabel?.text = String(repeating: "detail text that wraps ", count: 2 + indexPath.row % 5)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if fullPageRows { return tableView.bounds.height }
        return selfSizing ? UITableView.automaticDimension : 60
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { 44 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { rows }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: "c", for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize { collectionView.bounds.size }

    private func spin(_ seconds: TimeInterval) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func makeWindow(_ size: CGSize = CGSize(width: 375, height: 667)) -> (UIWindow, UIViewController) {
        let window = UIWindow(frame: CGRect(origin: .zero, size: size))
        let controller = UIViewController()
        window.rootViewController = controller
        window.isHidden = false
        return (window, controller)
    }

    // FIX: issue MJRefresh#1564
    // [EN] The header ends refreshing while its table is off screen (the user switched pages mid-request); back on
    //      screen the inset and offset are restored and the completion ran once.
    // [CN] 表格不在屏幕上时（请求中途切换了页面）刷新头结束刷新；回到屏幕后 inset 和 offset 已复原，完成回调只执行一次。
    func testHeaderEndingOffScreenRestoresTheInsetWhenTheTableComesBack() {
        let (window, controller) = makeWindow()
        let table = UITableView(frame: window.bounds, style: .plain)
        table.contentInsetAdjustmentBehavior = .never
        table.dataSource = self
        table.delegate = self
        controller.view.addSubview(table)
        var completions = 0
        let header = CYLRefreshNormalHeader(refreshingBlock: {})
        header.endRefreshingCompletionBlock = { completions += 1 }
        table.cylHeader = header
        table.layoutIfNeeded()
        for endsDuringTheStartMove in [false, true] {
            table.contentOffset.y = -120
            table.layoutIfNeeded()
            header.state = .refreshing
            spin(endsDuringTheStartMove ? 0.05 : 0.5)
            table.removeFromSuperview()
            header.endRefreshing()
            spin(0.8)
            controller.view.addSubview(table)
            table.layoutIfNeeded()
            spin(0.1)
            XCTAssertEqual(header.state, .idle)
            XCTAssertEqual(table.contentInset.top, 0, accuracy: 0.5, "inset restored (ends mid-move: \(endsDuringTheStartMove))")
            XCTAssertEqual(table.contentOffset.y, 0, accuracy: 0.5, "back at the top (ends mid-move: \(endsDuringTheStartMove))")
        }
        XCTAssertEqual(completions, 2)
        window.isHidden = true
    }

    // FIX: issue MJRefresh#1540
    // [EN] A full-screen paging collection ends a back footer load on a whole page, however far it was pulled.
    // [CN] 全屏分页 collection 无论上拉多远，back footer 加载结束后都停在整页上。
    func testPagingCollectionEndsBackFooterLoadOnAWholePage() {
        for pull in [60.0, 160.0] as [CGFloat] {
            rows = 3
            let (window, controller) = makeWindow()
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 0
            let collection = UICollectionView(frame: window.bounds, collectionViewLayout: layout)
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "c")
            collection.isPagingEnabled = true
            collection.contentInsetAdjustmentBehavior = .never
            collection.dataSource = self
            collection.delegate = self
            controller.view.addSubview(collection)
            let footer = CYLRefreshBackStateFooter(refreshingBlock: {})
            collection.cylFooter = footer
            collection.layoutIfNeeded()
            let page = collection.bounds.height
            collection.contentOffset.y = page * 2 + pull
            collection.layoutIfNeeded()
            footer.state = .refreshing
            spin(0.5)
            rows = 5
            collection.reloadData()
            footer.endRefreshing()
            spin(0.8)
            let position = collection.contentOffset.y / page
            XCTAssertEqual(position, position.rounded(), accuracy: 0.001,
                           "pull \(pull): rests on a whole page (offset \(collection.contentOffset.y))")
            XCTAssertEqual(collection.contentInset.bottom, 0, accuracy: 0.5)
            window.isHidden = true
        }
    }

    // FIX: issue MJRefresh#1535
    // [EN] Full-screen rows (one video per page) start loading when released past the back footer, on the screen sizes
    //      of the iPhone 6s, iPhone 11 and iPhone 15, with and without paging.
    // [CN] 整屏行（每页一个视频）在 iPhone 6s、iPhone 11、iPhone 15 的屏幕尺寸上，无论是否分页，越过 back footer 松手都会开始加载。
    func testFullScreenRowsStartLoadingWhenReleasedPastTheBackFooterOnEveryScreenSize() {
        fullPageRows = true
        defer { fullPageRows = false }
        let sizes = [CGSize(width: 375, height: 667 - 49), CGSize(width: 414, height: 896 - 83),
                     CGSize(width: 393, height: 852 - 83)]
        for size in sizes {
            for paging in [false, true] {
                rows = 5
                let (window, controller) = makeWindow(size)
                let table = CYLBatch5DraggingTable(frame: window.bounds, style: .plain)
                table.isPagingEnabled = paging
                table.estimatedRowHeight = 0
                table.separatorStyle = .none
                table.contentInsetAdjustmentBehavior = .never
                table.dataSource = self
                table.delegate = self
                controller.view.addSubview(table)
                var loads = 0
                let footer = CYLRefreshBackNormalFooter { loads += 1 }
                table.cylFooter = footer
                table.layoutIfNeeded()
                let maxOffset = table.contentSize.height - table.bounds.height
                table.fakeDragging = true
                table.contentOffset.y = maxOffset + footer.frame.height + 10
                XCTAssertEqual(footer.state, .pulling, "\(size) paging \(paging): pulling")
                table.fakeDragging = false
                table.contentOffset.y = maxOffset + footer.frame.height + 9
                spin(0.5)
                XCTAssertEqual(footer.state, .refreshing, "\(size) paging \(paging): refreshing")
                XCTAssertEqual(loads, 1, "\(size) paging \(paging): the block ran")
                window.isHidden = true
            }
        }
    }

    // FIX: issue MJRefresh#1238
    // [EN] A UISearchController's bar as the table header does not hide the refresh header or the back footer.
    // [CN] 以 UISearchController 的搜索栏作为表头时，刷新头和 back footer 不会被遮住。
    func testSearchBarTableHeaderLeavesTheRefreshViewsVisible() {
        rows = 20
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        let controller = UIViewController()
        window.rootViewController = UINavigationController(rootViewController: controller)
        window.isHidden = false
        let search = UISearchController(searchResultsController: nil)
        let table = UITableView(frame: controller.view.bounds, style: .plain)
        table.dataSource = self
        table.delegate = self
        table.tableHeaderView = search.searchBar
        search.searchBar.sizeToFit()
        controller.view.addSubview(table)
        let header = CYLRefreshNormalHeader(refreshingBlock: {})
        let footer = CYLRefreshBackNormalFooter(refreshingBlock: {})
        table.cylHeader = header
        table.cylFooter = footer
        table.layoutIfNeeded()
        let top = table.adjustedContentInset.top
        table.contentOffset.y = -top - header.frame.height
        table.layoutIfNeeded()
        spin(0.1)
        XCTAssertFalse(header.isHidden)
        XCTAssertEqual(header.alpha, 1, accuracy: 0.01)
        XCTAssertLessThanOrEqual(header.frame.maxY, search.searchBar.frame.minY + 0.5, "the bar sits below the header")
        let visible = table.bounds
        XCTAssertTrue(visible.contains(CGPoint(x: header.frame.midX, y: header.frame.midY)), "the header is on screen")
        let hit = table.hitTest(CGPoint(x: header.frame.midX, y: header.frame.midY), with: nil)
        XCTAssertTrue(hit === header || hit?.isDescendant(of: header) == true || hit === table,
                      "nothing covers the header (hit \(String(describing: hit)))")
        window.isHidden = true
    }

    // FIX: issue MJRefresh#1146
    // [EN] Self-sizing rows with a poor estimate: when loading ends with new rows, the read row stays where reloadData left
    //      it, in a plain table (offset driver) and a grouped one (animated inset).
    // [CN] 预估值偏差较大的自适应行高：加载出新行并结束时，正在看的行停在 reloadData 后的位置，plain 表格（offset driver）与 grouped
    //      表格（动画 inset）均如此。
    func testSelfSizingRowsKeepTheReadRowInPlaceWhenLoadingEnds() {
        selfSizing = true
        defer { selfSizing = false }
        for style in [UITableView.Style.plain, .grouped] {
            let withoutFooter = readRowShift(footer: false, style: style)
            let withFooter = readRowShift(footer: true, style: style)
            XCTAssertEqual(withFooter, withoutFooter, accuracy: 1,
                           "style \(style.rawValue): the read row stays where reloadData leaves it (\(withFooter) vs \(withoutFooter))")
        }
    }

    // [EN] How far the last old row moves on screen when 20 rows are added and loading ends.
    // [CN] 追加 20 行并结束加载时，原最后一行在屏幕上移动的距离。
    private func readRowShift(footer usesFooter: Bool, style: UITableView.Style = .plain) -> CGFloat {
        rows = 20
        let (window, controller) = makeWindow()
        defer { window.isHidden = true }
        let table = UITableView(frame: window.bounds, style: style)
        table.contentInsetAdjustmentBehavior = .never
        table.dataSource = self
        table.delegate = self
        controller.view.addSubview(table)
        let footer = CYLRefreshBackNormalFooter(refreshingBlock: {})
        if usesFooter { table.cylFooter = footer }
        table.layoutIfNeeded()
        // Scroll through every row once so each is measured, then rest at the end.
        var y: CGFloat = 0
        while y < table.contentSize.height {
            table.contentOffset.y = y
            table.layoutIfNeeded()
            y += table.bounds.height / 2
        }
        let maxOffset = table.contentSize.height - table.bounds.height
        table.contentOffset.y = maxOffset
        table.layoutIfNeeded()
        if usesFooter {
            table.contentOffset.y = maxOffset + 60
            table.layoutIfNeeded()
            footer.state = .refreshing
            spin(0.5)
        }
        let last = IndexPath(row: 19, section: 0)
        let before = table.convert(table.rectForRow(at: last), to: window).minY
        rows = 40
        table.reloadData()
        if usesFooter { footer.endRefreshing() }
        spin(0.8)
        table.layoutIfNeeded()
        let after = table.convert(table.rectForRow(at: last), to: window).minY
        // With a footer the offset gives back at most the footer height; count that as no jump.
        return after - before
    }
}
