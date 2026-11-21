//
//  CYLSectionsViewController.swift
//  Example-objc-02
//
//  A plain table with floating section headers under a translucent navigation bar (MJRefresh PR #1444, launch argument
//  `-sections`): while the header refreshes, a section header scrolled to the top must pin right below the bar, not
//  the header's height lower, and a rotation during the refresh must not leave a gap above the content afterwards.
//

import UIKit
import CYLTableViewPlaceHolder

private let CYLSectionsCellIdentifier = "row"
/// Simulated loading time; long enough for the UI tests to scroll and rotate while the header refreshes. 20 s, not 8:
/// on GitHub's macOS runners an XCUITest drag can take several seconds, and with 8 s the refresh sometimes ended
/// before the drag did ("the drag happens during the refresh" failed, 2026-11-21).
private let CYLSectionsDuration: TimeInterval = 20

final class CYLSectionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var refreshCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        title = CYLObjC02LocalizedString(.titleSections)
        view.backgroundColor = .systemBackground
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 60
        tableView.sectionHeaderHeight = 32
        tableView.sectionHeaderTopPadding = 0
        tableView.accessibilityIdentifier = "sectionsTable"
        view.addSubview(tableView)

        tableView.cyl_header = CYLRefreshNormalHeader { [weak self] in
            self?.title = CYLObjC02LocalizedString(.titleHeaderRefreshing)
            DispatchQueue.main.asyncAfter(deadline: .now() + CYLSectionsDuration) { [weak self] in
                guard let self = self else { return }
                self.tableView.reloadData()
                self.tableView.cyl_header?.endRefreshing(completionBlock: { [weak self] in
                    guard let self = self else { return }
                    self.refreshCount += 1
                    self.cyl_setStatusTitle(CYLObjC02LocalizedFormat(.formatHeaderCompleted, self.refreshCount))
                })
            }
        }

        let refreshItem = UIBarButtonItem(title: CYLObjC02LocalizedString(.actionRefresh), style: .plain,
                                          target: self, action: #selector(startRefresh))
        refreshItem.accessibilityHint = CYLObjC02LocalizedString(.hintRefreshSections)
        navigationItem.rightBarButtonItem = refreshItem
    }

    @objc private func startRefresh() {
        tableView.cyl_header?.beginRefreshing()
    }

    // MARK: - UITableViewDataSource

    @objc(numberOfSectionsInTableView:)
    func numberOfSections(in tableView: UITableView) -> Int {
        10
    }

    @objc(tableView:numberOfRowsInSection:)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        6
    }

    @objc(tableView:cellForRowAtIndexPath:)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CYLSectionsCellIdentifier)
            ?? UITableViewCell(style: .default, reuseIdentifier: CYLSectionsCellIdentifier)
        cell.textLabel?.font = .preferredFont(forTextStyle: .body)
        cell.textLabel?.adjustsFontForContentSizeCategory = true
        cell.textLabel?.text = CYLObjC02LocalizedFormat(.formatItem, indexPath.section * 6 + indexPath.row + 1)
        cell.accessibilityIdentifier = "row-\(indexPath.section)-\(indexPath.row)"
        return cell
    }

    // MARK: - UITableViewDelegate

    @objc(tableView:viewForHeaderInSection:)
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.backgroundColor = .secondarySystemBackground
        label.text = "  " + CYLObjC02LocalizedFormat(.formatSection, section)
        label.accessibilityLabel = CYLObjC02LocalizedFormat(.formatSection, section)
        label.accessibilityTraits = .header
        label.accessibilityIdentifier = "section-\(section)"
        return label
    }
}
