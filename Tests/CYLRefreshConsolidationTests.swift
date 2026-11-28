//
//  CYLRefreshConsolidationTests.swift
//  CYLTableViewPlaceHolder tests
//
//  [EN] The shared state-title and animation-image logic of CYLRefresh (docs/Task-Log.md, the iOS CYLRefresh
//       consolidation): every state control reads its texts from one table, every animation control its images.
//       Swift since docs/Swift-Migration.md, step 13.
//  [CN] CYLRefresh 共用的状态文字与动画图片逻辑（docs/Task-Log.md，iOS CYLRefresh 合并）：每个状态控件从同一张表读取文字，
//       每个动画控件从同一处读取图片。自 docs/Swift-Migration.md 第 13 步起用 Swift 编写。
//

import XCTest
import UIKit

final class CYLRefreshConsolidationTests: XCTestCase {

    func testEveryStateControlKeepsItsTitlesTheSameWay() {
        let header = CYLRefreshStateHeader(refreshingBlock: {})
        let autoFooter = CYLRefreshAutoStateFooter(refreshingBlock: {})
        let backFooter = CYLRefreshBackStateFooter(refreshingBlock: {})
        let trailer = CYLRefreshStateTrailer()
        header.setTitle("Pull", for: .pulling)
        autoFooter.setTitle("Pull", for: .pulling)
        backFooter.setTitle("Pull", for: .pulling)
        trailer.setTitle("Pull", for: .pulling)
        XCTAssertEqual(header.title(for: .pulling), "Pull")
        XCTAssertEqual(autoFooter.title(for: .pulling), "Pull")
        XCTAssertEqual(backFooter.title(for: .pulling), "Pull")
        XCTAssertEqual(trailer.title(for: .pulling), "Pull")
        for control in [header, autoFooter, backFooter, trailer] as [CYLRefreshComponent] {
            XCTAssertEqual(control.stateTitle(for: .pulling), "Pull", "\(type(of: control))")
            control.setStateTitle(nil, for: .pulling)
            XCTAssertEqual(control.stateTitle(for: .pulling), "Pull", "nil is ignored: \(type(of: control))")
        }
    }

    func testEveryAnimationControlKeepsItsImagesTheSameWay() {
        let tall = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 90)).image { _ in }
        let header = CYLRefreshAnimationHeader(refreshingBlock: {})
        let autoFooter = CYLRefreshAutoAnimationFooter(refreshingBlock: {})
        let backFooter = CYLRefreshBackAnimationFooter(refreshingBlock: {})
        header.setAnimationImages([tall, tall], for: .refreshing)
        autoFooter.setAnimationImages([tall, tall], for: .refreshing)
        backFooter.setAnimationImages([tall, tall], for: .refreshing)
        for control in [header, autoFooter, backFooter] as [CYLRefreshComponent] {
            XCTAssertEqual(control.animationImages(for: .refreshing)?.count ?? 0, 2, "\(type(of: control))")
            XCTAssertGreaterThanOrEqual(control.bounds.size.height, 90, "grows to the tallest image: \(type(of: control))")
            XCTAssertTrue(control.usesRefreshIconView, "the images become the icon: \(type(of: control))")
        }
    }

    func testBothNormalFootersShowTheNoMoreDataImageOnlyWithoutMoreData() {
        let image = UIGraphicsImageRenderer(size: CGSize(width: 12, height: 12)).image { _ in }
        let footers: [CYLRefreshFooter] = [
            CYLRefreshAutoNormalFooter(refreshingBlock: {}),
            CYLRefreshBackNormalFooter(refreshingBlock: {}),
        ]
        for footer in footers {
            footer.frame = CGRect(x: 0, y: 0, width: 320, height: 44)
            if let autoFooter = footer as? CYLRefreshAutoNormalFooter { autoFooter.noMoreDataImage = image }
            else { (footer as? CYLRefreshBackNormalFooter)?.noMoreDataImage = image }
            let shown = { () -> UIImageView? in
                for view in footer.subviews {
                    if type(of: view) == UIImageView.self, let imageView = view as? UIImageView,
                       imageView.image === image, !view.isHidden { return imageView }
                }
                return nil
            }
            XCTAssertNil(shown(), "hidden while idle: \(type(of: footer))")
            footer.endRefreshingWithNoMoreData()
            // [EN] The state changes on the next main-queue turn. [CN] 状态在下一个主队列循环中改变。
            let deadline = Date(timeIntervalSinceNow: 3)
            while shown() == nil && deadline.timeIntervalSinceNow > 0 {
                RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
                footer.layoutIfNeeded()
            }
            XCTAssertNotNil(shown(), "shown without more data: \(type(of: footer))")
        }
    }
}
