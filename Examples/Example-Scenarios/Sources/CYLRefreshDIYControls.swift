//
//  CYLRefreshDIYControls.swift
//  Example-Scenarios
//
//  The custom refresh controls of MJRefresh's example layer (Classes/DIY, MIT; originally created by MJ Lee,
//  Copyright (c) 2015 小码哥), transcribed to Swift on this project's API:
//
//  - MJChiBaoZiHeader, MJChiBaoZiFooter, MJChiBaoZiFooter2 → CYLRefreshExampleImagesHeader, …Footer, …BackFooter:
//    the "animated images" controls, here on the general names (CYLRefreshAnimationHeader and friends) with frames
//    of the bundled refresh GIFs instead of MJRefresh's mascot images.
//  - MJDIYHeader, MJDIYAutoFooter, MJDIYBackFooter → CYLRefreshDIYHeader, CYLRefreshDIYAutoFooter,
//    CYLRefreshDIYBackFooter: a label, a switch that is only for show, a logo and a spinner.
//
//  `prepare` and `placeSubviews` are overridden as in Objective-C; `setState:` and `setPullingPercent:` become
//  property observers (`didSet`) on `state` and `pullingPercent`.
//

import UIKit
import CYLTableViewPlaceHolder

/// The refresh frames used by the animated-image controls: turning arrows while idle, a ring while refreshing.
enum CYLRefreshExampleImages {
    static let idle = CYLRefreshFrames.images(ofBundledGIF: "CYLRefreshArrows.gif")
    static let refreshing = CYLRefreshFrames.images(ofBundledGIF: "CYLRefreshRing.gif")
}

// MARK: - Animated images (MJChiBaoZi…)

/// MJChiBaoZiHeader: images for the idle, pulling and refreshing states.
final class CYLRefreshExampleImagesHeader: CYLRefreshAnimationHeader {
    override func prepare() {
        super.prepare()
        // The images of the idle state
        setAnimationImages(CYLRefreshExampleImages.idle, for: .idle)
        // The images of the pulling state (refreshes as soon as it is released)
        setAnimationImages(CYLRefreshExampleImages.refreshing, for: .pulling)
        // The images of the refreshing state
        setAnimationImages(CYLRefreshExampleImages.refreshing, for: .refreshing)
    }
}

/// MJChiBaoZiFooter: images for the refreshing state of an automatic footer.
final class CYLRefreshExampleImagesFooter: CYLRefreshAutoAnimationFooter {
    override func prepare() {
        super.prepare()
        setAnimationImages(CYLRefreshExampleImages.refreshing, for: .refreshing)
    }
}

/// MJChiBaoZiFooter2: images for the idle, pulling and refreshing states of a back footer.
final class CYLRefreshExampleImagesBackFooter: CYLRefreshBackAnimationFooter {
    override func prepare() {
        super.prepare()
        setAnimationImages(CYLRefreshExampleImages.idle, for: .idle)
        setAnimationImages(CYLRefreshExampleImages.refreshing, for: .pulling)
        setAnimationImages(CYLRefreshExampleImages.refreshing, for: .refreshing)
    }
}

// MARK: - Custom controls (MJDIY…)

/// The subviews the three custom controls share.
private struct CYLRefreshDIYViews {
    let label = UILabel()
    /// Only for show ("打酱油"), so it is hidden from assistive technologies.
    let toggle = UISwitch()
    let logo = UIImageView(image: UIImage(systemName: "arrow.triangle.2.circlepath.circle.fill"))
    let loading = UIActivityIndicatorView(style: .medium)

    func add(to control: UIView, logo showsLogo: Bool) {
        label.textColor = UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        control.addSubview(label)
        toggle.isAccessibilityElement = false
        toggle.isUserInteractionEnabled = false
        control.addSubview(toggle)
        if showsLogo {
            logo.contentMode = .scaleAspectFit
            logo.tintColor = .systemTeal
            logo.isAccessibilityElement = false
            control.addSubview(logo)
        }
        control.addSubview(loading)
    }

    /// MJDIYHeader's color: from orange to purple as the control is pulled out.
    func follow(pullingPercent: CGFloat) {
        label.textColor = UIColor(red: 1.0 - pullingPercent * 0.5, green: 0.5 - 0.5 * pullingPercent,
                                  blue: 0.5 * pullingPercent, alpha: 1.0)
    }
}

/// MJDIYHeader
final class CYLRefreshDIYHeader: CYLRefreshHeader {

    private let views = CYLRefreshDIYViews()

    // Set up here (add the subviews)
    override func prepare() {
        super.prepare()
        // The control's height
        cyl_h = 50
        views.add(to: self, logo: true)
    }

