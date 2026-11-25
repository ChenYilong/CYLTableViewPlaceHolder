//
//  CYLTagListScreen.swift
//  Example-Scenarios
//
//  A sectioned index screen drawn with CollectionViewClassifyMenu's tag list (`CYLTagListView`) instead of a grouped
//  table (docs/instructions/examples.md, "Sectioned lists in demos use the tag list"): one tag list, one section per
//  group, the section title is the header, a tag shows the main title and the icon only, a long section folds behind
//  the core's More control at the trailing edge of the section header (`.headerTrailing`, "More" and the chevron; expanded,
//  the chevron turned), a tap does what the replaced row did and leaves nothing selected, and a long press
//  shows the secondary line in the tag list's own callout (`menuSubtitleForItem`, `CYLTagLongPressActions.callout`).
//  Examples only: the library itself does not depend on CollectionViewClassifyMenu.
//

import UIKit
import CollectionViewClassifyMenu

/// One tag of a sectioned index screen: its title, the secondary line shown in the callout, the row icon and the tap.
struct CYLTagEntry {
    let title: String
    /// Shown only by a long press, in the tag list's callout; nil shows no callout.
    var subtitle: String?
    /// An SF Symbol name; nil draws no icon.
    var symbol: String?
    var tint: UIColor = .systemTeal
    var accessibilityIdentifier: String?
    let action: () -> Void
}

/// One group of tags; `title` is the section header and is never empty.
struct CYLTagSection {
    let title: String
    let entries: [CYLTagEntry]
}

/// A soft diagonal gradient of four hues behind a tag list, so the Liquid Glass tags have something to refract; the colours
/// follow light and dark mode.
final class CYLTagListBackdropView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        let gradient = layer as! CAGradientLayer
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        updateColors()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        updateColors()
    }

    private func updateColors() {
        let dark = traitCollection.userInterfaceStyle == .dark
        let colors: [UIColor] = dark
            ? [UIColor(red: 0.20, green: 0.10, blue: 0.40, alpha: 1), UIColor(red: 0.05, green: 0.25, blue: 0.45, alpha: 1),
               UIColor(red: 0.05, green: 0.35, blue: 0.30, alpha: 1), UIColor(red: 0.45, green: 0.15, blue: 0.25, alpha: 1)]
            : [UIColor(red: 0.80, green: 0.72, blue: 1.00, alpha: 1), UIColor(red: 0.62, green: 0.84, blue: 1.00, alpha: 1),
               UIColor(red: 0.65, green: 0.95, blue: 0.82, alpha: 1), UIColor(red: 1.00, green: 0.78, blue: 0.80, alpha: 1)]
        (layer as! CAGradientLayer).colors = colors.map { $0.cgColor }
    }
}

/// Base class of the sectioned index screens: set `sections` (before the view loads or later, then `reloadSections()`).
class CYLTagListScreenViewController: UIViewController, CYLMenuDataSource, CYLMenuDelegate {

    /// Rows of tags a section shows before the core's More control; a longer section folds.
    static let defaultVisibleRows = 3
    /// The most lines a tag title wraps onto, the app's choice (the placeholder example uses 3).
    static let titleMaxLines = 3

    var sections: [CYLTagSection] = []
    /// Shown instead of the list while there is no section, should the bundle be missing.
    var emptyView: UIView?

