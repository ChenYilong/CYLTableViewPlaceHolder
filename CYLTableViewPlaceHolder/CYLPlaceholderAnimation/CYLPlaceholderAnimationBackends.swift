//
//  CYLPlaceholderAnimationBackends.swift
//  CYLTableViewPlaceHolder
//
//  Animation adapter patterns are informed by CYLTabBarController, distributed
//  under the MIT License (Copyright (c) 2026 CYLTabBarController).
//

import UIKit

#if canImport(Lottie)
import Lottie
#endif

#if canImport(RiveRuntime)
import RiveRuntime
#endif

@objc(CYLPlaceholderAnimationBackendView)
public class CYLPlaceholderAnimationBackendView: UIView {
    @objc public var errorHandler: ((NSError) -> Void)?
    @objc public var readyHandler: (() -> Void)?
    @objc public var isReady: Bool { true }

    @objc public func playAnimation() {}
    @objc public func stopAnimation() {}
    @objc public func showAnimationLastFrame() { stopAnimation() }
}

@objc(CYLPlaceholderAnimationBackendFactory)
public final class CYLPlaceholderAnimationBackendFactory: NSObject {
    @MainActor
    @objc(makeBackendViewWithFileURL:contentMode:options:error:)
    public class func makeBackendView(
        withFileURL fileURL: URL,
        contentMode: UIView.ContentMode,
        options: [String: Any],
        error errorPointer: AutoreleasingUnsafeMutablePointer<NSError?>?
    ) -> UIView? {
        do {
            switch fileURL.pathExtension.lowercased() {
            case "json":
                #if canImport(Lottie)
                guard #available(iOS 13.0, *) else {
                    throw Self.error(code: 4, description: "Lottie requires iOS 13 or later.")
                }
                let data = try Data(contentsOf: fileURL)
                let animation = try LottieAnimation.from(data: data)
                return CYLPlaceholderLottieAnimationBackendView(animation: animation, contentMode: contentMode)
                #else
                throw Self.error(code: 4, description: "Lottie support is not linked.")
                #endif

            case "riv":
                #if canImport(RiveRuntime)
                guard #available(iOS 14.0, *) else {
                    throw Self.error(code: 4, description: "RiveRuntime requires iOS 14 or later.")
                }
                for key in ["artboard", "stateMachine", "active", "trigger", "input", "triggerInput", "animation", "legacy"]
                    where options[key] != nil && !(options[key] is String) {
                    throw Self.error(code: 3, description: "Rive \(key) must be a string.")
                }
                let durationValue = options["duration"]
                let duration = (durationValue as? NSNumber)?.doubleValue
                    ?? (durationValue as? String).flatMap(Double.init)
                    ?? (durationValue == nil ? 1 : .nan)
                guard duration.isFinite, duration >= 0, duration <= 60 else {
                    throw Self.error(code: 3, description: "Rive duration must be between 0 and 60 seconds.")
                }
                if options["input"] != nil || options["triggerInput"] != nil ||
                    options["animation"] != nil || options["legacy"] as? String == "1" {
                    return try CYLPlaceholderRiveLegacyAnimationBackendView(
                        fileURL: fileURL, contentMode: contentMode,
                        artboardName: options["artboard"] as? String,
                        stateMachineName: options["stateMachine"] as? String,
                        input: options["input"] as? String,
                        triggerInput: options["triggerInput"] as? String,
                        animationName: options["animation"] as? String,
                        duration: duration)
                }
                return try CYLPlaceholderRiveAnimationBackendView(
                    fileURL: fileURL, contentMode: contentMode,
                    artboardName: options["artboard"] as? String,
                    stateMachineName: options["stateMachine"] as? String,
                    activePath: options["active"] as? String ?? "active",
                    triggerPath: options["trigger"] as? String, duration: duration)
                #else
                throw Self.error(code: 4, description: "Rive support is not linked.")
                #endif

            default:
                throw Self.error(code: 3, description: "The Swift animation adapters support .json and .riv files.")
            }
        } catch {
            errorPointer?.pointee = error as NSError
            return nil
        }
    }

    private class func error(code: Int, description: String) -> NSError {
        NSError(
            domain: "CYLPlaceholderAnimationErrorDomain",
            code: code,
            userInfo: [NSLocalizedDescriptionKey: description]
        )
    }
}

#if canImport(Lottie)
@available(iOS 13.0, *)
@objc(CYLPlaceholderLottieAnimationBackendView)
public final class CYLPlaceholderLottieAnimationBackendView: CYLPlaceholderAnimationBackendView {
    private let lottieView: LottieAnimationView
    private var colorKeypaths = Set<String>()
    private var appliedColors: [String: UIColor] = [:]

