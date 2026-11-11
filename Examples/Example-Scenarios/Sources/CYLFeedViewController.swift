//
//  CYLFeedViewController.swift
//  Example-Scenarios
//
//  A feed with CYLRefresh: the Loading scenario on first load, then posts; every other pull to refresh fails and shows
//  the Retry Button scenario, whose "Retry" loads the first page again.
//

import UIKit
import CYLTableViewPlaceHolder

final class CYLFeedViewController: UITableViewController {

    private enum State {
        case loading, loaded, failed
    }

    private var state = State.loading
    private var rows = 0
    private var refreshCount = 0

    init() {
        super.init(style: .plain)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "feed")
        tableView.tableFooterView = UIView()
        tableView.cyl_placeholderViewBlock({ [weak self] _ in
            self?.makePlaceholder()
        })
        // The refresh controls draw their icon with the library's icon component: a Lottie arrow while pulling and a PAG
        // spinner while refreshing; the footer loads with a Lottie spinner. Layout and texts stay CYLRefresh's own.
        let header = CYLRefreshNormalHeader { [weak self] in
            self?.refresh()
        }
        header.setIconAnimation(bundled: "CYLPlaceholderRefresh.json", size: CGSize(width: 28, height: 28), for: .idle)
        header.setIconAnimation(bundled: "CYLPlaceholderLoading.pag", size: CGSize(width: 36, height: 36), for: .refreshing)
        tableView.cyl_header = header
        let footer = CYLRefreshAutoNormalFooter { [weak self] in
            self?.loadMore()
        }
        footer.setIconAnimation(bundled: "CYLPlaceholderLoadingInfinity.json", size: CGSize(width: 40, height: 24),
                                for: .refreshing)
        tableView.cyl_footer = footer
        loadFirstPage()
    }

    private func makePlaceholder() -> UIView {
        switch state {
        case .loading, .loaded:
            return CYLPlaceholderStackView(scenario: .loading, actions: nil)
        case .failed:
            return CYLPlaceholderStackView(scenario: .retryButton, actions: [
                .retry: { [weak self] _, _ in self?.loadFirstPage() },
            ])
        }
    }

    private func loadFirstPage() {
        state = .loading
        rows = 0
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            self.state = .loaded
            self.rows = 15
            self.tableView.cyl_footer?.resetNoMoreData()
            self.tableView.reloadData()
        }
    }

    /// Every other refresh fails, to show the error placeholder replacing the list.
    private func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.refreshCount += 1
            let fails = self.refreshCount % 2 == 1
            self.state = fails ? .failed : .loaded
            self.rows = fails ? 0 : 15
            self.tableView.cyl_footer?.resetNoMoreData()
            self.tableView.reloadData()
            self.tableView.cyl_header?.endRefreshing()
        }
    }

    private func loadMore() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            if self.rows >= 30 {
                self.tableView.cyl_footer?.endRefreshingWithNoMoreData()
                return
            }
            self.rows += 15
            self.tableView.reloadData()
            self.tableView.cyl_footer?.endRefreshing()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feed", for: indexPath)
        var content = UIListContentConfiguration.subtitleCell()
        content.text = CYLScenarioLocalizedFormat(.formatPost, indexPath.row + 1)
        content.secondaryText = CYLScenarioLocalizedString(.textFeedHint)
        content.image = UIImage(systemName: "person.crop.circle")
        cell.contentConfiguration = content
        return cell
    }
}
