//  代码地址: https://github.com/ChenYilong/CYLTableViewPlaceHolder
//  CYLCollectionViewController.swift
//  Example-objc-02
//
//  Created by MJ Lee on 15/3/6.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//
//  Translated to Swift from the Objective-C original. Reproduces MJRefresh #1523, #1506 and #1483.
//

import UIKit
import CYLTableViewPlaceHolder

/// Simulated loading time of the header and footer.
private let CYLDuration: TimeInterval = 0.8
private let CYLCollectionViewCellIdentifier = "color"

final class CYLCollectionViewController: UICollectionViewController {
    /// Fake data.
    private var colors: [UIColor] = []
    private var headerRefreshCount = 0

    init() {
        // Flow layout (unrelated to the refresh controls).
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 20
        super.init(collectionViewLayout: layout)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: CYLCollectionViewCellIdentifier)
        collectionView.backgroundColor = .white
        collectionView.accessibilityIdentifier = "issue1523Collection"
        title = CYLObjC02LocalizedString(.titleCollection)
        setUpRefresh()
    }

    // MARK: - Pull down and pull up on a collection view

    private func setUpRefresh() {
        // 30 fake items.
        for _ in 0..<30 {
            colors.insert(Self.randomColor(), at: 0)
        }
        let header = CYLRefreshNormalHeader { [weak self] in
            self?.title = CYLObjC02LocalizedString(.titleHeaderRefreshing)
            // Simulated network delay; remove in a real app.
            DispatchQueue.main.asyncAfter(deadline: .now() + CYLDuration) { [weak self] in
                guard let self = self else { return }
                self.collectionView.reloadData()
                self.collectionView.cyl_header?.endRefreshing()
                self.headerRefreshCount += 1
                self.cyl_setStatusTitle(CYLObjC02LocalizedFormat(.formatHeaderCompleted, self.headerRefreshCount))
            }
        }
        collectionView.cyl_header = header
        header.isCollectionViewAnimationBug = true
        collectionView.cyl_footer = CYLRefreshBackNormalFooter { [weak self] in
            self?.title = CYLObjC02LocalizedString(.titleFooterRefreshing)
            DispatchQueue.main.asyncAfter(deadline: .now() + CYLDuration) { [weak self] in
                guard let self = self else { return }
                self.collectionView.reloadData()
                // `-noMoreData` (UI tests): the load returns nothing new and the footer shows "no more data".
                if ProcessInfo.processInfo.arguments.contains("-noMoreData") {
                    self.collectionView.cyl_footer?.endRefreshingWithNoMoreData()
                } else {
                    self.collectionView.cyl_footer?.endRefreshing()
                }
                self.cyl_setStatusTitle(CYLObjC02LocalizedString(.titleFooterCompleted))
            }
        }
    }

    private static func randomColor() -> UIColor {
        UIColor(red: CGFloat(Int.random(in: 0..<255)) / 255.0,
                green: CGFloat(Int.random(in: 0..<255)) / 255.0,
                blue: CGFloat(Int.random(in: 0..<255)) / 255.0,
                alpha: 1)
    }

    // MARK: - UICollectionViewDataSource

    @objc(collectionView:numberOfItemsInSection:)
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Show the footer only when there are items.
        collectionView.cyl_footer?.isHidden = colors.isEmpty
        return colors.count
    }

    @objc(collectionView:cellForItemAtIndexPath:)
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CYLCollectionViewCellIdentifier, for: indexPath)
        cell.backgroundColor = colors[indexPath.row]
        cell.isAccessibilityElement = true
        cell.accessibilityLabel = CYLObjC02LocalizedFormat(.formatItem, indexPath.row + 1)
        cell.accessibilityIdentifier = "item-\(indexPath.row)"
        return cell
    }
}

extension UIViewController {
    /// Shows a status in the navigation title and announces it to VoiceOver.
    func cyl_setStatusTitle(_ status: String) {
        title = status
        UIAccessibility.post(notification: .announcement, argument: status)
    }
}
