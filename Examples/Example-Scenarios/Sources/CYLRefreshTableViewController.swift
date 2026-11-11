//
//  CYLRefreshTableViewController.swift
//  Example-Scenarios
//
//  MJTableViewController of MJRefresh's example layer (MIT; originally created by MJ Lee, Copyright (c) 2015 小码哥),
//  transcribed to Swift on this project's API (`MJ` → `CYL`, `mj_` → `cyl_`): example01–06 (pull down),
//  example11–21 (pull up), then example51–56, which draw GIF, Lottie, PAG and Rive icons on the same list.
//

import UIKit
import CYLTableViewPlaceHolder

/// MJRefresh's MJDuration: long enough to see the refreshing state.
private let CYLRefreshDuration: TimeInterval = 2.0

/// A label of a refresh control, whether Swift imports it as optional (a weak property) or not.
private func label(_ label: UILabel?) -> UILabel? {
    label
}

final class CYLRefreshTableViewController: UITableViewController, CYLRefreshExampleRunning {

    var method = ""
    /// The fake data shown in the list.
    private lazy var data: [String] = (0..<5).map { _ in Self.randomData() }

    private static func randomData() -> String {
        CYLScenarioLocalizedFormat(.mjRandomData, Int.random(in: 0..<1_000_000))
    }

    // MARK: - Examples: UITableView + pull down

    /// Default
    func example01() {
        // The callback runs as soon as the control enters the refreshing state.
        tableView.cyl_header = CYLRefreshNormalHeader { [weak self] in
            self?.loadNewData()
        }
        // Enter the refreshing state right away
        tableView.cyl_header?.beginRefreshing()
    }

