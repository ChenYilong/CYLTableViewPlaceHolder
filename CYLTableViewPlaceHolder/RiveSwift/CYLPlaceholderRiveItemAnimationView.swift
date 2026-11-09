//
//  CYLPlaceholderRiveItemAnimationView.swift
//  CYLTableViewPlaceHolder
//
//  Adapted from CYLTabBarController (`RiveSwift/CYLRiveTabBarItemAnimationView.swift`,
//  branch feat/cross-platform-components), MIT License,
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//
//  The Swift bridge of the `Rive` subspec. It adopts the shared interfaces
//  `CYLPlaceholderItemAnimationPlayableView` and
//  `CYLPlaceholderItemAnimationViewProviding`, so the shared
//  `CYLPlaceholderItemViewAnimator` does everything else. It uses Rive's current
//  API (`Worker`, `File`, `Rive`, `RiveUIView`, view model instances).
//  Placeholder additions: it pauses rendering while stopped, and reports when
//  its asynchronous load finishes or fails.
//

#if canImport(RiveRuntime)
import UIKit
import RiveRuntime

/// Where Rive files come from: the view depends on this interface, not on a cache.
@available(iOS 14.0, *)
@MainActor
protocol CYLPlaceholderRiveItemAnimationFileProviding: AnyObject {
    func file(at url: URL) async throws -> RiveRuntime.File
}

struct CYLPlaceholderRiveItemAnimationConfiguration {
    let fileURL: URL
    let artboardName: String?
    let stateMachineName: String?
    let activePropertyPath: String
    let activeDuration: TimeInterval
    let triggerPropertyPath: String?
    let lightColor: UIColor?
    /// Legacy runtime (files without a view model): a state machine input, a trigger input, or a linear animation.
    let stateMachineInput: String?
    let triggerInput: String?
    let animationName: String?
    let forcesLegacyRuntime: Bool

    var usesLegacyRuntime: Bool {
        return forcesLegacyRuntime || stateMachineInput != nil || triggerInput != nil || animationName != nil
    }

    init(fileURL: URL, options: [String: String]) {
        self.fileURL = fileURL
        artboardName = options["artboard"]
        stateMachineName = options["stateMachine"]
        activePropertyPath = options["active"] ?? "active"
        // 1 second by default, at most a minute; 0 keeps it true until the animation stops.
        if let duration = Double(options["duration"] ?? ""), duration >= 0 {
            activeDuration = min(duration, 60)
        } else {
            activeDuration = 1
        }
        triggerPropertyPath = options["trigger"]
        lightColor = options["color"].flatMap(Self.color(hex:))
        stateMachineInput = options["input"]
        triggerInput = options["triggerInput"]
        animationName = options["animation"]
        forcesLegacyRuntime = options["legacy"] == "1"
    }

    private static func color(hex: String) -> UIColor? {
        let digits = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        guard digits.count == 6 || digits.count == 8, var value = UInt64(digits, radix: 16) else {
            return nil
        }
        if digits.count == 6 {
            value = (value << 8) | 0xFF
        }
        func component(_ shift: UInt64) -> CGFloat {
            return CGFloat((value >> shift) & 0xFF) / 255
        }
        return UIColor(red: component(24), green: component(16), blue: component(8), alpha: component(0))
    }
}

/// Plays a Rive artboard through its view model: the boolean `active` property is set to true, then back to false
/// after `duration` seconds, or the trigger `trigger` is fired.
@available(iOS 14.0, *)
@objc(CYLPlaceholderRiveItemAnimationView)
public final class CYLPlaceholderRiveItemAnimationView: UIView, CYLPlaceholderItemAnimationPlayableView, CYLPlaceholderItemAnimationViewProviding {
    private static let colorPropertyPath = "color"

    private let configuration: CYLPlaceholderRiveItemAnimationConfiguration
    private let fileProvider: CYLPlaceholderRiveItemAnimationFileProviding
    private var rive: Rive?
    private var riveView: RiveUIView?
    private var viewModelInstance: ViewModelInstance?
    private var isLoaded = false
    private var playsWhenLoaded = false
    private var deactivateTask: Task<Void, Never>?
    private var requestedColors: [String: UIColor]?
    private var colorTask: Task<Void, Never>?
    private var originalColors: [String: RiveRuntime.Color] = [:]
    private var overriddenColorPaths: Set<String> = []

