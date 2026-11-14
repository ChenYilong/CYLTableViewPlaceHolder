//
//  CYLHUDViewController.swift
//  Example-Scenarios
//
//  The HUD style of the placeholder (`CYLPlaceholderHUD`, scenario `.hud`), with SVProgressHUD's API: show, show with
//  a status, a progress, success, error, info, an image, components with their own tap action, a scenario, stacked
//  shows balanced by `popActivity`, and dismiss. The "Look" rows cycle the style, the mask, the looping loading
//  animation (refresh animations of the core bundle) and haptics. The last row runs a page's whole life cycle:
//  the HUD while loading, the placeholder when it fails, CYLRefresh to refresh and load more.
//

import UIKit
import CYLTableViewPlaceHolder

final class CYLHUDViewController: UITableViewController {

    private enum Row: CaseIterable {
        case show, showStatus, showProgress, success, error, info, image, components, scenario, popActivity, dismiss
        case style, mask, animation, haptics
        case lifecycle

        var section: Int {
            switch self {
            case .style, .mask, .animation, .haptics: return 1
            case .lifecycle: return 2
            default: return 0
            }
        }
    }

    private let hud = CYLPlaceholderHUD.shared
    private let styles: [(CYLPlaceholderHUDStyle, CYLScenarioL10n)] = [
        (.automatic, .hudStyleAutomatic), (.light, .hudStyleLight), (.dark, .hudStyleDark), (.custom, .hudStyleCustom),
    ]
    private let masks: [(CYLPlaceholderHUDMaskType, CYLScenarioL10n)] = [
        (.none, .hudMaskNone), (.clear, .hudMaskClear), (.black, .hudMaskBlack), (.gradient, .hudMaskGradient),
        (.custom, .hudStyleCustom),
    ]
    /// The loading animations that suit the HUD, one per format: the scenario's own GIF, then Lottie, PAG and Rive.
    private let animations = CYLPlaceholderScenarioCatalog.animationFileNames(for: .hud)
    private var styleIndex = 0
    private var maskIndex = 0
    private var animationIndex = 0
    private var progressTimer: Timer?

    init() {
        super.init(style: .insetGrouped)
        title = CYLScenarioLocalizedString(.titleHUD)
        hidesBottomBarWhenPushed = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.accessibilityIdentifier = "hudDemo"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "hud")
        hud.minimumDismissTimeInterval = 1.5
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        progressTimer?.invalidate()
        hud.dismiss()
    }

    private func rows(in section: Int) -> [Row] {
        Row.allCases.filter { $0.section == section }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows(in: section).count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        CYLScenarioLocalizedString([.hudSectionShow, .hudSectionLook, .hudSectionLifecycle][section])
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hud", for: indexPath)
        let row = rows(in: indexPath.section)[indexPath.row]
        var content = UIListContentConfiguration.valueCell()
        content.text = title(of: row)
        content.secondaryText = value(of: row)
        cell.contentConfiguration = content
        cell.accessoryType = row == .lifecycle ? .disclosureIndicator : .none
        cell.accessibilityTraits = .button
        return cell
    }

    private func title(of row: Row) -> String {
        switch row {
        case .show: return CYLScenarioLocalizedString(.hudShow)
        case .showStatus: return CYLScenarioLocalizedString(.hudShowStatus)
        case .showProgress: return CYLScenarioLocalizedString(.hudShowProgress)
        case .success: return CYLScenarioLocalizedString(.hudShowSuccess)
        case .error: return CYLScenarioLocalizedString(.hudShowError)
        case .info: return CYLScenarioLocalizedString(.hudShowInfo)
        case .image: return CYLScenarioLocalizedString(.hudShowImage)
        case .components: return CYLScenarioLocalizedString(.hudShowComponents)
        case .scenario: return CYLScenarioLocalizedString(.hudShowScenario)
        case .popActivity: return CYLScenarioLocalizedString(.hudPopActivity)
        case .dismiss: return CYLScenarioLocalizedString(.hudDismiss)
        case .style: return CYLScenarioLocalizedString(.hudStyle)
        case .mask: return CYLScenarioLocalizedString(.hudMask)
        case .animation: return CYLScenarioLocalizedString(.hudAnimation)
        case .haptics: return CYLScenarioLocalizedString(.hudHaptics)
        case .lifecycle: return CYLScenarioLocalizedString(.hudLifecycle)
        }
    }

    private func value(of row: Row) -> String? {
        switch row {
        case .style: return CYLScenarioLocalizedString(styles[styleIndex].1)
        case .mask: return CYLScenarioLocalizedString(masks[maskIndex].1)
        case .animation: return animations.isEmpty ? nil : animations[animationIndex]
        case .haptics: return hud.isHapticsEnabled ? "✓" : "–"
        default: return nil
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = rows(in: indexPath.section)[indexPath.row]
        progressTimer?.invalidate()
        switch row {
        case .show:
            hud.show()
            hud.dismiss(withDelay: 2)
        case .showStatus:
            hud.show(status: CYLScenarioLocalizedString(.hudStatusLoading))
            hud.dismiss(withDelay: 2)
        case .showProgress:
            showProgress()
        case .success:
            hud.showSuccess(status: CYLScenarioLocalizedString(.hudStatusSaved))
        case .error:
            hud.showError(status: CYLScenarioLocalizedString(.hudStatusFailed))
        case .info:
            hud.showInfo(status: CYLScenarioLocalizedString(.hudStatusInfo))
        case .image:
            if let image = CYLPlaceholderView.image(for: .cloud) {
                hud.show(image: image, status: CYLScenarioLocalizedString(.hudStatusImage))
            }
        case .components:
            showComponents()
        case .scenario:
            hud.show(scenario: .uploading, actions: nil)
            hud.dismiss(withDelay: 2)
        case .popActivity:
            // Three tasks start; the HUD stays until the last one ends.
            for _ in 0..<3 {
                hud.show(status: CYLScenarioLocalizedString(.hudStatusLoading))
            }
            for delay in [1.0, 2.0, 3.0] {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                    self?.hud.popActivity()
                }
            }
        case .dismiss:
            hud.dismiss()
        case .style:
            styleIndex = (styleIndex + 1) % styles.count
            if styles[styleIndex].0 == .custom {
                hud.foregroundColor = .white
                hud.hudBackgroundColor = .systemTeal
            } else {
                hud.foregroundColor = nil
                hud.hudBackgroundColor = nil
                hud.style = styles[styleIndex].0
            }
            showPreview()
        case .mask:
            maskIndex = (maskIndex + 1) % masks.count
            hud.maskType = masks[maskIndex].0
            hud.backgroundLayerColor = UIColor.systemTeal.withAlphaComponent(0.3)
            showPreview()
        case .animation:
            guard !animations.isEmpty else { return }
            animationIndex = (animationIndex + 1) % animations.count
            hud.loadingAnimationFileName = animations[animationIndex]
            showPreview()
        case .haptics:
            hud.isHapticsEnabled.toggle()
            hud.showSuccess(status: CYLScenarioLocalizedString(.hudStatusSaved))
        case .lifecycle:
            navigationController?.pushViewController(CYLHUDLifecycleViewController(), animated: true)
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    /// Shows the loading HUD for a moment, so a changed look can be seen.
    private func showPreview() {
        hud.show(status: CYLScenarioLocalizedString(.hudStatusLoading))
        hud.dismiss(withDelay: 1.5)
    }

    /// A progress from 0 to 1 in two seconds, then success.
    private func showProgress() {
        var progress: CGFloat = 0
        hud.show(progress: 0, status: CYLScenarioLocalizedString(.hudStatusDownloading))
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else { return timer.invalidate() }
            progress += 0.05
            if progress >= 1 {
                timer.invalidate()
                self.hud.showSuccess(status: CYLScenarioLocalizedString(.hudStatusSaved))
            } else {
                self.hud.show(progress: progress, status: CYLScenarioLocalizedString(.hudStatusDownloading))
            }
        }
    }

    /// The HUD scenario's components plus a "Cancel" button: every component of the box can have a tap action.
    private func showComponents() {
        let cancel = CYLPlaceholderAction(rawValue: "cancel")
        let components = CYLPlaceholderScenarioCatalog.components(for: .hud) + [
            CYLPlaceholderComponent.button(title: CYLScenarioLocalizedString(.hudCancel), style: .outlined,
                                           action: cancel),
        ]
        hud.show(components: components, actions: [
            cancel: { [weak self] _, _ in
                self?.hud.showInfo(status: CYLScenarioLocalizedString(.hudCancelled))
            },
        ])
    }
}