    // Place the subviews here
    override func placeSubviews() {
        super.placeSubviews()
        // Between the switch and the spinner (72 pt each side), so long texts shrink instead of running under them.
        views.label.frame = bounds.insetBy(dx: 72, dy: 0)
        views.toggle.center = CGPoint(x: 40, y: cyl_h * 0.5)
        views.logo.bounds = CGRect(x: 0, y: 0, width: bounds.width, height: 100)
        views.logo.center = CGPoint(x: cyl_w * 0.5, y: -views.logo.bounds.height + 20)
        views.loading.center = CGPoint(x: cyl_w - 30, y: cyl_h * 0.5)
    }

    // The refresh state
    override var state: CYLRefreshState {
        didSet {
            guard state != oldValue else { return }
            switch state {
            case .idle:
                views.loading.stopAnimating()
                views.toggle.setOn(false, animated: true)
                views.label.text = CYLScenarioLocalizedString(.mjDIYPullDown)
            case .pulling:
                views.loading.stopAnimating()
                views.toggle.setOn(true, animated: true)
                views.label.text = CYLScenarioLocalizedString(.mjDIYRelease)
            case .refreshing:
                views.toggle.setOn(true, animated: true)
                views.label.text = CYLScenarioLocalizedString(.mjDIYLoading)
                views.loading.startAnimating()
            default:
                break
            }
        }
    }

    // How far the control has been pulled out
    override var pullingPercent: CGFloat {
        didSet { views.follow(pullingPercent: pullingPercent) }
    }
}

/// MJDIYAutoFooter
final class CYLRefreshDIYAutoFooter: CYLRefreshAutoFooter {

    private let views = CYLRefreshDIYViews()

    override func prepare() {
        super.prepare()
        cyl_h = 50
        views.add(to: self, logo: false)
    }

    override func placeSubviews() {
        super.placeSubviews()
        // Between the switch and the spinner (72 pt each side), so long texts shrink instead of running under them.
        views.label.frame = bounds.insetBy(dx: 72, dy: 0)
        views.toggle.center = CGPoint(x: cyl_w - 40, y: cyl_h - 20)
        views.loading.center = CGPoint(x: 30, y: cyl_h * 0.5)
    }

    override var state: CYLRefreshState {
        didSet {
            guard state != oldValue else { return }
            switch state {
            case .idle:
                views.label.text = CYLScenarioLocalizedString(.mjDIYPullUp)
                views.loading.stopAnimating()
                views.toggle.setOn(false, animated: true)
            case .refreshing:
                views.toggle.setOn(true, animated: true)
                views.label.text = CYLScenarioLocalizedString(.mjDIYLoading)
                views.loading.startAnimating()
            case .noMoreData:
                views.label.text = CYLScenarioLocalizedString(.mjDIYNoMore)
                views.toggle.setOn(false, animated: true)
                views.loading.stopAnimating()
            default:
                break
            }
        }
    }
}

/// MJDIYBackFooter
final class CYLRefreshDIYBackFooter: CYLRefreshBackFooter {

    private let views = CYLRefreshDIYViews()

    override func prepare() {
        super.prepare()
        cyl_h = 50
        views.add(to: self, logo: true)
    }

    override func placeSubviews() {
        super.placeSubviews()
        // Between the switch and the spinner (72 pt each side), so long texts shrink instead of running under them.
        views.label.frame = bounds.insetBy(dx: 72, dy: 0)
        views.toggle.center = CGPoint(x: 40, y: cyl_h * 0.5)
        views.logo.bounds = CGRect(x: 0, y: 0, width: bounds.width, height: 100)
        views.logo.center = CGPoint(x: cyl_w * 0.5, y: cyl_h + views.logo.bounds.height * 0.5)
        views.loading.center = CGPoint(x: cyl_w - 30, y: cyl_h * 0.5)
    }

    override var state: CYLRefreshState {
        didSet {
            guard state != oldValue else { return }
            switch state {
            case .idle:
                views.loading.stopAnimating()
                views.toggle.setOn(false, animated: true)
                views.label.text = CYLScenarioLocalizedString(.mjDIYPullUp)
            case .pulling:
                views.loading.stopAnimating()
                views.toggle.setOn(true, animated: true)
                views.label.text = CYLScenarioLocalizedString(.mjDIYRelease)
            case .refreshing:
                views.loading.startAnimating()
                views.toggle.setOn(true, animated: true)
                views.label.text = CYLScenarioLocalizedString(.mjDIYLoading)
            case .noMoreData:
                views.loading.stopAnimating()
                views.label.text = CYLScenarioLocalizedString(.mjDIYNoMore)
                views.toggle.setOn(false, animated: true)
            default:
                break
            }
        }
    }

    override var pullingPercent: CGFloat {
        didSet { views.follow(pullingPercent: pullingPercent) }
    }
}
