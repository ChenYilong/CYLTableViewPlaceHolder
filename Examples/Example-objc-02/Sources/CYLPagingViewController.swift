//
//  CYLPagingViewController.swift
//  Example-objc-02
//
//  A paging table that restores its page after a header or footer refresh (MJRefresh #1430).
//

import UIKit
import CYLTableViewPlaceHolder

private let CYLPagingCellIdentifier = "page"
/// Simulated loading time of the header and footer.
private let CYLPagingDuration: TimeInterval = 0.5

final class CYLPagingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var rowCount = 8

    override func viewDidLoad() {
        super.viewDidLoad()
        title = CYLObjC02LocalizedString(.titlePaging)
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.isPagingEnabled = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.accessibilityIdentifier = "pagingTable"
        view.addSubview(tableView)

        tableView.cyl_header = CYLRefreshNormalHeader { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + CYLPagingDuration) { [weak self] in
                guard let self = self else { return }
                self.rowCount += 1
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
                self.tableView.setContentOffset(CGPoint(x: 0, y: 2 * self.tableView.bounds.height), animated: false)
                self.tableView.cyl_header?.endRefreshing(completionBlock: { [weak self] in
                    self?.cyl_setStatusTitle(CYLObjC02LocalizedString(.titleRefreshCompleted))
                })
            }
        }
        tableView.cyl_footer = CYLRefreshBackNormalFooter { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + CYLPagingDuration) { [weak self] in
                guard let self = self else { return }
                self.rowCount += 1
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
                self.tableView.cyl_footer?.endRefreshing(completionBlock: { [weak self] in
                    self?.cyl_setStatusTitle(CYLObjC02LocalizedString(.titleLoadCompleted))
                })
            }
        }

        let refreshItem = UIBarButtonItem(title: CYLObjC02LocalizedString(.actionRefresh), style: .plain,
                                          target: self, action: #selector(startRefresh))
        refreshItem.accessibilityHint = CYLObjC02LocalizedString(.hintRefresh)
        navigationItem.rightBarButtonItem = refreshItem
        let lastPageItem = UIBarButtonItem(title: CYLObjC02LocalizedString(.actionLastPage), style: .plain,
                                           target: self, action: #selector(showLastPage))
        lastPageItem.accessibilityHint = CYLObjC02LocalizedString(.hintLastPage)
        navigationItem.leftBarButtonItem = lastPageItem
    }

    @objc private func startRefresh() {
        tableView.cyl_header?.beginRefreshing()
    }

    @objc private func showLastPage() {
        tableView.setContentOffset(CGPoint(x: 0, y: CGFloat(rowCount - 1) * tableView.bounds.height), animated: false)
    }

    // MARK: - UITableViewDataSource

    @objc(tableView:numberOfRowsInSection:)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rowCount
    }

    @objc(tableView:cellForRowAtIndexPath:)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CYLPagingCellIdentifier)
            ?? UITableViewCell(style: .default, reuseIdentifier: CYLPagingCellIdentifier)
        cell.textLabel?.font = .preferredFont(forTextStyle: .body)
        cell.textLabel?.adjustsFontForContentSizeCategory = true
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = CYLObjC02LocalizedFormat(.formatPage, indexPath.row)
        cell.accessibilityIdentifier = "page-\(indexPath.row)"
        return cell
    }

    // MARK: - UITableViewDelegate

    @objc(tableView:heightForRowAtIndexPath:)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.bounds.height
    }
}
