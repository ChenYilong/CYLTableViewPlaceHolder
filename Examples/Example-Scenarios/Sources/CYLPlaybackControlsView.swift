//
//  CYLPlaybackControlsView.swift
//  Example-Scenarios
//
//  The playback controls of docs/Example-Animation-Playback.md for one page: "Play all" (restart from progress 0),
//  a loop switch and a speed slider (0.25x to 3x, steps of 0.25x, the value shown next to it). The view only reports
//  the user's choices; the page applies them through the core (`playPlaceholderAnimation()`,
//  `animationRepeatCount`, `setPlaceholderAnimationSpeed(_:)`).
//

import UIKit
import CYLTableViewPlaceHolder

final class CYLPlaybackControlsView: UIView {

    static let minimumSpeed: Float = 0.25
    static let maximumSpeed: Float = 3
    static let speedStep: Float = 0.25

    /// Called by "Play all".
    var onPlayAll: (() -> Void)?
    /// Called with the new speed while the slider moves (already rounded to a 0.25x step).
    var onSpeed: ((CGFloat) -> Void)?
    /// Called with the new loop setting.
    var onLoop: ((Bool) -> Void)?

    private(set) var speed: CGFloat = 1
    private(set) var loops: Bool

    private let playAllButton = UIButton(configuration: .filled())
    private let loopLabel = UILabel()
    private let loopSwitch = UISwitch()
    private let speedLabel = UILabel()
    private let speedSlider = UISlider()
    private let speedValueLabel = UILabel()

    /// Controls with the loop switch set to `loops` and the speed at 1x.
    init(loops: Bool) {
        self.loops = loops
        super.init(frame: .zero)
        playAllButton.configuration?.title = CYLScenarioLocalizedString(.playbackPlayAll)
        playAllButton.accessibilityIdentifier = "playbackPlayAll"
        playAllButton.addTarget(self, action: #selector(playAll), for: .touchUpInside)

        loopLabel.text = CYLScenarioLocalizedString(.playbackLoop)
        loopLabel.isAccessibilityElement = false
        loopSwitch.isOn = loops
        loopSwitch.accessibilityLabel = CYLScenarioLocalizedString(.playbackLoop)
        loopSwitch.accessibilityIdentifier = "playbackLoop"
        loopSwitch.addTarget(self, action: #selector(loopChanged), for: .valueChanged)

        speedLabel.text = CYLScenarioLocalizedString(.playbackSpeed)
        speedLabel.isAccessibilityElement = false
        speedSlider.minimumValue = Self.minimumSpeed
        speedSlider.maximumValue = Self.maximumSpeed
        speedSlider.value = 1
        speedSlider.accessibilityLabel = CYLScenarioLocalizedString(.playbackSpeed)
        speedSlider.accessibilityIdentifier = "playbackSpeed"
        speedSlider.addTarget(self, action: #selector(speedChanged), for: .valueChanged)
        speedValueLabel.font = .monospacedDigitSystemFont(ofSize: 17, weight: .regular)
        speedValueLabel.textAlignment = .right
        speedValueLabel.isAccessibilityElement = false
        updateSpeedText()

        let topRow = UIStackView(arrangedSubviews: [playAllButton, UIView(), loopLabel, loopSwitch])
        topRow.spacing = 8
        topRow.alignment = .center
        let speedRow = UIStackView(arrangedSubviews: [speedLabel, speedSlider, speedValueLabel])
        speedRow.spacing = 12
        speedRow.alignment = .center
        speedValueLabel.widthAnchor.constraint(equalToConstant: 56).isActive = true
        speedLabel.setContentHuggingPriority(.required, for: .horizontal)
        let column = UIStackView(arrangedSubviews: [topRow, speedRow])
        column.axis = .vertical
        column.spacing = 12
        column.translatesAutoresizingMaskIntoConstraints = false
        addSubview(column)
        NSLayoutConstraint.activate([
            column.topAnchor.constraint(equalTo: topAnchor),
            column.bottomAnchor.constraint(equalTo: bottomAnchor),
            column.leadingAnchor.constraint(equalTo: leadingAnchor),
            column.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    /// "1x", "1.5x", "0.25x".
    static func speedText(_ speed: CGFloat) -> String {
        let rounded = (speed * 100).rounded() / 100
        return rounded == rounded.rounded() ? "\(Int(rounded))x" : "\(rounded)x"
    }

    private func updateSpeedText() {
        let text = Self.speedText(speed)
        speedValueLabel.text = text
        speedSlider.accessibilityValue = text
    }

    @objc private func playAll() {
        onPlayAll?()
    }

    @objc private func loopChanged() {
        loops = loopSwitch.isOn
        onLoop?(loops)
    }

    /// Puts the controls above a table's rows as its header, driving the refresh controls' icons through the core
    /// (`CYLRefreshIconView.animationSpeed`, `loopsWhilePlaying`, `replayAnimation()`). Play all shows the refreshing
    /// icon from its first frame: an idle header refreshes again, then both icons replay (as the Android example).
    /// Call `sizeTableHeader(of:)` from `viewDidLayoutSubviews`.
    func installAsRefreshIconControls(in tableView: UITableView) {
        let icons: (UITableView?) -> [CYLRefreshIconView] = { table in
            [table?.cyl_header, table?.cyl_footer].compactMap { ($0 as? CYLRefreshIconAnimating)?.iconView }
        }
        onPlayAll = { [weak tableView] in
            if let header = tableView?.cyl_header, !header.isRefreshing { header.beginRefreshing() }
            icons(tableView).forEach { $0.replayAnimation() }
        }
        onSpeed = { [weak tableView] speed in icons(tableView).forEach { $0.animationSpeed = speed } }
        onLoop = { [weak tableView] loops in icons(tableView).forEach { $0.loopsWhilePlaying = loops } }
        let container = UIView()
        translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(self)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor),
            trailingAnchor.constraint(equalTo: container.layoutMarginsGuide.trailingAnchor),
        ])
        tableView.tableHeaderView = container
    }

    /// Sizes a table header to the table's width (not known in viewDidLoad); a header narrower than the table would
    /// leave the loop switch outside it, where it gets no touches.
    static func sizeTableHeader(of tableView: UITableView) {
        guard let header = tableView.tableHeaderView else { return }
        let width = tableView.bounds.width
        let height = header.systemLayoutSizeFitting(CGSize(width: width, height: 0),
                                                    withHorizontalFittingPriority: .required,
                                                    verticalFittingPriority: .fittingSizeLevel).height
        guard header.frame.width != width || header.frame.height != height else { return }
        header.frame = CGRect(x: 0, y: 0, width: width, height: height)
        tableView.tableHeaderView = header
    }

    @objc private func speedChanged() {
        let stepped = (speedSlider.value / Self.speedStep).rounded() * Self.speedStep
        speedSlider.value = stepped
        guard CGFloat(stepped) != speed else { return }
        speed = CGFloat(stepped)
        updateSpeedText()
        onSpeed?(speed)
    }
}