    /// The renderer for legacy options (another strategy of the same interface). Injected by
    /// `CYLRivePlaceholderItemAnimator`; nil: legacy options show nothing.
    @objc public static var legacyViewProvider: AnyClass?
    /// Where the views made by `makeAnimationView` load their files; injectable.
    static var fileProvider: CYLPlaceholderRiveItemAnimationFileProviding = CYLPlaceholderRiveItemAnimationFileCache.shared

    @objc public var animationReadyHandler: (() -> Void)?
    @objc public var animationErrorHandler: ((Error) -> Void)?
    @objc public var isAnimationReady: Bool { isLoaded }
    @objc var cyl_isPaused: Bool { riveView?.isPaused ?? true }
    /// The colors last asked for (test probe); nil restores the original colors.
    @objc var cyl_requestedColors: [String: UIColor]? { requestedColors }

    public static func makeAnimationView(fileURL: URL, options: [String: String], contentMode: UIView.ContentMode) -> (UIView & CYLPlaceholderItemAnimationPlayableView)? {
        let configuration = CYLPlaceholderRiveItemAnimationConfiguration(fileURL: fileURL, options: options)
        if configuration.usesLegacyRuntime {
            let legacyProvider = legacyViewProvider as? CYLPlaceholderItemAnimationViewProviding.Type
            return legacyProvider?.makeAnimationView(fileURL: fileURL, options: options, contentMode: contentMode)
        }
        let view = CYLPlaceholderRiveItemAnimationView(configuration: configuration, fileProvider: fileProvider)
        view.contentMode = contentMode
        return view
    }

    init(configuration: CYLPlaceholderRiveItemAnimationConfiguration, fileProvider: CYLPlaceholderRiveItemAnimationFileProviding) {
        self.configuration = configuration
        self.fileProvider = fileProvider
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        backgroundColor = .clear
        accessibilityElementsHidden = true
        load()
    }

    public required init?(coder _: NSCoder) {
        return nil
    }

    override public var contentMode: UIView.ContentMode {
        didSet {
            rive?.fit = Self.fit(for: contentMode)
        }
    }

