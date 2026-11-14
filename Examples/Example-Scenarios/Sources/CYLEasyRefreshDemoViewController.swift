//
//  CYLEasyRefreshDemoViewController.swift
//  Example-Scenarios
//
//  The demo of flutter_easy_refresh (https://github.com/xuelongqy/flutter_easy_refresh, example/lib/page, MIT; by
//  xuelongqy), transcribed to Swift on this project's API, one method per page. Only data, options and taps live
//  here; every header, footer and the pagination come from the core (CYLRefresh).
//
//  Pages and their originals:
//  - easyCupertino: style/cupertino_page.dart (CupertinoHeader / CupertinoFooter).
//  - easySecondary: sample/secondary_page.dart (the second floor).
//  - easyTriggerMode: sample/trigger_mode_page.dart (IndicatorTriggerMode).
//  - easyRefreshOnStart: sample/refresh_on_start_page.dart (refreshOnStartHeader).
//  - easyPaging: sample/paging_page.dart (easy_paging: 45 items, 10 per page).
//  - easyListener: sample/listener_header_page.dart (a header that draws nothing; the page shows the pull).
//  - easyChat: sample/chat_page.dart (pull at the top for earlier messages, the position kept).
//  - easyUserProfile: sample/user_profile_page.dart (the indicator behind the content, IndicatorPosition.behind).
//  The other pages (nested scrolling, carousel, page / tab views, center refresh, theme switch, test) are listed with
//  the reason in docs/Refresh-Library-Parity.md.
//

import UIKit
import CYLTableViewPlaceHolder

final class CYLEasyRefreshDemoViewController: UITableViewController, CYLRefreshExampleRunning {

    var method = ""

    private var rows: [String] = []
    private var count = 10
    private var refreshCount = 0
    private var loadCount = 0
    private var header: CYLRefreshHeader?
    private var footer: CYLRefreshFooter?
    private var paging: CYLRefreshPaging?
    private let progressView = UIProgressView(progressViewStyle: .bar)
    private var earliestMessage = 0