    @objc var cyl_isAnimationPlaying: Bool { lottieView.isAnimationPlaying }
    @objc var cyl_realtimeAnimationProgress: CGFloat { lottieView.realtimeAnimationProgress }
    @objc var cyl_animationSpeed: CGFloat { lottieView.animationSpeed }
    @objc var cyl_appliedColors: [String: UIColor] { appliedColors }

    fileprivate init(animation: LottieAnimation, contentMode: UIView.ContentMode) {
        lottieView = LottieAnimationView(animation: animation)
        super.init(frame: .zero)
        lottieView.contentMode = contentMode
        lottieView.loopMode = .playOnce
        lottieView.backgroundColor = .clear
        lottieView.isUserInteractionEnabled = false
        lottieView.frame = bounds
        lottieView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(lottieView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported.")
    }

    @objc public override func playAnimation() {
        lottieView.currentProgress = 0
        lottieView.play()
    }

    @objc public override func stopAnimation() {
        lottieView.stop()
        lottieView.currentProgress = 0
    }

    @objc public override func showAnimationLastFrame() {
        lottieView.stop()
        lottieView.currentProgress = 1
    }

    @objc public func setAnimationProgress(_ progress: CGFloat) -> Bool {
        lottieView.stop()
        lottieView.currentProgress = progress
        return true
    }

    @objc public func setAnimationSpeed(_ speed: CGFloat) -> Bool {
        lottieView.animationSpeed = speed
        return true
    }

    @objc public func setAnimationColors(_ colors: [String: UIColor]) -> Bool {
        if colors == appliedColors { return true }
        var providers: [String: ColorValueProvider] = [:]
        for (path, color) in colors {
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            let converted = color.cgColor.converted(to: LottieConfiguration.shared.colorSpace,
                                                     intent: .defaultIntent, options: nil)
            if let components = converted?.components, components.count == 4 {
                red = components[0]; green = components[1]; blue = components[2]; alpha = components[3]
            } else if !color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
                return false
            }
            providers[path] = ColorValueProvider(LottieColor(r: Double(red), g: Double(green),
                                                              b: Double(blue), a: Double(alpha)))
        }
        for path in colorKeypaths {
            lottieView.removeValueProvider(for: AnimationKeypath(keypath: path))
        }
        for (path, provider) in providers {
            lottieView.setValueProvider(provider, keypath: AnimationKeypath(keypath: path))
        }
        colorKeypaths = Set(providers.keys)
        appliedColors = colors
        return true
    }
}
#endif

#if canImport(RiveRuntime)
// Legacy playback adapted from CYLRiveLegacyTabBarItemAnimationView,
// CYLTabBarController (MIT); see the bundled third-party license.
@available(iOS 14.0, *)
@available(*, deprecated, message: "Wraps Rive's legacy state machine and animation API.")
@MainActor
@objc(CYLPlaceholderRiveLegacyAnimationBackendView)
public final class CYLPlaceholderRiveLegacyAnimationBackendView: CYLPlaceholderAnimationBackendView {
    private let viewModel: RiveViewModel
    private let input: String?
    private let triggerInput: String?
    private let animationName: String?
    private let duration: TimeInterval
    private var deactivateTask: Task<Void, Never>?
    @objc var cyl_inputActive: Bool {
        guard let input else { return false }
        return viewModel.boolInput(named: input)?.value() ?? false
    }
    @objc var cyl_isPlaying: Bool { viewModel.isPlaying }

