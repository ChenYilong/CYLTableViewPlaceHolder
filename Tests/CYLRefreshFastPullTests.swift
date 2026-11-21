import XCTest
import UIKit

// FIX: issue MJRefresh#1615
// [EN] A custom header that reads the scroll view on every offset change, as in the issue.
// [CN] 与 issue 相同：在每次 offset 变化时读取滚动视图的自定义刷新头。
final class CYLFastPullCustomHeader: CYLRefreshHeader {
    private let label = UILabel()
    private(set) var offsetChanges = 0

    override func prepare() {
        super.prepare()
        cyl_h = 60
        addSubview(label)
    }

    override func placeSubviews() {
        super.placeSubviews()
        label.frame = bounds
    }

    override func scrollViewContentOffsetDidChange(_ change: [AnyHashable: Any]?) {
        super.scrollViewContentOffsetDidChange(change)
        offsetChanges += 1
        label.text = String(format: "%.0f%%", (pullingPercent.isFinite ? pullingPercent : 0) * 100)
    }
}

// FIX: issue MJRefresh#1615
// [EN] The issue crashed in -observeValueForKeyPath: when a custom header was pulled quickly; it has no stack trace. These
//      tests pull every header kind as fast as code can: offsets jump far past the header in one step, pulling percents
//      are NaN, infinite and negative, the frame height is 0, and the header is removed in the middle of a refresh.
// [CN] 该 issue 在快速下拉自定义刷新头时崩溃于 -observeValueForKeyPath:，没有堆栈。这些测试以代码能做到的最快速度下拉每种刷新头：
//      offset 一步跳过刷新头很远，pullingPercent 为 NaN、无穷大和负数，frame 高度为 0，并在刷新中途移除刷新头。
final class CYLRefreshFastPullTests: XCTestCase {

    private func spin(_ seconds: TimeInterval) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func pullFast(_ make: () -> CYLRefreshComponent, zeroHeight: Bool) {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let controller = UIViewController()
        window.rootViewController = controller
        window.isHidden = false
        let table = UITableView(frame: window.bounds, style: .plain)
        controller.view.addSubview(table)
        let header = make()
        table.cyl_header = header as? CYLRefreshHeader
        if zeroHeight { header.cyl_h = 0 }
        table.layoutIfNeeded()
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 320, height: 200))
        let offsets: [CGFloat] = [-2000, 0, -5000, 30, -1_000_000, -61, 0]
        let percents: [CGFloat] = [.nan, .infinity, -3, 100, 0.5]
        for round in 0..<12 {
            for (index, offset) in offsets.enumerated() {
                table.contentOffset = CGPoint(x: 0, y: offset)
                header.pullingPercent = percents[(round + index) % percents.count]
                if index == 2 { header.state = .pulling }
                header.layoutIfNeeded()
                header.setNeedsDisplay()
                _ = renderer.image { context in header.layer.render(in: context.cgContext) }
            }
            if round % 3 == 0 { header.beginRefreshing() }
            spin(0.02)
            if round % 3 == 1 { header.endRefreshing() }
        }
        header.beginRefreshing()
        spin(0.05)
        header.removeFromSuperview()
        table.contentOffset = CGPoint(x: 0, y: -3000)
        spin(0.05)
        window.isHidden = true
    }

    func testEveryHeaderKindSurvivesFastPulls() {
        let kinds: [CYLRefreshComponent.Type] = [
            CYLFastPullCustomHeader.self,
            CYLRefreshStateHeader.self, CYLRefreshNormalHeader.self, CYLRefreshAnimationHeader.self,
            CYLRefreshGifHeader.self, CYLRefreshCupertinoHeader.self, CYLRefreshBezierCircleHeader.self,
            CYLRefreshBezierRadarHeader.self, CYLRefreshDeliveryHeader.self, CYLRefreshDropBoxHeader.self,
            CYLRefreshFlyHeader.self, CYLRefreshGameBattleCityHeader.self, CYLRefreshGameHitBlockHeader.self,
            CYLRefreshMaterialHeader.self, CYLRefreshOriginalHeader.self, CYLRefreshPhoenixHeader.self,
            CYLRefreshStoreHouseHeader.self, CYLRefreshTaurusHeader.self, CYLRefreshWaveSwipeHeader.self,
        ]
        for zeroHeight in [false, true] {
            for kind in kinds {
                pullFast({
                    if kind === CYLRefreshStoreHouseHeader.self { return CYLRefreshStoreHouseHeader(string: "CYL") }
                    let component = (kind as NSObject.Type).init() as! CYLRefreshComponent
                    component.refreshingBlock = {}
                    return component
                }, zeroHeight: zeroHeight)
            }
        }
    }

    func testCustomHeaderSeesEveryFastOffsetChange() {
        let table = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 480), style: .plain)
        let header = CYLFastPullCustomHeader(refreshingBlock: {})
        table.cyl_header = header
        for offset in stride(from: CGFloat(0), through: -3000, by: -500) {
            table.contentOffset = CGPoint(x: 0, y: offset)
        }
        XCTAssertGreaterThanOrEqual(header.offsetChanges, 7)
        XCTAssertTrue(header.pullingPercent.isFinite)
    }
}
