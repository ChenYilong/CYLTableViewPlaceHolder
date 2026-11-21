//
//  CYLAnimationPlaybackControls.swift
//  Example-Scenarios
//
//  The playback controls of every page that shows animations (docs/Example-Animation-Playback.md): "Play all" restarts
//  the page's animations from progress 0, the speed slider (0.25x to 3x, steps of 0.25x) and the loop switch apply live
//  and combine. The page decides what they drive; the core does the work (`setPlaceholderAnimationSpeed`,
//  `animationRepeatCount`, `playPlaceholderAnimation`, and `CYLRefreshIconView`'s `animationSpeed`,
//  `animationRepeatCount` and `restartAnimation`).
//

import UIKit
import CYLTableViewPlaceHolder

final class CYLAnimationPlaybackControls: UIView {

    /// The current setting, read by the page when it builds a new animation.
    struct Setting: Equatable {
        var speed: CGFloat
        var loops: Bool
        /// The core's repeat count: 0 loops, 1 plays once.
        var repeatCount: Int { loops ? 0 : 1 }
    }

    static let speeds: ClosedRange<Float> = 0.25...3
    static let speedStep: Float = 0.25

    /// "Play all": restart every animation of the page from progress 0 with the current setting.
    var onPlayAll: ((Setting) -> Void)?
    /// The speed or the loop changed: apply it to the animations, live.
    var onChange: ((Setting) -> Void)?

    private(set) var setting: Setting

    private let playAllButton = UIButton(type: .system)
    private let speedTitle = UILabel()
    private let speedSlider = CYLPlaybackSpeedSlider()
    private let speedValue = UILabel()
    private let loopTitle = UILabel()
    private let loopSwitch = UISwitch()

    init(loops: Bool) {
        setting = Setting(speed: 1, loops: loops)
        super.init(frame: .zero)
        backgroundColor = .secondarySystemBackground
        accessibilityIdentifier = "animationPlaybackControls"

        playAllButton.setTitle(CYLScenarioLocalizedString(.playbackPlayAll), for: .normal)
        playAllButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        playAllButton.titleLabel?.adjustsFontForContentSizeCategory = true
        playAllButton.addTarget(self, action: #selector(playAll), for: .touchUpInside)
        playAllButton.accessibilityIdentifier = "playbackPlayAll"

        for label in [speedTitle, speedValue, loopTitle] {
            label.font = .preferredFont(forTextStyle: .body)
            label.adjustsFontForContentSizeCategory = true
        }
        speedTitle.text = CYLScenarioLocalizedString(.playbackSpeed)
        // The slider says "Speed" itself, with its value, so the visible title is not read twice.
        speedTitle.isAccessibilityElement = false
        speedValue.isAccessibilityElement = false
        speedValue.font = .monospacedDigitSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize,
                                                     weight: .regular)
        speedValue.setContentHuggingPriority(.required, for: .horizontal)

        speedSlider.minimumValue = Self.speeds.lowerBound
        speedSlider.maximumValue = Self.speeds.upperBound
        speedSlider.value = 1
        speedSlider.step = Self.speedStep
        speedSlider.accessibilityLabel = CYLScenarioLocalizedString(.playbackSpeed)
        speedSlider.accessibilityIdentifier = "playbackSpeed"
        speedSlider.addTarget(self, action: #selector(speedChanged), for: .valueChanged)

        loopTitle.text = CYLScenarioLocalizedString(.playbackLoop)
        loopTitle.isAccessibilityElement = false
        loopSwitch.isOn = loops
        loopSwitch.accessibilityLabel = CYLScenarioLocalizedString(.playbackLoop)
        loopSwitch.accessibilityIdentifier = "playbackLoop"
        loopSwitch.addTarget(self, action: #selector(loopChanged), for: .valueChanged)

        let loopRow = UIStackView(arrangedSubviews: [loopTitle, loopSwitch])
        loopRow.spacing = 8
        loopRow.alignment = .center
        let topRow = UIStackView(arrangedSubviews: [playAllButton, UIView(), loopRow])
        topRow.alignment = .center
        let speedRow = UIStackView(arrangedSubviews: [speedTitle, speedSlider, speedValue])
        speedRow.spacing = 12
        speedRow.alignment = .center
        let stack = UIStackView(arrangedSubviews: [topRow, speedRow])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            // The safe area: pinned to the bottom of a page, the background reaches the screen edge and the controls stay
            // above the home indicator.
            stack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
        ])
        updateSpeedText()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    /// The text of a speed, "1x", "1.25x", "0.5x".
    static func text(for speed: CGFloat) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        let number = formatter.string(from: NSNumber(value: Double(speed))) ?? "\(speed)"
        return CYLScenarioLocalizedFormat(.formatPlaybackSpeed, number)
    }

