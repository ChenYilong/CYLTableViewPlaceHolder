//
//  CYLRefreshIconTests.swift
//  CYLTableViewPlaceHolder tests
//
//  [EN] The animated icon of MJRefresh's animated images (CYLRefreshIconAnimating): the GIF header and footers keep their
//       images until an icon animation is set; then the icon takes the GIF view's place with its layout and plays by a
//       fixed policy. The arrow and spinner controls keep their arrow and spinner. Swift since 2026-11-20
//       (docs/Swift-Migration.md, step 13).
//  [CN] MJRefresh 动画图片的动画图标（CYLRefreshIconAnimating）：GIF 刷新头与刷新尾在设置图标动画之前保留图片；之后图标以其布局取代 GIF
//       视图，并按固定策略播放。箭头与菊花控件保留箭头与菊花。自 2026-11-20 起用 Swift 编写（docs/Swift-Migration.md 第 13 步）。
//

import UIKit
import XCTest

/**
 * [EN] The animated icon of MJRefresh's animated images (CYLRefreshIconAnimating).
 * [CN] MJRefresh 动画图片的动画图标（CYLRefreshIconAnimating）。
 */
final class CYLRefreshIconTests: XCTestCase {

    private func layOut(_ component: CYLRefreshComponent) {
        component.frame = CGRect(x: 0, y: 0, width: 320, height: 54)
        component.setNeedsLayout()
        component.layoutIfNeeded()
    }

    private func conformsToIconAnimating(_ cls: AnyClass) -> Bool {
        cls.conforms(to: CYLRefreshIconAnimating.self)
    }

    func testTheArrowAndSpinnerControlsKeepTheirArrowAndSpinner() {
        XCTAssertFalse(conformsToIconAnimating(CYLRefreshNormalHeader.self))
        XCTAssertFalse(conformsToIconAnimating(CYLRefreshBackNormalFooter.self))
        XCTAssertFalse(conformsToIconAnimating(CYLRefreshAutoNormalFooter.self))
        XCTAssertFalse(conformsToIconAnimating(CYLRefreshNormalTrailer.self))
        XCTAssertTrue(conformsToIconAnimating(CYLRefreshAnimationHeader.self))
        XCTAssertTrue(conformsToIconAnimating(CYLRefreshBackAnimationFooter.self))
        XCTAssertTrue(conformsToIconAnimating(CYLRefreshAutoAnimationFooter.self))
        let header = CYLRefreshNormalHeader(refreshingBlock: {})
        layOut(header)
        XCTAssertFalse(header.arrowView.isHidden, "the default arrow, as in MJRefresh")
        for subview in header.subviews {
            XCTAssertFalse(subview is CYLRefreshIconView)
        }
    }

    private func assertNoIcon(in control: UIView) {
        for subview in control.subviews {
            XCTAssertFalse(subview is CYLRefreshIconView, "\(type(of: control)) never creates an icon view")
        }
    }

