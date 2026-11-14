//
//  CYLExampleViewController.swift
//  CYLNoResultTableViewController
//
//  Created by 微博@iOS程序犭袁 ( http://weibo.com/luohanchenyilong/ ) on 15/12/22.
//  Copyright © 2015年 https://github.com/ChenYilong . All rights reserved.
//
//  [EN] Swift translation of ViewController.h/.m. Reproduces issues #2, #3 and #6 (instructions.md): every pull to
//  refresh toggles between five random rows and an empty table; an empty `cyl_reloadData()` asks
//  `makePlaceHolderView()` (CYLTableViewPlaceHolderDelegate), which picks one of two custom placeholders at random.
//  [CN] ViewController.h/.m 的 Swift 版本，复现 #2、#3、#6：下拉刷新在 5 行随机数据与空表之间切换，
//  空表时 `makePlaceHolderView()` 随机返回两种自定义占位图之一。
//

import UIKit
import CYLTableViewPlaceHolder

final class CYLExampleViewController: UITableViewController, CYLTableViewPlaceHolderDelegate,
                                      CYLWeChatStylePlaceHolderDelegate {

    private static let duration: TimeInterval = 1.0
    private static let cellIdentifier = "cell"

    private var dataSource: [Int] = []

    private var isNoResult: Bool {
        dataSource.isEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // The library's name, a technical identifier, not translated.
        title = "CYLTableViewPlaceHolder"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: CYLPlaceholderExampleLocalizedString(.actionAuto),
                                                            style: .plain, target: self,
                                                            action: #selector(showPlaceholderDemo))
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = .yellow
        dataSource = []
        setUpCYLRefresh()
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellIdentifier)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.cyl_reloadData()
    }

    @objc private func showPlaceholderDemo() {
        navigationController?.pushViewController(CYLPlaceholderDemoViewController(), animated: true)
    }

    private func setUpCYLRefresh() {
        // [EN] The refreshing block runs as soon as the header enters the refreshing state.
        // [CN] 设置回调（一旦进入刷新状态就会调用这个 refreshingBlock）
        tableView.cyl_header = CYLRefreshNormalHeader { [weak self] in
            self?.loadNewData()
        }
        // [EN] Start refreshing right away. [CN] 马上进入刷新状态
        tableView.cyl_header?.beginRefreshing()
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier)
            ?? UITableViewCell(style: .default, reuseIdentifier: Self.cellIdentifier)
        cell.textLabel?.text = CYLPlaceholderExampleLocalizedFormat(.formatRandomData, dataSource[indexPath.row])
        cell.textLabel?.numberOfLines = 0
        return cell
    }

    // MARK: - Pull to refresh

    private func loadNewData() {
        if !isNoResult {
            dataSource = []
        } else {
            // [EN] 1. Add fake data. [CN] 1.添加假数据
            for _ in 0..<5 {
                dataSource.insert(Int.random(in: 0..<1_000_000), at: 0)
            }
        }
        // [EN] 2. Simulate a one-second request before updating the table (remove the delay in a real app).
        // [CN] 2.模拟1秒后刷新表格UI（真实开发中，可以移除这段延时代码）
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.duration) { [weak self] in
            guard let self = self else { return }
            // [EN] Reload the table, then end the header's refreshing state. [CN] 刷新表格，结束刷新状态
            self.tableView.cyl_reloadData()
            self.tableView.cyl_header?.endRefreshing()
        }
    }

    // MARK: - CYLTableViewPlaceHolderDelegate

    @objc(makePlaceHolderView)
    func makePlaceHolderView() -> UIView {
        Bool.random() ? taoBaoStylePlaceHolder() : weChatStylePlaceHolder()
    }

    private func taoBaoStylePlaceHolder() -> UIView {
        CYLXTNetReloader(frame: .zero) { [weak self] in
            self?.tableView.cyl_header?.beginRefreshing()
        }
    }

    private func weChatStylePlaceHolder() -> UIView {
        let weChatStylePlaceHolder = CYLWeChatStylePlaceHolder(frame: tableView.frame)
        weChatStylePlaceHolder.delegate = self
        return weChatStylePlaceHolder
    }

    // MARK: - CYLWeChatStylePlaceHolderDelegate

    func emptyOverlayClicked(_ sender: Any?) {
        tableView.cyl_header?.beginRefreshing()
    }
}