/// A page's whole life cycle with the library's components: the HUD while the first page loads, the placeholder
/// (with "Retry") when it fails, CYLRefresh to refresh and to load more.
final class CYLHUDLifecycleViewController: UITableViewController {

    private var items: [Int] = []
    private var attempts = 0
    private lazy var hud: CYLPlaceholderHUD = {
        let hud = CYLPlaceholderHUD(containerView: view)
        hud.minimumDismissTimeInterval = 1
        return hud
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = CYLScenarioLocalizedString(.hudSectionLifecycle)
        tableView.accessibilityIdentifier = "hudLifecycle"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "item")
        // Failed: the placeholder with a "Retry" button, shown only while the list is empty.
        tableView.cyl_placeholderViewBlock({ [weak self] _ in
            CYLPlaceholderStackView(scenario: .retryButton, actions: [
                .retry: { _, _ in self?.loadFirstPage() },
            ])
        })
        // Loaded: pull down to refresh, pull up to load more.
        tableView.cyl_header = CYLRefreshNormalHeader { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.items = Array(1...15)
                self?.tableView.cyl_reloadData()
                self?.tableView.cyl_header?.endRefreshing()
                self?.tableView.cyl_footer?.resetNoMoreData()
            }
        }
        tableView.cyl_footer = CYLRefreshAutoNormalFooter { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                guard let self = self else { return }
                let next = self.items.count + 1
                self.items += Array(next..<(next + 10))
                self.tableView.cyl_reloadData()
                if self.items.count >= 45 {
                    self.tableView.cyl_footer?.endRefreshingWithNoMoreData()
                } else {
                    self.tableView.cyl_footer?.endRefreshing()
                }
            }
        }
        loadFirstPage()
    }

    /// The first attempt fails, the next succeeds, so every state of the cycle shows once.
    private func loadFirstPage() {
        attempts += 1
        hud.show(status: CYLScenarioLocalizedString(.hudStatusLoading))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            if self.attempts == 1 {
                self.hud.showError(status: CYLScenarioLocalizedString(.hudStatusFailed))
                self.items = []
            } else {
                self.hud.dismiss()
                self.items = Array(1...15)
            }
            self.tableView.cyl_reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = CYLScenarioLocalizedFormat(.hudLifecycleRow, items[indexPath.row])
        cell.contentConfiguration = content
        return cell
    }
}