    func testTheDefaultArrowControlsKeepMJRefreshsArrowLogic() {
        // [EN] The arrow controls are the pre-icon code: the arrow image, its rotation and the spinner per state.
        // [CN] 箭头控件是图标改造前的代码：箭头图片、按状态旋转箭头与菊花。
        let header = CYLRefreshNormalHeader(refreshingBlock: {})
        layOut(header)
        XCTAssertEqual(header.arrowView.image, Bundle.cyl_arrowImage())
        XCTAssertFalse(header.arrowView.isHidden)
        XCTAssertTrue(header.arrowView.transform.isIdentity, "idle: the arrow points down")
        header.state = .pulling
        XCTAssertEqual(header.arrowView.transform.a, -1, accuracy: 0.001, "pulling: the arrow turns up")
        XCTAssertFalse(header.loadingView.isAnimating)
        header.state = .refreshing
        XCTAssertTrue(header.arrowView.isHidden, "refreshing: the spinner replaces the arrow")
        XCTAssertTrue(header.loadingView.isAnimating)
        assertNoIcon(in: header)

        let backFooter = CYLRefreshBackNormalFooter(refreshingBlock: {})
        layOut(backFooter)
        XCTAssertEqual(backFooter.arrowView.image, Bundle.cyl_arrowImage())
        backFooter.state = .pulling
        XCTAssertTrue(backFooter.arrowView.transform.isIdentity, "pulling: the footer arrow turns down")
        backFooter.state = .refreshing
        XCTAssertTrue(backFooter.arrowView.isHidden)
        XCTAssertTrue(backFooter.loadingView.isAnimating)
        backFooter.state = .noMoreData
        XCTAssertTrue(backFooter.arrowView.isHidden)
        XCTAssertFalse(backFooter.loadingView.isAnimating)
        assertNoIcon(in: backFooter)

        let autoFooter = CYLRefreshAutoNormalFooter(refreshingBlock: {})
        layOut(autoFooter)
        autoFooter.state = .refreshing
        XCTAssertTrue(autoFooter.loadingView.isAnimating)
        autoFooter.state = .noMoreData
        XCTAssertFalse(autoFooter.loadingView.isAnimating)
        assertNoIcon(in: autoFooter)

        let trailer = CYLRefreshNormalTrailer(refreshingBlock: {})
        layOut(trailer)
        XCTAssertEqual(trailer.arrowView.image, Bundle.cyl_trailArrowImage())
        assertNoIcon(in: trailer)
    }

