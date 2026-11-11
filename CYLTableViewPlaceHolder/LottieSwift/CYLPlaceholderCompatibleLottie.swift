//
//  CYLPlaceholderCompatibleLottie.swift
//  CYLTableViewPlaceHolder
//
//  Adapted from CYLTabBarController (`LottieSwift/CYLCompatibleLottie.swift`,
//  branch feat/cross-platform-components), MIT License,
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//
//  The Swift bridge of the `LottieSwift` subspec: lottie-ios 4.x is a Swift
//  API, so these @objc classes expose what `CYLLottiePlaceholderItemAnimator`
//  (Objective-C) needs. Class names differ from CYLTabBarController's so both
//  libraries can be linked into one app.
//

#if canImport(Lottie)
import Foundation
import Lottie
import UIKit

@available(iOS 13.0, *)
@objc(CYLPlaceholderCompatibleLOTAnimation)
public final class CYLPlaceholderCompatibleLOTAnimation: NSObject {
    @objc
    public init(filepath: String) {
        self.filepath = filepath
        animation = LottieAnimation.filepath(filepath)
        super.init()
    }

    /**
     * NO when the file could not be read or decoded.
     */
    @objc public var isLoaded: Bool { animation != nil }

    let animation: LottieAnimation?
    private let filepath: String
}

@available(iOS 13.0, *)
@objc(CYLPlaceholderCompatibleLOTAnimationView)
public final class CYLPlaceholderCompatibleLOTAnimationView: UIView {
    @objc
    public init(compatibleAnimation: CYLPlaceholderCompatibleLOTAnimation) {
        animationView = LottieAnimationView(animation: compatibleAnimation.animation)
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    public var loopAnimationCount: CGFloat = 0 {
        didSet {
            animationView.loopMode = loopAnimationCount == -1 ? .loop : .repeat(Float(loopAnimationCount))
        }
    }

    @objc
    public override var contentMode: UIView.ContentMode {
        set { animationView.contentMode = newValue }
        get { animationView.contentMode }
    }

    @objc
    public var animationProgress: CGFloat {
        set { animationView.currentProgress = newValue }
        get { animationView.currentProgress }
    }

    @objc
    public var duration: CGFloat {
        animationView.animation?.duration ?? 0.0
    }

    @objc
    public var realtimeAnimationProgress: CGFloat {
        animationView.realtimeAnimationProgress
    }

    @objc
    public var animationSpeed: CGFloat {
        set { animationView.animationSpeed = newValue }
        get { animationView.animationSpeed }
    }

    @objc
    public var isAnimationPlaying: Bool {
        animationView.isAnimationPlaying
    }

    @objc
    public func play() {
        animationView.play(completion: nil)
    }

    @objc
    public func stop() {
        animationView.stop()
    }

    @objc
    public func pause() {
        animationView.pause()
    }

    @objc
    public func forceDrawingUpdate() {
        animationView.forceDisplayUpdate()
    }

    /**
     * Sets a color value provider for a keypath string, e.g. "Icon.**.Color".
     */
    @objc
    public func setColorValue(_ color: UIColor, forKeypathString keypath: String) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        let convertedColor = color.cgColor.converted(to: LottieConfiguration.shared.colorSpace,
                                                     intent: .defaultIntent, options: nil)
        if let components = convertedColor?.components, components.count == 4 {
            red = components[0]
            green = components[1]
            blue = components[2]
            alpha = components[3]
        } else {
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        }
        let valueProvider = ColorValueProvider(LottieColor(r: Double(red), g: Double(green), b: Double(blue), a: Double(alpha)))
        animationView.setValueProvider(valueProvider, keypath: AnimationKeypath(keypath: keypath))
        appliedColors[keypath] = color
    }

    /**
     * Removes the value provider set for `keypath`, restoring the animation's own value.
     */
    @objc
    public func removeValueProvider(forKeypathString keypath: String) {
        animationView.removeValueProvider(for: AnimationKeypath(keypath: keypath))
        appliedColors[keypath] = nil
    }

    // MARK: Test probes (read with key-value coding)

    @objc var cyl_isAnimationPlaying: Bool { animationView.isAnimationPlaying }
    @objc var cyl_realtimeAnimationProgress: CGFloat { animationView.realtimeAnimationProgress }
    @objc var cyl_animationSpeed: CGFloat { animationView.animationSpeed }
    /**
     * The color overrides currently set, by keypath.
     */
    @objc private(set) var cyl_appliedColors: [String: UIColor] = [:]

    // MARK: Private

    private let animationView: LottieAnimationView
    private var appliedColors: [String: UIColor] {
        get { cyl_appliedColors }
        set { cyl_appliedColors = newValue }
    }

    private func commonInit() {
        // Plays once, like a tab icon. Fills with an autoresizing mask instead of constraints.
        animationView.loopMode = .playOnce
        animationView.backgroundColor = .clear
        animationView.isUserInteractionEnabled = false
        animationView.translatesAutoresizingMaskIntoConstraints = true
        animationView.frame = bounds
        animationView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(animationView)
    }
}
#endif