    let tagList = CYLTagListView(foldControl: CYLMenuFoldControl(position: .headerTrailing, content: .iconAndTitle))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        // Glass shows what is behind it: a plain grouped background makes it look like the flat tag, so a soft colourful
        // gradient sits behind the list (examples only; the tag list itself stays transparent).
        let backdrop = CYLTagListBackdropView()
        backdrop.frame = view.bounds
        backdrop.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(backdrop)
        let style = tagList.style
        // 0 items per row: a tag is as wide as its content and a row holds as many tags as fit.
        style.numberOfItemsPerRow = 0
        style.titleMaxLines = Self.titleMaxLines
        // The one Liquid Glass parameter (docs/tag-liquid-glass.md of CollectionViewClassifyMenu): glass where the system
        // draws it (iOS 27 and later, iOS 26 without `UIDesignRequiresCompatibility`), the flat tag elsewhere.
        style.backgroundStyle = .liquidGlass
        style.backgroundColor = .clear
        tagList.style = style
        tagList.defaultVisibleRows = Self.defaultVisibleRows
        // A tap reports through the delegate and leaves the tag unselected.
        tagList.selectionMode = .none
        // A long press shows the secondary line in the list's callout with an arrow.
        tagList.longPressAction = CYLTagLongPressActions.callout
        tagList.menuDataSource = self
        tagList.menuDelegate = self
        tagList.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tagList)
        let guide = view.safeAreaLayoutGuide
        bottomConstraint = tagList.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        NSLayoutConstraint.activate([
            tagList.topAnchor.constraint(equalTo: guide.topAnchor),
            bottomConstraint!,
            tagList.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            tagList.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
        ])
        reloadSections()
    }

    /// The bulge of the raised plus button above the floating tab bar, in points.
    private static let plusButtonBulge: CGFloat = 40
    private var bottomConstraint: NSLayoutConstraint?

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // The floating tab bar and the plus button float over the view and are not in the bottom safe area: end the list
        // above them, so the last row is never covered.
        // A screen pushed above a root hides the tab bar, then nothing is covered.
        let isRoot = navigationController.map { $0.viewControllers.first === self } ?? true
        var inset: CGFloat = 0
        if isRoot, let tabBar = tabBarController?.tabBar, !tabBar.isHidden, tabBar.window != nil {
            let overlap = view.bounds.maxY - view.convert(tabBar.bounds, from: tabBar).minY
            inset = max(0, overlap + Self.plusButtonBulge - view.safeAreaInsets.bottom)
        }
        if bottomConstraint?.constant != -inset { bottomConstraint?.constant = -inset }
    }

    /// Reloads the tag list after `sections` changed, and swaps in `emptyView` while there is nothing to list.
    func reloadSections() {
        tagList.reloadMenuData()
        guard let emptyView = emptyView else { return }
        if sections.isEmpty, emptyView.superview == nil {
            emptyView.frame = view.bounds
            emptyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(emptyView)
        } else if !sections.isEmpty {
            emptyView.removeFromSuperview()
        }
    }

    // MARK: - CYLMenuDataSource

    func numberOfSectionsInMenu() -> Int {
        sections.count
    }

    func menuNumberOfItems(inSection section: Int) -> Int {
        sections[section].entries.count
    }

    func menuTitle(forSection section: Int) -> String {
        sections[section].title
    }

    func menuTitleForItem(at indexPath: IndexPath) -> String {
        entry(at: indexPath).title
    }

    func menuSubtitleForItem(at indexPath: IndexPath) -> String? {
        entry(at: indexPath).subtitle
    }

    func menuImageForItem(at indexPath: IndexPath) -> UIImage? {
        let entry = entry(at: indexPath)
        // System image on a tag: a row icon, not a placeholder, so CYLPlaceholderView does not apply.
        return entry.symbol.flatMap { UIImage(systemName: $0) }?.withTintColor(entry.tint, renderingMode: .alwaysOriginal)
    }

    func menuIdentifierForItem(at indexPath: IndexPath) -> String {
        entry(at: indexPath).accessibilityIdentifier ?? "tag-\(indexPath.section)-\(indexPath.item)"
    }

    // MARK: - CYLMenuDelegate

    func menu(_ menu: Any, didSelectItemAt indexPath: IndexPath) {
        entry(at: indexPath).action()
    }

    private func entry(at indexPath: IndexPath) -> CYLTagEntry {
        sections[indexPath.section].entries[indexPath.item]
    }
}