    private func updateSpeedText() {
        let text = Self.text(for: setting.speed)
        speedValue.text = text
        speedSlider.accessibilityValue = text
    }

    @objc private func playAll() {
        onPlayAll?(setting)
    }

    @objc private func speedChanged() {
        let stepped = (speedSlider.value / Self.speedStep).rounded() * Self.speedStep
        speedSlider.value = stepped
        guard CGFloat(stepped) != setting.speed else { return }
        setting.speed = CGFloat(stepped)
        updateSpeedText()
        onChange?(setting)
    }

    @objc private func loopChanged() {
        setting.loops = loopSwitch.isOn
        onChange?(setting)
    }

    /// The controls as a table header: the width of the table, the height Auto Layout needs.
    func sizedAsTableHeader(width: CGFloat) -> Self {
        frame = CGRect(x: 0, y: 0, width: width, height: 0)
        let size = systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
                                           withHorizontalFittingPriority: .required,
                                           verticalFittingPriority: .fittingSizeLevel)
        frame.size.height = ceil(size.height)
        return self
    }
}

/// A slider that VoiceOver and Switch Control move by one step (0.25x) instead of UIKit's 10 percent.
private final class CYLPlaybackSpeedSlider: UISlider {
    var step: Float = 0.25

    override func accessibilityIncrement() {
        value = min(maximumValue, value + step)
        sendActions(for: .valueChanged)
    }

    override func accessibilityDecrement() {
        value = max(minimumValue, value - step)
        sendActions(for: .valueChanged)
    }
}

/// The refresh controls of a scroll view whose icon is an animation (`CYLRefreshIconAnimating` with an icon set).
extension UIScrollView {

    private var animatedRefreshIcons: [CYLRefreshIconView] {
        [cyl_header as AnyObject?, cyl_footer as AnyObject?, cyl_trailer as AnyObject?]
            .compactMap { $0 as? CYLRefreshIconAnimating }
            .filter { $0.usesIconView }
            .map { $0.iconView }
    }

    /// YES when a header, footer or trailer draws an animated icon, so the page shows the playback controls.
    var hasAnimatedRefreshIcons: Bool {
        !animatedRefreshIcons.isEmpty
    }

    /// Speed and loop for every refresh icon, live; icons built later for another state keep them.
    func applyRefreshIconPlayback(_ setting: CYLAnimationPlaybackControls.Setting) {
        for icon in animatedRefreshIcons {
            icon.animationSpeed = setting.speed
            icon.animationRepeatCount = setting.repeatCount
        }
    }

    /// "Play all": a header at rest starts refreshing, which plays its icon from 0; otherwise every icon restarts.
    func restartRefreshIcons(_ setting: CYLAnimationPlaybackControls.Setting) {
        applyRefreshIconPlayback(setting)
        if let header = cyl_header, !header.isRefreshing {
            header.beginRefreshing()
        }
        animatedRefreshIcons.forEach { $0.restartAnimation() }
    }
}

/// Shows the playback controls as the table header of a list whose refresh icons are animations; nothing otherwise
/// (the arrow and spinner styles have no animation to control). Loop starts on: refresh icons are spinners.
func addPlaybackControls(to controller: UITableViewController) {
    let tableView = controller.tableView!
    guard tableView.hasAnimatedRefreshIcons else { return }
    let controls = CYLAnimationPlaybackControls(loops: true)
    controls.onPlayAll = { [weak tableView] setting in tableView?.restartRefreshIcons(setting) }
    controls.onChange = { [weak tableView] setting in tableView?.applyRefreshIconPlayback(setting) }
    let width = controller.view.bounds.width > 0 ? controller.view.bounds.width : UIScreen.main.bounds.width
    tableView.tableHeaderView = controls.sizedAsTableHeader(width: width)
    tableView.applyRefreshIconPlayback(controls.setting)
}
