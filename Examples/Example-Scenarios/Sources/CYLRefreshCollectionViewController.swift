//
//  CYLRefreshCollectionViewController.swift
//  Example-Scenarios
//
//  MJCollectionViewController, MJPinHeaderCollectionViewController and MJHorizontalCollectionViewController of
//  MJRefresh's example layer (MIT; originally created by MJ Lee, Copyright (c) 2015 小码哥), transcribed to Swift on
//  this project's API (`MJ` → `CYL`, `mj_` → `cyl_`): example31 (pull down and up), example42 (pull left, the trailer)
//  and, beyond MJRefresh, example32 (the same collection with animated icons).
//

import UIKit
import CYLTableViewPlaceHolder

private let CYLRefreshCollectionDuration: TimeInterval = 2.0

class CYLRefreshCollectionViewController: UICollectionViewController, CYLRefreshExampleRunning {

    var method = ""
    /// The fake data
    private var colors: [UIColor] = []

    // MARK: - Examples

    /// UICollectionView: pull down and up
    func example31() {
        // Pull down
        CYLRefreshNormalHeader { [weak self] in
            // Ten fake items
            for _ in 0..<10 {
                self?.colors.insert(CYLRefreshRandomColor(), at: 0)
            }
            // A delayed load, so the refresh ends 2 seconds later (remove the delay in a real app)
            DispatchQueue.main.asyncAfter(deadline: .now() + CYLRefreshCollectionDuration) {
                self?.collectionView.reloadData()
                self?.collectionView.cyl_header?.endRefreshing()
            }
        }.cyl_link(to: collectionView)
        collectionView.cyl_header?.isCollectionViewAnimationBug = true

        // Pull up, the short way
        CYLRefreshBackNormalFooter { [weak self] in
            for _ in 0..<5 {
                self?.colors.append(CYLRefreshRandomColor())
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + CYLRefreshCollectionDuration) {
                self?.collectionView.performBatchUpdates({
                    self?.collectionView.reloadSections(IndexSet(integer: 0))
                }, completion: { _ in
                    self?.collectionView.cyl_footer?.endRefreshing()
                })
            }
        }.setAnimationDisabled().cyl_autoChangeTransparency(true).cyl_link(to: collectionView)

        collectionView.cyl_header?.beginRefreshing()
    }

    /// Beyond MJRefresh: the same collection with animated icons (a Lottie header, a GIF back footer).
    func example32() {
        let header = CYLRefreshAnimationHeader { [weak self] in
            for _ in 0..<10 {
                self?.colors.insert(CYLRefreshRandomColor(), at: 0)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + CYLRefreshCollectionDuration) {
                self?.collectionView.reloadData()
                self?.collectionView.cyl_header?.endRefreshing()
            }
        }
        header.setIconAnimation(bundled: "CYLRefreshCounterClockwise.json", size: CGSize(width: 28, height: 28),
                                for: .idle)
        header.setIconAnimation(bundled: "CYLRefreshGradientSpinner.json", size: CGSize(width: 32, height: 32),
                                for: .refreshing)
        header.cyl_link(to: collectionView)
        header.isCollectionViewAnimationBug = true

        let footer = CYLRefreshBackAnimationFooter { [weak self] in
            for _ in 0..<5 {
                self?.colors.append(CYLRefreshRandomColor())
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + CYLRefreshCollectionDuration) {
                self?.collectionView.reloadData()
                self?.collectionView.cyl_footer?.endRefreshing()
            }
        }
        footer.setIconAnimation(bundled: "CYLRefreshActivity.gif", size: CGSize(width: 28, height: 28), for: .idle)
        footer.cyl_autoChangeTransparency(true).cyl_link(to: collectionView)

        header.beginRefreshing()
    }

    // MARK: - Other

    /// The flow layout (unrelated to the refresh controls).
    static func makeLayout(_ layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()) -> UICollectionViewFlowLayout {
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 20
        layout.headerReferenceSize = CGSize(width: 100, height: 30)
        return layout
    }

    init(layout: UICollectionViewFlowLayout = CYLRefreshCollectionViewController.makeLayout()) {
        super.init(collectionViewLayout: layout)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .systemBackground
        collectionView.accessibilityIdentifier = "refreshCollection"
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "color")
        collectionView.register(UICollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "header")
        switch method {
        case "example31": example31()
        case "example32": example32()
        default: break
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Show the footer only when there is something to load after
        collectionView.cyl_footer?.isHidden = colors.isEmpty
        return colors.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "color", for: indexPath)
        cell.backgroundColor = colors[indexPath.item]
        cell.isAccessibilityElement = true
        cell.accessibilityTraits = .button
        cell.accessibilityLabel = CYLScenarioLocalizedString(indexPath.item % 2 == 1 ? .mjPush : .mjModal)
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                   withReuseIdentifier: "header", for: indexPath)
        view.backgroundColor = .systemPurple
        return view
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        CYLRefreshTestViewController.show(from: self, row: indexPath.item)
    }
}

/// MJPinHeaderCollectionViewController: the same page on a layout whose header attributes are its own.
final class CYLRefreshPinHeaderCollectionViewController: CYLRefreshCollectionViewController {
    init() {
        super.init(layout: CYLRefreshCollectionViewController.makeLayout(CYLRefreshPinHeaderFlowLayout()))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
}

/// PinHeaderFlowLayout (its pinning is a TODO in MJRefresh too).
final class CYLRefreshPinHeaderFlowLayout: UICollectionViewFlowLayout {
    override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        true
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String,
                                                       at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                         with: indexPath)
    }
}

/// MJHorizontalCollectionViewController: pages that swipe left; pulling past the last one opens a page.
final class CYLRefreshHorizontalCollectionViewController: UICollectionViewController, CYLRefreshExampleRunning {

    var method = ""
    private let colors: [UIColor] = (0..<5).map { _ in CYLRefreshRandomColor() }

    /// UICollectionView: pull left
    func example42() {
        collectionView.cyl_trailer = CYLRefreshNormalTrailer { [weak self] in
            guard let self = self else { return }
            self.navigationController?.pushViewController(CYLRefreshTestViewController(), animated: true)
            self.collectionView.cyl_trailer?.endRefreshing()
        }
    }

    init() {
        // The flow layout (unrelated to the refresh controls)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 200)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        super.init(collectionViewLayout: layout)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        collectionView.frame = CGRect(x: 0, y: 150, width: UIScreen.main.bounds.width, height: 200)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .systemBackground
        collectionView.accessibilityIdentifier = "refreshHorizontalCollection"
        if method == "example42" {
            example42()
        }
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "color")
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        colors.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "color", for: indexPath)
        cell.backgroundColor = colors[indexPath.item]
        cell.isAccessibilityElement = true
        cell.accessibilityTraits = .button
        cell.accessibilityLabel = CYLScenarioLocalizedString(indexPath.item % 2 == 1 ? .mjPush : .mjModal)
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        CYLRefreshTestViewController.show(from: self, row: indexPath.item)
    }
}