    /// Animated images
    func example02() {
        // The callback calls the target's action, that is self's loadNewData.
        tableView.cyl_header = CYLRefreshExampleImagesHeader(refreshingTarget: self,
                                                              refreshingAction: #selector(loadNewData))
        tableView.cyl_header?.beginRefreshing()
    }

    /// Hide the time
    func example03() {
        let header = CYLRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadNewData))
        // Fades automatically (hides under the navigation bar)
        header.isAutomaticallyChangeAlpha = true
        // Hide the time
        label(header.lastUpdatedTimeLabel)?.isHidden = true
        header.beginRefreshing()
        tableView.cyl_header = header
    }

    /// Hide the state and time
    func example04() {
        let header = CYLRefreshExampleImagesHeader(refreshingTarget: self, refreshingAction: #selector(loadNewData))
        label(header.lastUpdatedTimeLabel)?.isHidden = true
        label(header.stateLabel)?.isHidden = true
        header.beginRefreshing()
        tableView.cyl_header = header
    }

    /// Custom text
    func example05() {
        let header = CYLRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadNewData))
        // The texts
        header.setTitle(CYLScenarioLocalizedString(.mjCustomIdle), for: .idle)
        header.setTitle(CYLScenarioLocalizedString(.mjCustomPulling), for: .pulling)
        header.setTitle(CYLScenarioLocalizedString(.mjCustomLoading), for: .refreshing)
        // The fonts (scaled with Dynamic Type)
        label(header.stateLabel)?.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 15))
        label(header.lastUpdatedTimeLabel)?.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 14))
        // The colors
        label(header.stateLabel)?.textColor = .systemRed
        label(header.lastUpdatedTimeLabel)?.textColor = .systemBlue
        header.beginRefreshing()
        tableView.cyl_header = header
    }

    /// Custom refresh control
    func example06() {
        tableView.cyl_header = CYLRefreshDIYHeader(refreshingTarget: self, refreshingAction: #selector(loadNewData))
        tableView.cyl_header?.beginRefreshing()
    }

    // MARK: - Examples: UITableView + pull up

    /// Default
    func example11() {
        example01()
        tableView.cyl_footer = CYLRefreshAutoNormalFooter { [weak self] in
            self?.loadMoreData()
        }
    }

    /// Animated images
    func example12() {
        example01()
        tableView.cyl_footer = CYLRefreshExampleImagesFooter(refreshingTarget: self,
                                                              refreshingAction: #selector(loadMoreData))
    }

    /// Hide the refreshing text
    func example13() {
        example01()
        let footer = CYLRefreshExampleImagesFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        // Refreshes automatically once 50% of the footer shows (the default 1.0 waits for all of it):
        // footer.triggerAutomaticallyRefreshPercent = 0.5
        // Hide the text of the refreshing state
        footer.isRefreshingTitleHidden = true
        tableView.cyl_footer = footer
    }

    /// Everything loaded
    func example14() {
        example01()
        tableView.cyl_footer = CYLRefreshAutoNormalFooter(refreshingTarget: self,
                                                           refreshingAction: #selector(loadLastData))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: CYLScenarioLocalizedString(.mjResumeLoading),
                                                            style: .done, target: self, action: #selector(reset))
    }

    @objc private func reset() {
        tableView.cyl_footer?.setRefreshingTarget(self, refreshingAction: #selector(loadMoreData))
        tableView.cyl_footer?.resetNoMoreData()
    }

    /// No automatic loading
    func example15() {
        example01()
        let footer = CYLRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        // No automatic loading
        footer.isAutomaticallyRefresh = false
        tableView.cyl_footer = footer
    }

    /// Custom text
    func example16() {
        example01()
        let footer = CYLRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        footer.setTitle(CYLScenarioLocalizedString(.mjFooterIdle), for: .idle)
        footer.setTitle(CYLScenarioLocalizedString(.mjFooterLoading), for: .refreshing)
        footer.setTitle(CYLScenarioLocalizedString(.mjFooterNoMore), for: .noMoreData)
        label(footer.stateLabel)?.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 17))
        label(footer.stateLabel)?.textColor = .systemBlue
        tableView.cyl_footer = footer
    }

    /// Hide after loading
    func example17() {
        example01()
        tableView.cyl_footer = CYLRefreshAutoNormalFooter(refreshingTarget: self,
                                                           refreshingAction: #selector(loadOnceData))
    }

    /// Springing-back footer 01
    func example18() {
        example01()
        tableView.cyl_footer = CYLRefreshBackNormalFooter(refreshingTarget: self,
                                                           refreshingAction: #selector(loadMoreData))
        // A bottom inset…
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        // …that the footer ignores
        tableView.cyl_footer?.ignoredScrollViewContentInsetBottom = 30
    }

    /// Springing-back footer 02
    func example19() {
        example01()
        tableView.cyl_footer = CYLRefreshExampleImagesBackFooter(refreshingTarget: self,
                                                                  refreshingAction: #selector(loadLastData))
        tableView.cyl_footer?.isAutomaticallyChangeAlpha = true
    }

    /// Custom control (loads automatically)
    func example20() {
        example01()
        let footer = CYLRefreshDIYAutoFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        footer.autoTriggerTimes = 2
        tableView.cyl_footer = footer
    }

    /// Custom control (springs back)
    func example21() {
        example01()
        tableView.cyl_footer = CYLRefreshDIYBackFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
    }

    // MARK: - Examples beyond MJRefresh: animated icons on the animated-image controls

    /// A GIF icon in place of the images: the header turns refresh arrows, the footer loads with a ring.
    func example51() {
        let header = CYLRefreshAnimationHeader(refreshingTarget: self, refreshingAction: #selector(loadNewData))
        header.setIconAnimation(bundled: "CYLRefreshArrows.gif", size: CGSize(width: 32, height: 32), for: .idle)
        tableView.cyl_header = header
        let footer = CYLRefreshAutoAnimationFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        footer.setIconAnimation(bundled: "CYLRefreshRing.gif", size: CGSize(width: 28, height: 28), for: .refreshing)
        tableView.cyl_footer = footer
        header.beginRefreshing()
    }

    /// A Lottie icon for each state: pull arrow, turning arrows when released, a spinner while refreshing; the footer
    /// shows load-more dots, then a check when everything is loaded.
    func example52() {
        let header = CYLRefreshAnimationHeader(refreshingTarget: self, refreshingAction: #selector(loadNewData))
        header.setIconAnimation(bundled: "CYLRefreshPullArrow.json", size: CGSize(width: 28, height: 28), for: .idle)
        header.setIconAnimation(bundled: "CYLRefreshClockwise.json", size: CGSize(width: 28, height: 28), for: .pulling)
        header.setIconAnimation(bundled: "CYLRefreshMaterialSpinner.json", size: CGSize(width: 36, height: 36),
                                for: .refreshing)
        tableView.cyl_header = header
        let footer = CYLRefreshBackAnimationFooter(refreshingTarget: self, refreshingAction: #selector(loadLastData))
        footer.setIconAnimation(bundled: "CYLRefreshLoadMore.json", size: CGSize(width: 28, height: 28), for: .idle)
        footer.setIconAnimation(bundled: "CYLRefreshMoreDots.json", size: CGSize(width: 40, height: 24),
                                for: .refreshing)
        tableView.cyl_footer = footer
        header.beginRefreshing()
    }

    /// The PAG progress ring: it fills with the pull and loops while refreshing.
    func example53() {
        let header = CYLRefreshAnimationHeader(refreshingTarget: self, refreshingAction: #selector(loadNewData))
        header.setIconAnimation(bundled: "CYLPlaceholderProgress.pag", size: CGSize(width: 32, height: 32), for: .idle)
        tableView.cyl_header = header
        let footer = CYLRefreshAutoAnimationFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        footer.setIconAnimation(bundled: "CYLPlaceholderProgress.pag", size: CGSize(width: 28, height: 28),
                                for: .refreshing)
        tableView.cyl_footer = footer
        header.beginRefreshing()
    }

    /// The Rive refresh icon: its "refresh" artboard rests while pulling and turns while refreshing.
    func example54() {
        let header = CYLRefreshAnimationHeader(refreshingTarget: self, refreshingAction: #selector(loadNewData))
        let footer = CYLRefreshAutoAnimationFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        if let path = CYLPlaceholderView.path(forBundledAnimation: "CYLRefreshIcon.riv") {
            let resting: [String: Any] = [
                CYLPlaceholderItemAnimationFilePath: path,
                CYLPlaceholderItemAnimationSize: [32, 32],
                CYLPlaceholderItemAnimationOptions: ["legacy": "1", "artboard": "refresh", "animation": "idle"],
            ]
            var turning = resting
            turning[CYLPlaceholderItemAnimationOptions] = ["legacy": "1", "artboard": "refresh", "animation": "active"]
            header.setIconAnimation(attributes: resting, for: .idle)
            header.setIconAnimation(attributes: turning, for: .refreshing)
            footer.setIconAnimation(attributes: turning, for: .refreshing)
        }
        tableView.cyl_header = header
        tableView.cyl_footer = footer
        header.beginRefreshing()
    }

    /// MJRefresh's animated-images API on its own names: CYLRefreshGifHeader with `setImages`, frames of a refresh GIF.
    func example55() {
        let header = CYLRefreshGifHeader(refreshingTarget: self, refreshingAction: #selector(loadNewData))
        header.setImages(CYLRefreshExampleImages.idle, for: .idle)
        header.setImages(CYLRefreshExampleImages.refreshing, duration: 0.8, for: .refreshing)
        tableView.cyl_header = header
        let footer = CYLRefreshAutoGifFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        footer.setImages(CYLRefreshExampleImages.refreshing, for: .refreshing)
        tableView.cyl_footer = footer
        header.beginRefreshing()
    }

    /// A different engine for each state: Lottie while idle, GIF when released, PAG while refreshing; the footer loads
    /// with Rive.
    func example56() {
        let header = CYLRefreshAnimationHeader(refreshingTarget: self, refreshingAction: #selector(loadNewData))
        header.setIconAnimation(bundled: "CYLRefreshPullCircle.json", size: CGSize(width: 28, height: 28), for: .idle)
        header.setIconAnimation(bundled: "CYLRefreshArrows.gif", size: CGSize(width: 30, height: 30), for: .pulling)
        header.setIconAnimation(bundled: "CYLPlaceholderProgress.pag", size: CGSize(width: 32, height: 32),
                                for: .refreshing)
        tableView.cyl_header = header
        let footer = CYLRefreshAutoAnimationFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        footer.setIconAnimation(bundled: "CYLRefreshIcon.riv", size: CGSize(width: 30, height: 30), for: .refreshing)
        tableView.cyl_footer = footer
        header.beginRefreshing()
    }

    // MARK: - Data

    /// New data for a pull down
    @objc private func loadNewData() {
        // 1. Fake data
        for _ in 0..<5 {
            data.insert(Self.randomData(), at: 0)
        }
        // 2. Reload after a delay (remove it in a real app)
        DispatchQueue.main.asyncAfter(deadline: .now() + CYLRefreshDuration) { [weak self] in
            self?.tableView.reloadData()
            // End the refreshing state of the current header
            self?.tableView.cyl_header?.endRefreshing()
        }
    }

    /// More data for a pull up
    @objc private func loadMoreData() {
        data.append(Self.randomData())
        DispatchQueue.main.asyncAfter(deadline: .now() + CYLRefreshDuration) { [weak self] in
            self?.tableView.reloadData()
            self?.tableView.cyl_footer?.endRefreshing()
        }
    }

    /// The last data: the footer then shows "no more data"
    @objc private func loadLastData() {
        for _ in 0..<5 {
            data.append(Self.randomData())
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + CYLRefreshDuration) { [weak self] in
            self?.tableView.reloadData()
            self?.tableView.cyl_footer?.endRefreshingWithNoMoreData()
        }
    }

    /// Data that loads only once: the footer hides afterwards
    @objc private func loadOnceData() {
        for _ in 0..<5 {
            data.append(Self.randomData())
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + CYLRefreshDuration) { [weak self] in
            self?.tableView.reloadData()
            self?.tableView.cyl_footer?.isHidden = true
        }
    }

    // MARK: - Other

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.accessibilityIdentifier = "refreshExample"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        run(method)
    }

    /// Runs an example by name (MJRefresh calls `performSelector:` with the method name).
    private func run(_ method: String) {
        let examples: [String: () -> Void] = [
            "example01": example01, "example02": example02, "example03": example03, "example04": example04,
            "example05": example05, "example06": example06, "example11": example11, "example12": example12,
            "example13": example13, "example14": example14, "example15": example15, "example16": example16,
            "example17": example17, "example18": example18, "example19": example19, "example20": example20,
            "example21": example21, "example51": example51, "example52": example52, "example53": example53,
            "example54": example54, "example55": example55, "example56": example56,
        ]
        examples[method]?()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let action = CYLScenarioLocalizedString(indexPath.row % 2 == 1 ? .mjPush : .mjModal)
        var content = cell.defaultContentConfiguration()
        content.text = "\(action) - \(data[indexPath.row])"
        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        CYLRefreshTestViewController.show(from: self, row: indexPath.row)
    }
}
