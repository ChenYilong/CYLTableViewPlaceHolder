//
//  CYLViewController.swift
//  Example-objc-01
//
//  Created by Jerry Jiang on 2022/9/30.
//

import UIKit
import CYLTableViewPlaceHolder

class CYLViewController: UIViewController {

    private lazy var refreshHeader = CYLRefreshNormalHeader { [weak self] in
        self?.title = "Refreshing"
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            guard let self = self else { return }
            self.collectionView.cyl_header?.endRefreshing()
            self.collectionView.reloadData()
            self.title = "Finished"
        }
    }

    private lazy var collectionView: UICollectionView = {
       let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .lightGray
        view.accessibilityIdentifier = "issue1575Collection"
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ready"
        collectionView.contentInset = .init(top: 32, left: 0, bottom: 0, right: 0)
        view.addSubview(collectionView)
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        collectionView.cyl_header = refreshHeader
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        extendLayout()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        NSLog("!!!%.20f", view.safeAreaInsets.top)
    }

    private func extendLayout() {
        if !edgesForExtendedLayout.contains(.top) {
            edgesForExtendedLayout.insert(.top)
        }

        extendedLayoutIncludesOpaqueBars = true
    }
}

extension CYLViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        50
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = UIColor
            .init(
                red: CGFloat(arc4random_uniform(255))/255.0,
                green: CGFloat(arc4random_uniform(255))/255.0,
                blue: CGFloat(arc4random_uniform(255))/255.0,
                alpha: 1.0)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewFlowLayout, preferredSizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: collectionView.frame.width, height: 40)
    }
}