    init() {
        super.init(style: .plain)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.accessibilityIdentifier = "easyRefreshDemo"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "item")
        switch method {
        case "easyCupertino": setUpCupertino()
        case "easySecondary": setUpSecondary()
        case "easyTriggerMode": setUpTriggerMode()
        case "easyRefreshOnStart": setUpRefreshOnStart()
        case "easyPaging": setUpPaging()
        case "easyListener": setUpListener()
        case "easyChat": setUpChat()
        default: setUpUserProfile()
        }
    }

    // MARK: - Pages

    /// cupertino_page.dart: the iOS-style header and footer.
    private func setUpCupertino() {
        header = CYLRefreshCupertinoHeader.attach(to: tableView, target: self, action: #selector(refreshCounted))
        footer = CYLRefreshCupertinoFooter.attach(to: tableView, target: self, action: #selector(loadCounted))
        reloadCounted()
    }

    /// secondary_page.dart: pull past 120 points and release to open the second floor; its button closes it.
    private func setUpSecondary() {
        let normal = CYLRefreshNormalHeader.attach(to: tableView, target: self, action: #selector(refreshCounted))
        normal.secondaryTriggerOffset = 120
        let floor = UIView()
        floor.backgroundColor = .systemIndigo
        let title = UILabel()
        title.text = CYLScenarioLocalizedString(.easySecondFloor)
        title.font = .preferredFont(forTextStyle: .title1)
        title.adjustsFontForContentSizeCategory = true
        title.textColor = .white
        let close = UIButton(type: .system)
        close.setTitle(CYLScenarioLocalizedString(.easyCloseSecondFloor), for: .normal)
        close.tintColor = .white
        close.addAction(UIAction { [weak normal] _ in normal?.closeSecondary() }, for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [title, close])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        floor.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: floor.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: floor.centerYAnchor),
        ])
        normal.secondaryView = floor
        header = normal
        footer = CYLRefreshBackNormalFooter.attach(to: tableView, target: self, action: #selector(loadCounted))
        reloadCounted()
    }

    /// trigger_mode_page.dart: the two rows switch the header's and the footer's trigger mode; the counts show what
    /// triggered.
    private func setUpTriggerMode() {
        header = CYLRefreshNormalHeader.attach(to: tableView, target: self, action: #selector(refreshTriggerMode))
        footer = CYLRefreshBackNormalFooter.attach(to: tableView, target: self, action: #selector(loadTriggerMode))
        count = 30
        reloadTriggerMode()
    }

    /// refresh_on_start_page.dart: the first refresh uses another header (here the Cupertino one); later pulls use
    /// the classic header. Starts with no rows.
    private func setUpRefreshOnStart() {
        header = CYLRefreshNormalHeader.attach(to: tableView, target: self, action: #selector(refreshCounted))
        footer = CYLRefreshBackNormalFooter.attach(to: tableView, target: self, action: #selector(loadByTen))
        count = 0
        reloadCounted()
        tableView.cyl_beginRefreshing(startHeader: CYLRefreshCupertinoHeader())
    }

    /// paging_page.dart: a server of 45 items, 10 per page, 2 seconds per request; refresh on start.
    private func setUpPaging() {
        let normal = CYLRefreshNormalHeader()
        normal.attach(to: tableView)
        let back = CYLRefreshBackNormalFooter()
        back.attach(to: tableView)
        let paging = CYLRefreshPaging(header: normal, footer: back) { page, done in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let total = 45, size = 10
                let start = (page - 1) * size
                let items: [Any] = start >= total ? [] : Array(start..<min(start + size, total)).map { $0 + 1 }
                done(items, total, NSNotFound, nil)
            }
        }
        paging.itemsDidChange = { [weak self] paging in
            self?.rows = (paging.items as? [Int] ?? []).map { String(format: CYLScenarioLocalizedString(.smartTestDataRow), $0) }
            self?.tableView.reloadData()
        }
        self.paging = paging
        header = normal
        footer = back
        paging.start()
    }

    /// listener_header_page.dart: the header draws nothing; the bar above the list shows how far it is pulled.
    private func setUpListener() {
        let listener = CYLRefreshHeader.attach(to: tableView, target: self, action: #selector(refreshCounted))
        listener.accessibilityLabel = CYLScenarioLocalizedString(.easyPullProgress)
        header = listener
        footer = CYLRefreshBackNormalFooter.attach(to: tableView, target: self, action: #selector(loadCounted))
        progressView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 4)
        progressView.accessibilityLabel = CYLScenarioLocalizedString(.easyPullProgress)
        tableView.tableHeaderView = progressView
        reloadCounted()
    }

    /// chat_page.dart: the newest messages are at the bottom; pulling at the top loads 10 earlier ones and keeps the
    /// visible messages where they were.
    private func setUpChat() {
        header = CYLRefreshNormalHeader.attach(to: tableView, target: self, action: #selector(loadEarlierMessages))
        earliestMessage = 31
        rows = (31...50).map { String(format: CYLScenarioLocalizedString(.easyMessageRow), $0) }
        tableView.reloadData()
        DispatchQueue.main.async { [weak self] in
            guard let self = self, !self.rows.isEmpty else { return }
            self.tableView.scrollToRow(at: IndexPath(row: self.rows.count - 1, section: 0), at: .bottom, animated: false)
        }
    }

    /// user_profile_page.dart: a banner above the list and the header pinned behind the content.
    private func setUpUserProfile() {
        let normal = CYLRefreshNormalHeader.attach(to: tableView, target: self, action: #selector(refreshCounted))
        normal.scrollMode = .behind
        header = normal
        let banner = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 160))
        banner.text = CYLScenarioLocalizedString(.easyProfileBanner)
        banner.textAlignment = .center
        banner.font = .preferredFont(forTextStyle: .title2)
        banner.adjustsFontForContentSizeCategory = true
        banner.backgroundColor = .systemTeal
        banner.textColor = .white
        tableView.tableHeaderView = banner
        reloadCounted()
    }

    // MARK: - Data

    private func reloadCounted() {
        rows = (0..<count).map { String(format: CYLScenarioLocalizedString(.smartTestDataRow), $0 + 1) }
        tableView.reloadData()
    }

    private func reloadTriggerMode() {
        let headerOnEdge = header?.triggerMode == .onEdge
        let footerOnEdge = footer?.triggerMode == .onEdge
        rows = [
            String(format: CYLScenarioLocalizedString(.easyRefreshCount), refreshCount),
            String(format: CYLScenarioLocalizedString(.easyLoadCount), loadCount),
            CYLScenarioLocalizedString(headerOnEdge ? .easyHeaderOnEdge : .easyHeaderAnywhere),
            CYLScenarioLocalizedString(footerOnEdge ? .easyFooterOnEdge : .easyFooterAnywhere),
        ] + (0..<count).map { String(format: CYLScenarioLocalizedString(.smartTestDataRow), $0 + 1) }
        tableView.reloadData()
    }

    // MARK: - Taps and callbacks

    /// Refresh: back to 10 rows after 2 seconds, and the footer can load again. Ends the header that is attached now
    /// (`cyl_header`): during refresh on start that is the start header, not `header`.
    @objc private func refreshCounted() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            self.count = 10
            self.reloadCounted()
            self.tableView.cyl_header?.endRefreshing()
            self.footer?.resetNoMoreData()
        }
    }

    /// Load: 5 more rows after 2 seconds; no more data at 20.
    @objc private func loadCounted() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            self.count += 5
            self.reloadCounted()
            if self.count >= 20 { self.footer?.endRefreshingWithNoMoreData() } else { self.footer?.endRefreshing() }
        }
    }

    /// refresh_on_start_page.dart's load: 10 more rows; no more data at 30.
    @objc private func loadByTen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            self.count += 10
            self.reloadCounted()
            if self.count >= 30 { self.footer?.endRefreshingWithNoMoreData() } else { self.footer?.endRefreshing() }
        }
    }

    @objc private func refreshTriggerMode() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.refreshCount += 1
            self.reloadTriggerMode()
            self.tableView.cyl_header?.endRefreshing()
        }
    }

    @objc private func loadTriggerMode() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.loadCount += 1
            self.reloadTriggerMode()
            self.footer?.endRefreshing()
        }
    }

    @objc private func loadEarlierMessages() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            let first = max(1, self.earliestMessage - 10)
            let added = (first..<self.earliestMessage).map { String(format: CYLScenarioLocalizedString(.easyMessageRow), $0) }
            self.earliestMessage = first
            // Keep the visible messages in place: add the height of the new rows to the offset.
            let before = self.tableView.contentSize.height
            self.rows.insert(contentsOf: added, at: 0)
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
            let offset = self.tableView.contentOffset
            self.tableView.cyl_header?.endRefreshing()
            self.tableView.contentOffset = CGPoint(x: offset.x, y: offset.y + self.tableView.contentSize.height - before)
            if first == 1 { self.header?.isHidden = true }
        }
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard method == "easyListener", let header = header else { return }
        progressView.setProgress(Float(min(header.pullingPercent, 1)), animated: false)
        progressView.accessibilityValue = "\(Int(min(header.pullingPercent, 1) * 100))%"
    }

    // MARK: - Table

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = rows[indexPath.row]
        cell.contentConfiguration = content
        let switches = method == "easyTriggerMode" && (indexPath.row == 2 || indexPath.row == 3)
        cell.accessibilityTraits = switches ? .button : .staticText
        cell.selectionStyle = switches ? .default : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard method == "easyTriggerMode" else { return }
        if indexPath.row == 2, let header = header {
            header.triggerMode = header.triggerMode == .onEdge ? .anywhere : .onEdge
        } else if indexPath.row == 3, let footer = footer {
            footer.triggerMode = footer.triggerMode == .onEdge ? .anywhere : .onEdge
        } else {
            return
        }
        reloadTriggerMode()
    }
}
