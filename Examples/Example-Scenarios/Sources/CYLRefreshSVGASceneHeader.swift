//
//  CYLRefreshSVGASceneHeader.swift
//  Example-Scenarios
//
//  The SVGA twin of the Rive scene styles (Task-Log "SVGA animations, every Rive demo copied 1:1"; Android
//  SVGASceneHeader.kt): an SVGA scene of scripts/make_svga_scenes.py drawn by the core's CYLPlaceholderView (the
//  CYLAnimatedItem engine and SVGAPlayerLite, CYLTableViewPlaceHolder/SVGA). Like CYLRefreshRiveHeader it stretches with
//  the pull and keeps the art laid out in at least `sceneHeight` points at the bottom. SVGA has no state machine, so the
//  pull scrubs the scene (seeking, CYLTabBarController 28a9609d) and refreshing loops it.
//

import UIKit
import CYLTableViewPlaceHolder

final class CYLRefreshSVGASceneHeader: CYLRefreshDrawnHeader {

    /// The scene's height in points (the files are 375 x 150, shown 300 x 120), as on Android.
    static let sceneHeight: CGFloat = 130

    private var scene: CYLPlaceholderView?
    private var playing = false

    /// A header drawn by the SVGA file at `path`; nil when the file cannot be shown.
    convenience init?(path: String) {
        self.init(frame: .zero)
        guard let scene = try? CYLPlaceholderView(itemAttributes: [
            CYLPlaceholderItemAnimationFilePath: path,
            CYLPlaceholderItemAnimationSize: [300, 120],
        ], imageBundle: nil) else { return nil }
        scene.isUserInteractionEnabled = false
        scene.backgroundColor = .clear
        scene.stopPlaceholderAnimation()
        insertSubview(scene, at: 0)
        self.scene = scene
        setExpandHeight(Self.sceneHeight)
    }

    override func setUpComponent() {
        super.setUpComponent()
        scrollMode = .stretch
        clipsToBounds = true
        // Decoration: the refresh tells its state itself.
        accessibilityElementsHidden = true
    }

    override func placeSubviews() {
        super.placeSubviews()
        guard let scene = scene else { return }
        // Bottom-aligned in at least sceneHeight, so the art sits against the content while the header grows.
        let height = max(bounds.height, Self.sceneHeight)
        scene.frame = CGRect(x: 0, y: bounds.height - height, width: bounds.width, height: height)
    }

    override func onScrolling(withOffset offset: CGFloat, percent: CGFloat, drag isDragging: Bool) {
        super.onScrolling(withOffset: offset, percent: percent, drag: isDragging)
        guard !playing else { return }
        _ = scene?.setPlaceholderAnimationProgress(min(max(percent, 0), 1))
    }

    override func onStatus(_ oldStatus: CYLRefreshPhase, changed status: CYLRefreshPhase) {
        super.onStatus(oldStatus, changed: status)
        guard let scene = scene else { return }
        switch status {
        case .releasing, .refreshing:
            guard !playing else { break }
            playing = true
            scene.animationRepeatCount = 0
            scene.playPlaceholderAnimation()
        case .idle:
            guard playing else { break }
            playing = false
            scene.stopPlaceholderAnimation()
            _ = scene.setPlaceholderAnimationProgress(0)
        default:
            break
        }
    }
}
