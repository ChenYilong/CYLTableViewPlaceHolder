//
//  CYLRiveRoomsViewController.swift
//  Example-Scenarios
//
//  The Rive Home icon (house.riv) as a placeholder, driven by its state machine number input Rooms.
//

import UIKit
import CYLTableViewPlaceHolder

/// house.riv as a placeholder: its "State Machine 1" moves only when the number input Rooms changes. The placeholder is
/// built with CYLAnimatedItem's Rive options numberInput=Rooms and values=3,4,5,6, so each play sets the next value.
/// A picker and a slider set Rooms by hand (as many plays as steps to the chosen value); the loop switch plays it every
/// 1.5 s, as the library loop does (`animationRepeatCount = 0`), and the label, picker and slider follow the number.
final class CYLRiveRoomsViewController: UIViewController {

    static let fileName = "CYLScenarioExampleHouse.riv"
    /// The values the placeholder steps through (the `values` option); Rooms starts at 3 in the file.
    private static let rooms: [Int] = [3, 4, 5, 6]
    /// One loop pass, CYLRiveTabBarItemAnimationConfiguration.loopSeconds.
    private static let loopSeconds: TimeInterval = 1.5

    private let path: String
    private var placeholder: CYLPlaceholderStackView?
    private var current = CYLRiveRoomsViewController.rooms[0]
    private var loopTimer: Timer?
    private let valueLabel = UILabel()
    private let picker = UISegmentedControl(items: CYLRiveRoomsViewController.rooms.map(String.init))
    private let slider = UISlider()
    private let loopSwitch = UISwitch()

    init(path: String) {
        self.path = path
        super.init(nibName: nil, bundle: nil)
        title = CYLScenarioLocalizedString(.riveRoomsTitle)
        hidesBottomBarWhenPushed = true
        navigationItem.largeTitleDisplayMode = .never
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let component = CYLPlaceholderComponent(attributes: [
            CYLPlaceholderItemTitle: CYLScenarioLocalizedString(.riveRoomsPlaceholder),
            CYLPlaceholderItemStyle: CYLPlaceholderStyle.image.rawValue,
            CYLPlaceholderItemAnimationFilePath: path,
            CYLPlaceholderItemAnimationSize: [220, 220],
            CYLPlaceholderItemAnimationRepeatCount: 1,
            CYLPlaceholderItemAnimationOptions: [
                "stateMachine": "State Machine 1",
                "numberInput": "Rooms",
                "values": CYLRiveRoomsViewController.rooms.map(String.init).joined(separator: ","),
            ],
        ], action: nil)
        let placeholder = CYLPlaceholderStackView(components: [component], actions: nil)
        // No play on appearing: a play sets the next value, and the page starts at Rooms 3, the file's own value.
        placeholder.placeholderView.stopPlaceholderAnimation()
        self.placeholder = placeholder

        valueLabel.font = .preferredFont(forTextStyle: .title1)
        valueLabel.adjustsFontForContentSizeCategory = true
        valueLabel.textAlignment = .center
        valueLabel.accessibilityTraits = .updatesFrequently

        picker.accessibilityLabel = CYLScenarioLocalizedString(.riveRoomsPicker)
        picker.addTarget(self, action: #selector(pickerChanged), for: .valueChanged)

        slider.minimumValue = Float(CYLRiveRoomsViewController.rooms.first!)
        slider.maximumValue = Float(CYLRiveRoomsViewController.rooms.last!)
        slider.accessibilityLabel = CYLScenarioLocalizedString(.riveRoomsSlider)
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)

        let loopLabel = UILabel()
        loopLabel.text = CYLScenarioLocalizedString(.riveRoomsLoop)
        loopLabel.font = .preferredFont(forTextStyle: .body)
        loopLabel.adjustsFontForContentSizeCategory = true
        loopLabel.isAccessibilityElement = false
        loopSwitch.accessibilityLabel = CYLScenarioLocalizedString(.riveRoomsLoop)
        loopSwitch.accessibilityIdentifier = "cyl-rive-rooms-loop"
        loopSwitch.addTarget(self, action: #selector(loopChanged), for: .valueChanged)
        let loopRow = UIStackView(arrangedSubviews: [loopLabel, UIView(), loopSwitch])

        let hint = UILabel()
        hint.text = CYLScenarioLocalizedString(.riveRoomsHint)
        hint.font = .preferredFont(forTextStyle: .footnote)
        hint.adjustsFontForContentSizeCategory = true
        hint.textColor = .secondaryLabel
        hint.numberOfLines = 0

        let controls = UIStackView(arrangedSubviews: [valueLabel, picker, slider, loopRow, hint])
        controls.axis = .vertical
        controls.spacing = 16
        let stack = UIStackView(arrangedSubviews: [placeholder, controls])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: guide.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: guide.bottomAnchor, constant: -16),
            placeholder.heightAnchor.constraint(equalToConstant: 300),
        ])
        showCurrent()
        if ProcessInfo.processInfo.arguments.contains("-CYLRiveRoomsLoop") {
            loopSwitch.isOn = true
            loopChanged()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        loopTimer?.invalidate()
        loopTimer = nil
        loopSwitch.isOn = false
    }

    /// Sets Rooms to `value`: one play per step, since each play sets the next of 3, 4, 5, 6.
    private func setRooms(_ value: Int) {
        let rooms = CYLRiveRoomsViewController.rooms
        guard let from = rooms.firstIndex(of: current), let to = rooms.firstIndex(of: value) else { return }
        let steps = (to - from + rooms.count) % rooms.count
        for _ in 0..<steps {
            placeholder?.placeholderView.playPlaceholderAnimation()
        }
        current = value
        showCurrent()
    }

    /// The label, picker and slider show the current number.
    private func showCurrent() {
        valueLabel.text = CYLScenarioLocalizedFormat(.riveRoomsValue, String(current))
        picker.selectedSegmentIndex = CYLRiveRoomsViewController.rooms.firstIndex(of: current) ?? 0
        slider.value = Float(current)
        slider.accessibilityValue = String(current)
    }

    @objc private func pickerChanged() {
        setRooms(CYLRiveRoomsViewController.rooms[picker.selectedSegmentIndex])
    }

    @objc private func sliderChanged() {
        let value = Int(slider.value.rounded())
        if value != current {
            setRooms(value)
        } else {
            slider.value = Float(value)
        }
    }

    /// Loop on: one play every pass, the next value each time; the controls follow.
    @objc private func loopChanged() {
        loopTimer?.invalidate()
        loopTimer = nil
        guard loopSwitch.isOn else { return }
        loopTimer = Timer.scheduledTimer(withTimeInterval: CYLRiveRoomsViewController.loopSeconds, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let rooms = CYLRiveRoomsViewController.rooms
            let index = rooms.firstIndex(of: self.current) ?? 0
            self.setRooms(rooms[(index + 1) % rooms.count])
        }
    }
}