    func testTheMJRefreshGifNamesCallTheGeneralAnimationMethods() {
        // [EN] The old names are subclasses of the general classes, so old code compiles and behaves the same.
        // [CN] 旧名称是通用类的子类，旧代码照常编译、行为不变。
        XCTAssertTrue(CYLRefreshGifHeader.isSubclass(of: CYLRefreshAnimationHeader.self))
        XCTAssertTrue(CYLRefreshBackGifFooter.isSubclass(of: CYLRefreshBackAnimationFooter.self))
        XCTAssertTrue(CYLRefreshAutoGifFooter.isSubclass(of: CYLRefreshAutoAnimationFooter.self))
        XCTAssertTrue(conformsToIconAnimating(CYLRefreshGifHeader.self))

        guard let small = CYLPlaceholderView.image(for: .refresh) else { return XCTFail("no refresh image") }
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 120))
        let tall = renderer.image { _ in }
        // [EN] The control grows to the first image's height. [CN] 控件高度随第一张图片增大。
        let images: [UIImage] = [tall, small]

        let header = CYLRefreshGifHeader(refreshingBlock: {})
        XCTAssertTrue(header.gifView === header.animationView, "gifView is the animation view")
        XCTAssertTrue(header.setImages(images, for: .refreshing) === header)
        XCTAssertEqual(header.frame.size.height, 120, accuracy: 0.5, "setImages: grows the control like setAnimationImages:")

        let autoFooter = CYLRefreshAutoGifFooter(refreshingBlock: {})
        XCTAssertTrue(autoFooter.gifView === autoFooter.animationView)
        XCTAssertTrue(autoFooter.setImages(images, duration: 1, for: .refreshing) === autoFooter)
        XCTAssertEqual(autoFooter.frame.size.height, 120, accuracy: 0.5)

        let backFooter = CYLRefreshBackGifFooter(refreshingBlock: {})
        XCTAssertTrue(backFooter.gifView === backFooter.animationView)
        XCTAssertTrue(backFooter.setImages(images, for: .pulling) === backFooter)
        XCTAssertEqual(backFooter.frame.size.height, 120, accuracy: 0.5)
    }

    func testWithoutImagesOrAnIconTheAnimationHeaderCreatesNothing() {
        let header = CYLRefreshAnimationHeader(refreshingBlock: {})
        layOut(header)
        XCTAssertFalse(header.usesIconView)
        header.setIconAnimation(attributes: nil, for: .idle)
        XCTAssertFalse(header.usesIconView, "removing nothing creates nothing")
        assertNoIcon(in: header)
    }

    func testImageSequencesAreDrawnByTheIconsPlaceholderViewWithTheStateText() {
        // [EN] MJRefresh's setImages: / setAnimationImages: go through the same CYLPlaceholderView as every other icon.
        // [CN] MJRefresh 的 setImages: / setAnimationImages: 与其他图标一样经过同一个 CYLPlaceholderView。
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 40, height: 40))
        var frames: [UIImage] = []
        for i in 0..<4 {
            frames.append(renderer.image { context in
                UIColor(white: CGFloat(i) / 4.0, alpha: 1).setFill()
                context.fill(CGRect(x: 0, y: 0, width: 40, height: 40))
            })
        }
        let header = CYLRefreshGifHeader(refreshingBlock: {})
        header.setImages(frames, for: .idle)
        header.setImages(frames, duration: 0.8, for: .refreshing)
        layOut(header)
        XCTAssertTrue(header.usesIconView)
        XCTAssertTrue(header.gifView.isHidden, "the image view stays for compatibility, hidden")
        let view = header.iconView.placeholderView
        XCTAssertTrue(view?.imageView.image === frames.first, "idle: a still frame")
        XCTAssertTrue(view?.textLabel.text?.hasPrefix(header.stateLabel?.text ?? "") ?? false, "the state text is in the same view")
        XCTAssertEqual(header.iconView.iconSize.width, 40, accuracy: 0.01, "the icon has the image's size")
        header.pullingPercent = 0.6
        XCTAssertTrue(header.iconView.placeholderView?.imageView.image === frames[2], "pulling picks the frame, as in MJRefresh")
        header.state = .refreshing
        layOut(header)
        let playing = header.iconView.placeholderView?.imageView.image
        XCTAssertEqual(playing?.images?.count, 4, "refreshing: the frames play as one animated image")
        XCTAssertEqual(playing?.duration ?? 0, 0.8, accuracy: 0.001)

        let autoFooter = CYLRefreshAutoGifFooter(refreshingBlock: {})
        autoFooter.setImages(frames, for: .refreshing)
        layOut(autoFooter)
        XCTAssertTrue(autoFooter.iconView.isHidden, "the auto footer shows its icon only while loading")
        autoFooter.state = .refreshing
        layOut(autoFooter)
        XCTAssertFalse(autoFooter.iconView.isHidden)
        XCTAssertTrue(autoFooter.gifView.isHidden)
        XCTAssertEqual(autoFooter.iconView.placeholderView?.imageView.image?.images?.count, 4)

        let backFooter = CYLRefreshBackGifFooter(refreshingBlock: {})
        backFooter.setImages(frames, for: .pulling)
        layOut(backFooter)
        XCTAssertTrue(backFooter.iconView.placeholderView?.imageView.image === frames.first,
                      "idle without its own images: the first image, still")
        backFooter.state = .pulling
        XCTAssertEqual(backFooter.iconView.placeholderView?.imageView.image?.images?.count, 4)
    }

    func testTheTrailerTextIsCompleteAndReadableInEveryLanguage() {
        // [EN] MJRefresh's one-character-wide column breaks English words letter by letter and cuts them off; CJK text
        //      stays upright, other text is rotated to read top to bottom and wraps instead of being cut off.
        // [CN] MJRefresh 一个字宽的竖列会把英文单词逐字母拆开并截断；中日韩文字保持正立，其他文字旋转后从上往下读，过长时换行而不截断。
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
        scrollView.contentSize = CGSize(width: 1600, height: 200)
        let trailer = CYLRefreshNormalTrailer(refreshingBlock: {})
        scrollView.cyl_trailer = trailer
        let label: UILabel = trailer.stateLabel

        trailer.setTitle("释放查看图文详情", for: .idle)
        trailer.setNeedsLayout()
        trailer.layoutIfNeeded()
        XCTAssertTrue(label.transform.isIdentity, "CJK: upright, as in MJRefresh")
        XCTAssertEqual(label.bounds.width, ceil(label.font.pointSize), accuracy: 0.5)

        for text in ["Release to see more", "Отпустите, чтобы посмотреть подробности",
                     "Release to see the details of this page, and keep reading what comes next"] {
            trailer.setTitle(text, for: .idle)
            trailer.setNeedsLayout()
            trailer.layoutIfNeeded()
            XCTAssertEqual(atan2(label.transform.b, label.transform.a), .pi / 2, accuracy: 0.001, "\(text): rotated")
            let needed = label.sizeThatFits(CGSize(width: label.bounds.width, height: .greatestFiniteMagnitude))
            XCTAssertLessThanOrEqual(needed.height, label.bounds.height + 0.5, "\(text): shown in full")
            XCTAssertLessThanOrEqual(label.frame.height, trailer.bounds.height + 0.5,
                                     "\(text): within the control's height")
            XCTAssertGreaterThan(label.frame.minX, trailer.arrowView.frame.maxX - 0.5,
                                 "\(text): right of the arrow")
        }
    }

    func testTheHeaderIsHiddenWhileIdleAndRetracted() {
        // [EN] iOS 26's glass navigation bar shows what is under it: the retracted header is masked out while idle.
        // [CN] iOS 26 的玻璃导航栏会透出下方内容：空闲时把收回的刷新头遮住。
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        scrollView.contentSize = CGSize(width: 320, height: 1000)
        let header = CYLRefreshNormalHeader(refreshingBlock: {})
        scrollView.cyl_header = header
        layOut(header)
        if #available(iOS 26.0, *) {
            XCTAssertTrue(header.autoHideRefresh, "on by default where the navigation bar is transparent by default")
        } else {
            XCTAssertFalse(header.autoHideRefresh, "off by default on earlier systems")
            header.autoHideRefresh = true
        }
        XCTAssertNotNil(header.layer.mask, "idle and retracted: masked out")
        XCTAssertTrue(header.accessibilityElementsHidden)
        XCTAssertFalse(header.isHidden, "the caller's hidden is not touched")
        XCTAssertEqual(header.alpha, 1, "nor alpha")
        scrollView.contentOffset = CGPoint(x: 0, y: -20)
        XCTAssertNil(header.layer.mask, "pulled down: shown")
        XCTAssertFalse(header.accessibilityElementsHidden)
        scrollView.contentOffset = CGPoint(x: 0, y: 200)
        XCTAssertNotNil(header.layer.mask, "scrolled away: hidden again")
        header.state = .refreshing
        XCTAssertNil(header.layer.mask, "refreshing: shown")
        header.state = .idle
        XCTAssertNil(header.layer.mask, "retracting after the refresh: still shown")
        header.autoHideRefresh = false
        header.pullingPercent = 0
        XCTAssertNil(header.layer.mask, "NO: MJRefresh's behavior")
    }

    func testAnIconAnimationAndTheStateTextAreOneCenteredPlaceholderView() {
        let header = CYLRefreshAnimationHeader(refreshingBlock: {})
        header.setIconAnimation(bundled: "CYLRefreshArrows.gif", size: CGSize(width: 36, height: 36), for: .idle)
        layOut(header)
        XCTAssertTrue(header.usesIconView)
        XCTAssertTrue(header.iconView.superview === header)
        XCTAssertTrue(header.animationView.isHidden)
        XCTAssertFalse(header.iconView.isHidden)
        // [EN] One CYLPlaceholderView holds the icon and both lines of text. [CN] 一个 CYLPlaceholderView 同时包含图标与两行文字。
        guard let view = header.iconView.placeholderView else { return XCTFail("no placeholder view") }
        let expected = "\(header.stateLabel?.text ?? "(null)")\n\(header.lastUpdatedTimeLabel?.text ?? "(null)")"
        XCTAssertEqual(view.textLabel.text, expected)
        XCTAssertEqual(header.stateLabel?.alpha, 0, "the label's text is inside the icon's view")
        XCTAssertEqual(header.lastUpdatedTimeLabel?.alpha, 0)
        XCTAssertFalse(header.stateLabel?.isHidden ?? true, "the caller's hidden setting is kept")
        XCTAssertEqual(header.iconView.center.x, header.bounds.midX, accuracy: 0.5, "icon and text centered as one")
        XCTAssertEqual(header.iconView.center.y, header.bounds.midY, accuracy: 0.5, "centered in the height")
        XCTAssertTrue(view.frame.equalTo(header.iconView.bounds))
        view.layoutIfNeeded()
        let icon = header.iconView.convert(view.imageView.frame, from: view.imageView.superview)
        let text = header.iconView.convert(view.textLabel.frame, from: view.textLabel.superview)
        XCTAssertTrue(icon.size == CGSize(width: 36, height: 36), NSCoder.string(for: icon))
        XCTAssertLessThanOrEqual(icon.maxX, text.minX, "the text follows the icon")
        XCTAssertEqual(icon.midY, text.midY, accuracy: 0.5, "icon and text share a center line")
        XCTAssertTrue(header.iconView.bounds.insetBy(dx: -0.5, dy: -0.5).contains(icon.union(text)))
        XCTAssertTrue(header.iconView.isAccessibilityElement, "VoiceOver reads the text from the view that shows it")
        XCTAssertEqual(header.iconView.accessibilityLabel, expected)
        XCTAssertTrue(header.stateLabel?.accessibilityElementsHidden ?? false)

        header.state = .refreshing
        layOut(header)
        XCTAssertTrue(header.iconView.placeholderView === view, "a new state text updates in place")
        XCTAssertTrue(view.textLabel.text?.hasPrefix(header.stateLabel?.text ?? "") ?? false)
        header.state = .idle

        header.stateLabel?.isHidden = true
        header.lastUpdatedTimeLabel?.isHidden = true
        layOut(header)
        XCTAssertEqual(header.iconView.center.x, header.bounds.midX, accuracy: 0.5, "centered without text")
        XCTAssertTrue(header.iconView.bounds.size == CGSize(width: 36, height: 36), "the icon alone")
    }

    func testThePlaybackFollowsTheControlState() {
        let header = CYLRefreshAnimationHeader(refreshingBlock: {})
        let loading = CYLPlaceholderView.path(forBundledAnimation: "CYLPlaceholderLoading.json") ?? ""
        header.setIconAnimation(filePath: loading, size: CGSize(width: 30, height: 30), for: .idle)
        let icon = header.iconView.placeholderView
        XCTAssertNotNil(icon)
        header.state = .refreshing
        XCTAssertEqual(icon?.animationRepeatCount, 0, "loops while refreshing")
        header.state = .idle
        header.pullingPercent = 0.5
        header.pullingPercent = 0
        // [EN] A different icon per state is swapped in. [CN] 每个状态可以使用不同的图标。
        header.setIconAnimation(bundled: "CYLPlaceholderRefresh.json", size: CGSize(width: 30, height: 30), for: .pulling)
        header.state = .pulling
        XCTAssertFalse(header.iconView.placeholderView === icon)
        header.state = .idle
        XCTAssertEqual(header.iconView.placeholderView?.itemAttributes[CYLPlaceholderItemAnimationFilePath] as? String, loading,
                       "other states fall back to the idle icon")
        XCTAssertNotNil(header.iconView.animationAttributes(for: .pulling))
        XCTAssertNil(header.iconView.animationAttributes(for: .refreshing))
    }

    func testSpeedLoopAndReplayFollowTheExamplesControls() {
        let header = CYLRefreshAnimationHeader(refreshingBlock: {})
        let loading = CYLPlaceholderView.path(forBundledAnimation: "CYLPlaceholderLoading.json") ?? ""
        header.setIconAnimation(filePath: loading, size: CGSize(width: 30, height: 30), for: .idle)
        let iconView = header.iconView
        XCTAssertEqual(iconView.animationSpeed, 1)
        XCTAssertTrue(iconView.loopsWhilePlaying)
        iconView.animationSpeed = 0
        iconView.animationSpeed = .nan
        XCTAssertEqual(iconView.animationSpeed, 1, "invalid speeds are ignored")
        iconView.loopsWhilePlaying = false
        header.state = .refreshing
        XCTAssertEqual(iconView.placeholderView?.animationRepeatCount, 1, "plays once with the loop off")
        iconView.loopsWhilePlaying = true
        XCTAssertEqual(iconView.placeholderView?.animationRepeatCount, 0, "loops again, live")
        iconView.animationSpeed = 2
        XCTAssertEqual(iconView.animationSpeed, 2)
        // [EN] A new icon for another state keeps the speed. [CN] 其他状态的新图标保持该速度。
        header.setIconAnimation(bundled: "CYLPlaceholderRefresh.json", size: CGSize(width: 30, height: 30), for: .pulling)
        header.state = .pulling
        if let lottie = iconView.placeholderView?.animationView {
            XCTAssertEqual((lottie.value(forKey: "animationSpeed") as? NSNumber)?.doubleValue ?? 0, 2, accuracy: 0.01)
        }
        iconView.loopsWhilePlaying = false
        iconView.replayAnimation()
        XCTAssertEqual(iconView.placeholderView?.animationRepeatCount, 1)
    }

    func testAnimationFootersShowTheIconWhenTheirImagesWouldShow() {
        let autoFooter = CYLRefreshAutoAnimationFooter(refreshingBlock: {})
        autoFooter.setIconAnimation(bundled: "CYLRefreshSpinnerRing.json", size: CGSize(width: 24, height: 24), for: .idle)
        layOut(autoFooter)
        XCTAssertTrue(autoFooter.iconView.isHidden, "an auto GIF footer shows its images only while loading")
        autoFooter.state = .refreshing
        layOut(autoFooter)
        XCTAssertFalse(autoFooter.iconView.isHidden)
        XCTAssertTrue(autoFooter.animationView.isHidden)
        XCTAssertEqual(autoFooter.iconView.center.y, autoFooter.bounds.midY, accuracy: 0.5)
        autoFooter.state = .noMoreData
        XCTAssertTrue(autoFooter.iconView.isHidden)

        let backFooter = CYLRefreshBackAnimationFooter(refreshingBlock: {})
        backFooter.setIconAnimation(bundled: "CYLRefreshPullArrow.json", size: CGSize(width: 24, height: 24), for: .idle)
        layOut(backFooter)
        XCTAssertFalse(backFooter.iconView.isHidden)
        XCTAssertTrue(backFooter.animationView.isHidden)
        XCTAssertEqual(backFooter.iconView.center.y, backFooter.bounds.midY, accuracy: 0.5)
        backFooter.state = .noMoreData
        XCTAssertTrue(backFooter.iconView.isHidden, "no more data shows the text only, as before")
    }

    func testMissingBundledAnimationsAreIgnored() {
        let footer = CYLRefreshBackAnimationFooter(refreshingBlock: {})
        footer.setIconAnimation(bundled: "Missing.json", size: CGSize(width: 20, height: 20), for: .idle)
        XCTAssertFalse(footer.usesIconView)
        footer.setIconAnimation(filePath: "", size: CGSize(width: 20, height: 20), for: .idle)
        XCTAssertFalse(footer.usesIconView)
    }

    func testEveryBundledRefreshAnimationBuildsAnIcon() {
        let names = CYLRefreshAnimationHeader.bundledIconAnimationFileNames
        XCTAssertEqual(names, CYLRefreshAutoAnimationFooter.bundledIconAnimationFileNames)
        var refreshFiles = 0
        for name in names {
            if name.hasPrefix("CYLRefresh") { refreshFiles += 1 }
            let header = CYLRefreshAnimationHeader(refreshingBlock: {})
            header.setIconAnimation(bundled: name, size: CGSize(width: 32, height: 32), for: .idle)
            XCTAssertTrue(header.usesIconView, name)
            let attributes = header.iconView.animationAttributes(for: .idle)
            XCTAssertEqual(((attributes?[CYLPlaceholderItemAnimationFilePath] as? String) as NSString?)?.lastPathComponent, name)
        }
        XCTAssertEqual(refreshFiles, 22, "\(names)")
        XCTAssertEqual(names.count, 24, "the CYLRefresh files plus two refresh-like placeholder files: \(names)")
        XCTAssertTrue(names.contains("CYLPlaceholderProgress.pag"), "PAG comes from the placeholder set")
        // [EN] Scenes, hands and play arrows are placeholder art, not refresh icons. [CN] 场景、手势与播放箭头是占位插画，不是刷新图标。
        for name in ["CYLPlaceholderPullToRefresh.riv", "CYLPlaceholderLoading.pag", "CYLPlaceholderPullHint.pag",
                     "CYLPlaceholderLoading.riv", "CYLPlaceholderUploading.gif"] {
            XCTAssertFalse(names.contains(name), name)
        }
        for pathExtension in ["gif", "json", "pag", "riv"] {
            let count = names.filter { ($0 as NSString).pathExtension == pathExtension }.count
            XCTAssertGreaterThan(count, 0, pathExtension)
        }
        let header = CYLRefreshAnimationHeader(refreshingBlock: {})
        header.setIconAnimation(bundled: "CYLRefreshIcon.riv", size: CGSize(width: 32, height: 32), for: .idle)
        let options = header.iconView.animationAttributes(for: .idle)?[CYLPlaceholderItemAnimationOptions] as? [String: Any]
        XCTAssertEqual(options?["artboard"] as? String, "refresh", "the bundled Rive file brings its options")
        XCTAssertEqual(options?["animation"] as? String, "active")
    }

    func testAPlaceholderGivesUpItsMarginsOnlyWhenTooNarrow() {
        guard let image = CYLPlaceholderView.image(for: .refresh) else { return XCTFail("no refresh image") }
        let view = CYLPlaceholderView(image: image, text: nil)
        XCTAssertEqual(view.contentMargin, 16, accuracy: 0.01, "a full-screen placeholder keeps 16 points")
        view.frame = CGRect(x: 0, y: 0, width: image.size.width + 8, height: 100)
        view.layoutIfNeeded()
        // [EN] The item frame: where the placeholder lays out its icon and title. [CN] item 区域：占位图布局图标与标题的位置。
        let item = (view.value(forKey: "itemFrame") as? NSValue)?.cgRectValue ?? .null
        XCTAssertGreaterThanOrEqual(item.width, image.size.width - 0.5, "no zero-width item")
        XCTAssertEqual(item.midX, view.bounds.midX, accuracy: 0.5)
        let text = CYLPlaceholderView(image: nil, text: "A long title that wraps over several lines of text")
        text.frame = CGRect(x: 0, y: 0, width: 200, height: 300)
        text.layoutIfNeeded()
        let textItem = (text.value(forKey: "itemFrame") as? NSValue)?.cgRectValue ?? .null
        XCTAssertGreaterThanOrEqual(textItem.minX, 16 - 0.5, "wrapping text keeps the margins")
    }

    func testHeaderAndFooterAutoHideCanBeSetSeparatelyOrTogether() {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        scrollView.contentSize = CGSize(width: 320, height: 1000)
        // [EN] Set before attaching: applied when the controls arrive. [CN] 挂上之前设置：控件挂上时生效。
        scrollView.cyl_autoHideRefreshHeader = false
        scrollView.cyl_autoHideRefreshFooter = true
        let header = CYLRefreshNormalHeader(refreshingBlock: {})
        let footer = CYLRefreshBackNormalFooter(refreshingBlock: {})
        scrollView.cyl_header = header
        scrollView.cyl_footer = footer
        XCTAssertFalse(header.autoHideRefresh)
        XCTAssertTrue(footer.autoHideRefresh)
        XCTAssertFalse(scrollView.cyl_autoHideRefresh, "YES only when both hide")
        footer.layoutIfNeeded()
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
        XCTAssertNotNil(footer.layer.mask, "idle footer below the bottom bar: hidden")
        XCTAssertNil(header.layer.mask, "header auto-hide is off")
        // [EN] Scrolled to the end and pulled: the footer shows. [CN] 滚到底并上拉：刷新尾显示。
        scrollView.contentOffset = CGPoint(x: 0, y: 1000 + 50 - 480 + 30)
        XCTAssertNil(footer.layer.mask, "pulled into view: shown")
        footer.state = .refreshing
        XCTAssertNil(footer.layer.mask, "loading: shown")
        footer.state = .idle
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
        XCTAssertNotNil(footer.layer.mask, "idle again and out of view: hidden")

        scrollView.cyl_autoHideRefresh = true
        XCTAssertTrue(header.autoHideRefresh && footer.autoHideRefresh && scrollView.cyl_autoHideRefresh)
        scrollView.cyl_autoHideRefresh = false
        XCTAssertFalse(header.autoHideRefresh || footer.autoHideRefresh)
        XCTAssertNil(footer.layer.mask, "off: never masked")
        XCTAssertFalse(footer.isHidden, "hidden is never touched")
    }
}
