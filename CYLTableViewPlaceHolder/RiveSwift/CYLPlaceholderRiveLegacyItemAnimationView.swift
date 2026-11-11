//
//  CYLPlaceholderRiveLegacyItemAnimationView.swift
//  CYLTableViewPlaceHolder
//
//  Adapted from CYLTabBarController (`RiveSwift/CYLRiveLegacyTabBarItemAnimationView.swift`,
//  branch feat/cross-platform-components), MIT License,
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//
//  Rive files made before data binding have no view model: they are played
//  through state machine inputs or linear animations, which Rive keeps only in
//  its deprecated API. Chosen by `CYLPlaceholderRiveItemAnimationView` when the
//  options name an input, a trigger input, an animation, or `legacy=1`.
//  Placeholder addition: it pauses rendering while stopped.
//

#if canImport(RiveRuntime)
import UIKit
import RiveRuntime

@available(iOS 14.0, *)
@available(*, deprecated, message: "Wraps Rive's legacy API for .riv files without a view model.")
@objc(CYLPlaceholderRiveLegacyItemAnimationView)
public final class CYLPlaceholderRiveLegacyItemAnimationView: UIView, CYLPlaceholderItemAnimationPlayableView, CYLPlaceholderItemAnimationViewProviding {
    private let configuration: CYLPlaceholderRiveItemAnimationConfiguration
    private let viewModel: RiveViewModel
    /// [EN] How a named animation plays: `.autoLoop` follows the file. [CN] 具名动画的播放方式：`.autoLoop` 跟随文件设置。
    private var loop: RiveLoop = .autoLoop
    private var deactivateTask: Task<Void, Never>?

    @objc var cyl_inputActive: Bool {
        guard let input = configuration.stateMachineInput else { return false }
        return viewModel.boolInput(named: input)?.value() ?? false
    }
    @objc var cyl_isPlaying: Bool { viewModel.isPlaying }

    public static func makeAnimationView(fileURL: URL, options: [String: String], contentMode: UIView.ContentMode) -> (UIView & CYLPlaceholderItemAnimationPlayableView)? {
        let configuration = CYLPlaceholderRiveItemAnimationConfiguration(fileURL: fileURL, options: options)
        guard fileURL.isFileURL,
              let data = try? Data(contentsOf: fileURL),
              let file = try? RiveFile(data: data, loadCdn: false),
              isValid(configuration, in: file) else {
            return nil
        }
        let view = CYLPlaceholderRiveLegacyItemAnimationView(configuration: configuration, file: file)
        if let input = configuration.stateMachineInput, view.viewModel.boolInput(named: input) == nil {
            return nil
        }
        view.contentMode = contentMode
        return view
    }

    private static func isValid(_ configuration: CYLPlaceholderRiveItemAnimationConfiguration, in file: RiveFile) -> Bool {
        guard let artboard = try? (configuration.artboardName.map { try file.artboard(fromName: $0) } ?? file.artboard()) else {
            return false
        }
        if let animationName = configuration.animationName {
            return (try? artboard.animation(fromName: animationName)) != nil
        }
        if let stateMachineName = configuration.stateMachineName {
            return (try? artboard.stateMachine(fromName: stateMachineName)) != nil
        }
        return true
    }

    private init(configuration: CYLPlaceholderRiveItemAnimationConfiguration, file: RiveFile) {
        self.configuration = configuration
        let model = RiveModel(riveFile: file)
        if let animationName = configuration.animationName {
            viewModel = RiveViewModel(model, animationName: animationName, fit: .contain, alignment: .center,
                                      autoPlay: false, artboardName: configuration.artboardName)
        } else {
            viewModel = RiveViewModel(model, stateMachineName: configuration.stateMachineName, fit: .contain, alignment: .center,
                                      autoPlay: false, artboardName: configuration.artboardName)
        }
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        backgroundColor = .clear
        accessibilityElementsHidden = true
        let riveView = viewModel.createRiveView()
        riveView.frame = bounds
        riveView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        riveView.isUserInteractionEnabled = false
        riveView.backgroundColor = .clear
        addSubview(riveView)
    }

    public required init?(coder _: NSCoder) {
        return nil
    }

    override public var contentMode: UIView.ContentMode {
        didSet {
            switch contentMode {
            case .scaleToFill: viewModel.fit = .fill
            case .scaleAspectFill: viewModel.fit = .cover
            default: viewModel.fit = .contain
            }
        }
    }

    /// Plays the animation, fires the trigger, or sets the input to true (back to false after the duration, unless 0).
    public func playAnimation() {
        deactivateTask?.cancel()
        if let animationName = configuration.animationName {
            viewModel.play(animationName: animationName, loop: loop)
            return
        }
        viewModel.play()
        if let triggerInput = configuration.triggerInput {
            viewModel.triggerInput(triggerInput)
            return
        }
        guard let input = configuration.stateMachineInput else {
            return
        }
        viewModel.setInput(input, value: true)
        guard configuration.activeDuration > 0 else {
            return
        }
        let nanoseconds = UInt64(configuration.activeDuration * 1_000_000_000)
        deactivateTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: nanoseconds)
            guard !Task.isCancelled, let self else {
                return
            }
            self.viewModel.setInput(input, value: false)
        }
    }

    /// [EN] 0 loops and 1 plays once a named animation; other counts, and state machines, are not supported.
    /// [CN] 具名动画：0 循环，1 播放一次；其他次数以及状态机不支持。
    public func setAnimationRepeatCount(_ repeatCount: Int) -> Bool {
        guard configuration.animationName != nil, repeatCount == 0 || repeatCount == 1 else {
            return false
        }
        loop = repeatCount == 0 ? .loop : .oneShot
        return true
    }

    public func showAnimationLastFrame() {
        stopAnimation()
    }

    public func stopAnimation() {
        deactivateTask?.cancel()
        deactivateTask = nil
        if configuration.animationName != nil {
            viewModel.stop()
            return
        }
        if let input = configuration.stateMachineInput {
            viewModel.setInput(input, value: false)
        }
        viewModel.pause()
    }
}
#endif