    init(fileURL: URL, contentMode: UIView.ContentMode, artboardName: String?, stateMachineName: String?,
         input: String?, triggerInput: String?, animationName: String?, duration: TimeInterval) throws {
        let data = try Data(contentsOf: fileURL)
        let file = try RiveFile(data: data, loadCdn: false)
        let artboard = try artboardName.map { try file.artboard(fromName: $0) } ?? file.artboard()
        if let animationName {
            _ = try artboard.animation(fromName: animationName)
        } else if let stateMachineName {
            _ = try artboard.stateMachine(fromName: stateMachineName)
        }
        let model = RiveModel(riveFile: file)
        if let animationName {
            viewModel = RiveViewModel(model, animationName: animationName, fit: .contain, alignment: .center,
                                      autoPlay: false, artboardName: artboardName)
        } else {
            viewModel = RiveViewModel(model, stateMachineName: stateMachineName, fit: .contain, alignment: .center,
                                      autoPlay: false, artboardName: artboardName)
        }
        self.input = input
        self.triggerInput = triggerInput
        self.animationName = animationName
        self.duration = duration
        super.init(frame: .zero)
        switch contentMode {
        case .scaleToFill: viewModel.fit = .fill
        case .scaleAspectFill: viewModel.fit = .cover
        default: viewModel.fit = .contain
        }
        let view = viewModel.createRiveView()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        addSubview(view)
        if let input, viewModel.boolInput(named: input) == nil {
            throw NSError(domain: "CYLPlaceholderAnimationErrorDomain", code: 5,
                          userInfo: [NSLocalizedDescriptionKey: "Rive boolean input '\(input)' was not found."])
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported.")
    }

    @objc public override func playAnimation() {
        deactivateTask?.cancel()
        if let animationName {
            viewModel.play(animationName: animationName)
            return
        }
        viewModel.play()
        if let triggerInput {
            viewModel.triggerInput(triggerInput)
        } else if let input {
            viewModel.setInput(input, value: true)
            if duration > 0 {
                deactivateTask = Task { @MainActor [weak self] in
                    do {
                        try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                    } catch {
                        return
                    }
                    guard let self else { return }
                    self.viewModel.setInput(input, value: false)
                }
            }
        }
    }

    @objc public override func stopAnimation() {
        deactivateTask?.cancel()
        deactivateTask = nil
        if animationName != nil {
            viewModel.stop()
        } else if let input {
            viewModel.setInput(input, value: false)
        }
        if animationName == nil {
            viewModel.pause()
        }
    }
}
#endif

#if canImport(RiveRuntime)
@available(iOS 14.0, *)
@MainActor
@objc(CYLPlaceholderRiveAnimationBackendView)
public final class CYLPlaceholderRiveAnimationBackendView: CYLPlaceholderAnimationBackendView {
    private let fileData: Data
    private let viewContentMode: UIView.ContentMode
    private let artboardName: String?
    private let stateMachineName: String?
    private let activePath: String
    private let triggerPath: String?
    private let activeDuration: TimeInterval
    private var rive: Rive?
    private var riveView: RiveUIView?
    private var viewModelInstance: ViewModelInstance?
    private var shouldPlayWhenLoaded = false
    private var deactivateTask: Task<Void, Never>?
    @objc public override var isReady: Bool { riveView != nil }
    @objc var cyl_isPaused: Bool { riveView?.isPaused ?? true }

    public init(fileURL: URL, contentMode: UIView.ContentMode, artboardName: String?, stateMachineName: String?,
                activePath: String, triggerPath: String?, duration: TimeInterval) throws {
        fileData = try Data(contentsOf: fileURL)
        viewContentMode = contentMode
        self.artboardName = artboardName
        self.stateMachineName = stateMachineName
        self.activePath = activePath
        self.triggerPath = triggerPath
        self.activeDuration = duration
        super.init(frame: .zero)
        load()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported.")
    }

    @objc public override func playAnimation() {
        shouldPlayWhenLoaded = true
        riveView?.isPaused = false
        guard let instance = viewModelInstance else { return }
        deactivateTask?.cancel()
        if let triggerPath {
            instance.fire(trigger: TriggerProperty(path: triggerPath))
            return
        }
        instance.setValue(of: BoolProperty(path: activePath), to: true)
        guard activeDuration > 0 else { return }
        deactivateTask = Task { @MainActor [weak self] in
            do {
                try await Task.sleep(nanoseconds: UInt64(activeDuration * 1_000_000_000))
            } catch {
                return
            }
            guard let self, let instance = self.viewModelInstance else { return }
            instance.setValue(of: BoolProperty(path: self.activePath), to: false)
        }
    }

    @objc public override func stopAnimation() {
        shouldPlayWhenLoaded = false
        deactivateTask?.cancel()
        deactivateTask = nil
        if triggerPath == nil {
            viewModelInstance?.setValue(of: BoolProperty(path: activePath), to: false)
        }
        riveView?.isPaused = true
    }

    private func load() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let worker = try await RiveRuntime.Worker()
                let file = try await RiveRuntime.File(source: .data(fileData), worker: worker)
                let artboard = try await file.createArtboard(artboardName)
                let instance = try? await file.createViewModelInstance(
                    .viewModelDefault(from: .artboardDefault(artboard))
                )
                let stateMachine = try await artboard.createStateMachine(stateMachineName, binding: instance)
                let rive = try await Rive(
                    file: file,
                    artboard: artboard,
                    stateMachine: stateMachine,
                    fit: Self.fit(for: viewContentMode)
                )
                self.rive = rive
                viewModelInstance = instance
                let riveView = RiveUIView(rive: rive, isPaused: !shouldPlayWhenLoaded)
                riveView.frame = bounds
                riveView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                riveView.backgroundColor = .clear
                riveView.isUserInteractionEnabled = false
                addSubview(riveView)
                self.riveView = riveView
                readyHandler?()
                if shouldPlayWhenLoaded {
                    playAnimation()
                } else {
                    stopAnimation()
                }
            } catch {
                errorHandler?(error as NSError)
            }
        }
    }

    private static func fit(for contentMode: UIView.ContentMode) -> Fit {
        switch contentMode {
        case .scaleToFill:
            return .fill(alignment: .center)
        case .scaleAspectFill:
            return .cover(alignment: .center)
        default:
            return .contain(alignment: .center)
        }
    }
}
#endif