    public func playAnimation() {
        guard isLoaded else {
            playsWhenLoaded = true
            return
        }
        riveView?.isPaused = false
        guard let instance = viewModelInstance else {
            return
        }
        deactivateTask?.cancel()
        if let triggerPropertyPath = configuration.triggerPropertyPath {
            instance.fire(trigger: TriggerProperty(path: triggerPropertyPath))
            return
        }
        let activePropertyPath = configuration.activePropertyPath
        instance.setValue(of: BoolProperty(path: activePropertyPath), to: true)
        guard configuration.activeDuration > 0 else {
            return
        }
        let nanoseconds = UInt64(configuration.activeDuration * 1_000_000_000)
        deactivateTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: nanoseconds)
            guard !Task.isCancelled, let self, let instance = self.viewModelInstance else {
                return
            }
            instance.setValue(of: BoolProperty(path: activePropertyPath), to: false)
        }
    }

    /// A state machine has no last frame: the view stays in its resting state.
    public func showAnimationLastFrame() {
        stopAnimation()
    }

    public func stopAnimation() {
        playsWhenLoaded = false
        deactivateTask?.cancel()
        deactivateTask = nil
        if configuration.triggerPropertyPath == nil, let instance = viewModelInstance {
            instance.setValue(of: BoolProperty(path: configuration.activePropertyPath), to: false)
        }
        riveView?.isPaused = true
    }

    /// Color property path -> color; nil restores the original colors.
    public func applyAnimationColors(_ colors: [String: UIColor]?) {
        requestedColors = colors
        if isLoaded {
            enqueueRequestedColors()
        }
    }

    private func load() {
        let configuration = self.configuration
        let fileProvider = self.fileProvider
        Task { @MainActor [weak self] in
            do {
                let file = try await fileProvider.file(at: configuration.fileURL)
                guard let self else {
                    return
                }
                let artboard = try await file.createArtboard(configuration.artboardName)
                let instance = try? await file.createViewModelInstance(.viewModelDefault(from: .artboardDefault(artboard)))
                let stateMachine = try await artboard.createStateMachine(configuration.stateMachineName, binding: instance)
                let rive = try await Rive(file: file,
                                          artboard: artboard,
                                          stateMachine: stateMachine,
                                          fit: Self.fit(for: self.contentMode))
                self.didLoad(rive: rive, viewModelInstance: instance)
            } catch {
                self?.animationErrorHandler?(error)
            }
        }
    }

    private func didLoad(rive: Rive, viewModelInstance: ViewModelInstance?) {
        self.rive = rive
        self.viewModelInstance = viewModelInstance
        let riveView = RiveUIView(rive: rive, isPaused: !playsWhenLoaded)
        riveView.frame = bounds
        riveView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        riveView.isUserInteractionEnabled = false
        riveView.backgroundColor = .clear
        addSubview(riveView)
        self.riveView = riveView
        isLoaded = true
        if let lightColor = configuration.lightColor, let instance = viewModelInstance {
            let path = Self.colorPropertyPath
            let color = Self.riveColor(lightColor)
            originalColors[path] = color
            instance.setValue(of: ColorProperty(path: path), to: color)
        }
        if requestedColors != nil {
            enqueueRequestedColors()
        }
        animationReadyHandler?()
        if playsWhenLoaded {
            playsWhenLoaded = false
            playAnimation()
        }
    }

    /// Applies `requestedColors` after the updates already queued, so they keep their order.
    private func enqueueRequestedColors() {
        guard let instance = viewModelInstance else {
            return
        }
        let colors = requestedColors
        let previous = colorTask
        colorTask = Task { @MainActor [weak self] in
            await previous?.value
            guard let self else {
                return
            }
            if let colors {
                for (path, color) in colors {
                    let property = ColorProperty(path: path)
                    if self.originalColors[path] == nil, let original = try? await instance.value(of: property) {
                        self.originalColors[path] = original
                    }
                    instance.setValue(of: property, to: Self.riveColor(color))
                    self.overriddenColorPaths.insert(path)
                }
            } else {
                for path in self.overriddenColorPaths {
                    if let original = self.originalColors[path] {
                        instance.setValue(of: ColorProperty(path: path), to: original)
                    }
                }
                self.overriddenColorPaths.removeAll()
            }
        }
    }

    private static func riveColor(_ color: UIColor) -> RiveRuntime.Color {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        if !color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            var white: CGFloat = 0
            if color.getWhite(&white, alpha: &alpha) {
                red = white
                green = white
                blue = white
            }
        }
        func byte(_ value: CGFloat) -> UInt8 {
            return UInt8(max(0, min(255, (value * 255).rounded())))
        }
        return RiveRuntime.Color(red: byte(red), green: byte(green), blue: byte(blue), alpha: byte(alpha))
    }

    private static func fit(for contentMode: UIView.ContentMode) -> RiveRuntime.Fit {
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

/// One `Worker` for every Rive placeholder, and each .riv file loaded once.
@available(iOS 14.0, *)
@MainActor
final class CYLPlaceholderRiveItemAnimationFileCache: CYLPlaceholderRiveItemAnimationFileProviding {
    static let shared = CYLPlaceholderRiveItemAnimationFileCache()
    private var workerTask: Task<RiveRuntime.Worker, Error>?
    private var fileTasks: [URL: Task<RiveRuntime.File, Error>] = [:]

    func file(at url: URL) async throws -> RiveRuntime.File {
        if let task = fileTasks[url] {
            return try await task.value
        }
        let task = Task { @MainActor () async throws -> RiveRuntime.File in
            let worker = try await self.sharedWorker()
            return try await RiveRuntime.File(source: .data(try Data(contentsOf: url)), worker: worker)
        }
        fileTasks[url] = task
        do {
            return try await task.value
        } catch {
            fileTasks[url] = nil
            throw error
        }
    }

    private func sharedWorker() async throws -> RiveRuntime.Worker {
        if let task = workerTask {
            return try await task.value
        }
        let task = Task { @MainActor () async throws -> RiveRuntime.Worker in
            return try await RiveRuntime.Worker()
        }
        workerTask = task
        do {
            return try await task.value
        } catch {
            workerTask = nil
            throw error
        }
    }
}
#endif
