//
//  CYLRefreshIconView.swift
//  CYLTableViewPlaceHolder
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 7), with the same Objective-C API: the class name, the
//      selectors and the former `NS_SWIFT_NAME` spellings as the Swift names (`setAnimationAttributes(_:for:)`,
//      `animationAttributes(for:)`, `update(for:)`, `update(pullingPercent:)`), the properties, `-replayAnimation`, and the
//      class members of the former `CYLRefreshIconView (CYLRefreshIconAttributes)` category. The playback policy is the one
//      the header describes, with the 2026-11-19 speed / loop / replay API; bundled icons keep their attributes without
//      the scenario repeat count. The `CYLRefreshIconAnimating` protocol stays in `CYLRefreshIconView.h`; the
//      `CYLRefreshComponent (CYLRefreshIconLayout)` methods are a Swift extension in `CYLRefreshComponent.swift` (step 12).
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 7 步），Objective-C API 不变：类名、选择器、原 `NS_SWIFT_NAME` 写法作为
//      Swift 名称（`setAnimationAttributes(_:for:)`、`animationAttributes(for:)`、`update(for:)`、`update(pullingPercent:)`）、各属性、
//      `-replayAnimation`，以及原 `CYLRefreshIconView (CYLRefreshIconAttributes)` 分类的类成员。播放策略与头文件所述相同，包括 2026-11-19
//      的速度 / 循环 / 重播 API；内置图标保留其属性，但去掉场景的播放次数。`CYLRefreshIconAnimating` 协议保留在 `CYLRefreshIconView.h`；`CYLRefreshComponent
//      (CYLRefreshIconLayout)` 的方法是 `CYLRefreshComponent.swift` 中的 Swift 扩展（第 12 步）。

import UIKit

/**
 * [EN] The icon of a refresh control, drawn by the library's icon component (CYLPlaceholderView): a static image or a
 *      GIF, Lottie, PAG or Rive animation that plays by the control's state, as `CYLRefreshIconView.h` describes.
 * [CN] 刷新控件的图标，由本库的图标组件（CYLPlaceholderView）绘制：静态图片或 GIF、Lottie、PAG、Rive 动画，按
 *      `CYLRefreshIconView.h` 所述随控件状态播放。
 */
@objc(CYLRefreshIconView)
open class CYLRefreshIconView: UIView {

    // [EN] The default icon size, about the arrow's height. [CN] 默认图标尺寸，约为箭头的高度。
    private static let defaultSide: CGFloat = 30

    // [EN] The attributes of each state, keyed by the state's raw value; an `NSMutableDictionary`, as before, so the
    //      "any state" fallback picks the same entry.
    // [CN] 每个状态的属性，以状态的原始值为 key；与之前一样使用 `NSMutableDictionary`，使“任意状态”回退选中相同的条目。
    private let stateAttributes = NSMutableDictionary()
    // [EN] The attributes the current placeholder view was built from. [CN] 当前图标组件所用的属性。
    private var shownAttributes: NSDictionary?
    private var state: CYLRefreshState = .idle
    private var pullingPercent: CGFloat = 0
    // [EN] Whether the icon is playing now, so repeated updates do not restart it. [CN] 当前是否在播放，避免重复更新时重新开始。
    private var playing = false

    /**
     * [EN] The icon component showing the current state's attributes; nil before any is set or when they are invalid.
     * [CN] 显示当前状态属性的图标组件；尚未设置或属性无效时为 nil。
     */
    @objc public private(set) var placeholderView: CYLPlaceholderView?

    /**
     * [EN] YES (the default): while the idle control is pulled, the animation follows the pulling percent when the engine
     *      can seek. NO: it plays instead.
     * [CN] YES（默认）：空闲状态下拖动时，可定位的动画跟随下拉百分比；NO：改为播放。
     */
    @objc public var scrubsWhilePulling = true

    /**
     * [EN] A clear, non-interactive icon, hidden from accessibility (the state label says what is happening).
     * [CN] 透明、不响应交互的图标，对辅助功能隐藏（状态文字已说明当前状态）。
     */
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
        // [EN] Decorative: the state label says what is happening. [CN] 装饰性内容：状态文字已说明当前状态。
        isAccessibilityElement = false
        accessibilityElementsHidden = true
    }

    /**
     * [EN] An icon from a storyboard or nib.
     * [CN] 从 storyboard 或 nib 创建的图标。
     */
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /**
     * [EN] The component always fills the icon, centered in it, whatever size the control gives the icon.
     * [CN] 组件始终铺满图标并在其中居中，无论控件给图标的尺寸是多少。
     */
    open override func layoutSubviews() {
        super.layoutSubviews()
        placeholderView?.frame = bounds
    }

    // MARK: - Attributes

    /**
     * [EN] The item attributes of CYLPlaceholderView for a state, such as `CYLPlaceholderItemAnimationFilePath`,
     *      `CYLPlaceholderItemAnimationSize`, `CYLPlaceholderItemAnimationOptions`, `CYLPlaceholderItemAnimationColors` or
     *      `CYLPlaceholderItemImage`; nil removes it. A state without attributes uses the idle state's.
     * [CN] 某个状态的 CYLPlaceholderView item 属性；nil 表示移除。没有属性的状态使用空闲状态的属性。
     */
    @objc(setAnimationAttributes:forState:)
    public func setAnimationAttributes(_ attributes: [String: Any]?, for state: CYLRefreshState) {
        stateAttributes[NSNumber(value: state.rawValue)] = (attributes as NSDictionary?)?.copy()
        showAttributes(for: self.state)
        applyPlayback()
    }

    /**
     * [EN] The attributes set for a state, without the idle fallback.
     * [CN] 某个状态设置的属性（不含空闲状态的回退）。
     */
    @objc(animationAttributesForState:)
    public func animationAttributes(for state: CYLRefreshState) -> [String: Any]? {
        stateAttributes[NSNumber(value: state.rawValue)] as? [String: Any]
    }

    /**
     * [EN] YES when any state has attributes.
     * [CN] 任意状态设置了属性时为 YES。
     */
    @objc public var hasAnimations: Bool { stateAttributes.count > 0 }

    /**
     * [EN] The size the control lays the icon out at: `CYLPlaceholderItemAnimationSize` of the current state's attributes,
     *      else the size of an image icon, else 30 x 30.
     * [CN] 控件布局图标使用的尺寸：当前状态属性中的 `CYLPlaceholderItemAnimationSize`，否则为图片图标的尺寸，再否则为 30 × 30。
     */
    @objc public var iconSize: CGSize {
        // [EN] The size of the animation shown for the current state. [CN] 当前状态所显示动画的尺寸。
        let attributes = shownAttributes ?? attributesForState(state)
        let size = attributes?[CYLPlaceholderItemAnimationSize]
        if let value = size as? NSValue,
           strcmp(value.objCType, NSValue(cgSize: .zero).objCType) == 0 {
            return value.cgSizeValue
        }
        if let array = size as? NSArray, array.count == 2, let width = Self.doubleValue(of: array.firstObject) {
            // [EN] Any first element that answers `doubleValue` (a number or a string), as the Objective-C check.
            // [CN] 与 Objective-C 的检查相同：第一个元素只要响应 `doubleValue`（数字或字符串）即可。
            let height = Self.doubleValue(of: array.lastObject) ?? 0
            if width > 0 && height > 0 { return CGSize(width: width, height: height) }
        }
        // [EN] An image icon (MJRefresh's image sequences) has the image's size. [CN] 图片图标（MJRefresh 的图片序列）使用图片尺寸。
        if let image = attributes?[CYLPlaceholderItemImage] as? UIImage, image.size.width > 0, image.size.height > 0 {
            return image.size
        }
        return CGSize(width: Self.defaultSide, height: Self.defaultSide)
    }

    // [EN] `doubleValue` of an object that answers it, else nil. [CN] 对象响应 `doubleValue` 时返回其值，否则为 nil。
    private static func doubleValue(of object: Any?) -> CGFloat? {
        guard let object = object as? NSObject, object.responds(to: #selector(getter: NSNumber.doubleValue)) else { return nil }
        return (object.value(forKey: "doubleValue") as? NSNumber).map { CGFloat($0.doubleValue) }
    }

    // [EN] The state's attributes, else the idle state's, else any. [CN] 该状态的属性，否则空闲状态的，否则任意一个。
    private func attributesForState(_ state: CYLRefreshState) -> NSDictionary? {
        (stateAttributes[NSNumber(value: state.rawValue)] as? NSDictionary)
            ?? (stateAttributes[NSNumber(value: CYLRefreshState.idle.rawValue)] as? NSDictionary)
            ?? ((stateAttributes.allValues as NSArray).firstObject as? NSDictionary)
    }

    /**
     * [EN] The size of the icon and its `title` together, as the CYLPlaceholderView measures them; `iconSize` without a
     *      title.
     * [CN] 图标与 `title` 合在一起的尺寸，由 CYLPlaceholderView 测量；没有 title 时为 `iconSize`。
     */
    @objc public var fittingSize: CGSize {
        guard let title = title, !title.isEmpty, let view = placeholderView else { return iconSize }
        view.preferredMaxLayoutWidth = .greatestFiniteMagnitude
        let size = view.intrinsicContentSize
        return CGSize(width: ceil(size.width), height: max(ceil(size.height), iconSize.height))
    }

    private var storedTitle: String?

    /**
     * [EN] The text shown after the icon inside the same CYLPlaceholderView (horizontal axis), so icon and text are one
     *      view and cannot drift apart; nil shows the icon alone. The control sets it to its state text.
     * [CN] 在同一个 CYLPlaceholderView 中显示在图标之后的文字（横向排列），图标与文字是同一个视图，不会错位；nil 只显示图标。
     *      控件把它设为状态文字。
     */
    @objc public var title: String? {
        get { storedTitle }
        set {
            if newValue == storedTitle { return }
            let hadTitle = !(storedTitle ?? "").isEmpty
            storedTitle = newValue
            if hadTitle != !(newValue ?? "").isEmpty {
                // [EN] With or without a title is a different layout: rebuild. [CN] 有无标题是不同的布局：重建。
                shownAttributes = nil
                showAttributes(for: state)
                applyPlayback()
            } else {
                // [EN] A new text only: update it in place, so the animation keeps playing. [CN] 只换文字：原地更新，动画不中断。
                placeholderView?.textLabel.text = newValue
                placeholderView?.invalidateIntrinsicContentSize()
            }
        }
    }

    private var storedTitleFont: UIFont?

    /**
     * [EN] The font of `title` (the state label's font).
     * [CN] `title` 的字体（状态文字的字体）。
     */
    @objc public var titleFont: UIFont? {
        get { storedTitleFont }
        set {
            storedTitleFont = newValue
            if let font = newValue { placeholderView?.textLabel.font = font }
        }
    }

    private var storedTitleColor: UIColor?

    /**
     * [EN] The color of `title` (the state label's color).
     * [CN] `title` 的颜色（状态文字的颜色）。
     */
    @objc public var titleColor: UIColor? {
        get { storedTitleColor }
        set {
            storedTitleColor = newValue
            if let color = newValue { placeholderView?.textLabel.textColor = color }
        }
    }

    // [EN] The state's attributes with the title after the icon, laid out horizontally, when there is a title.
    // [CN] 有标题时：在状态属性中加入图标之后的标题，横向排列。
    private func displayAttributes(_ attributes: NSDictionary) -> NSDictionary {
        guard let title = title, !title.isEmpty else { return attributes }
        let display = attributes.mutableCopy() as! NSMutableDictionary
        display[CYLPlaceholderItemTitle] = title
        display[CYLPlaceholderItemContentAxis] = "horizontal"
        if let font = titleFont { display[CYLPlaceholderItemTitleFont] = font }
        if let color = titleColor { display[CYLPlaceholderItemTitleColor] = color }
        return display
    }

    private func showAttributes(for state: CYLRefreshState) {
        let attributes = attributesForState(state)
        if let attributes = attributes, let shown = shownAttributes, attributes.isEqual(shown),
           placeholderView != nil {
            return
        }
        if attributes == nil && shownAttributes == nil && placeholderView == nil { return }
        placeholderView?.removeFromSuperview()
        placeholderView = nil
        shownAttributes = attributes
        playing = false
        guard let attributes = attributes else { return }
        let view: CYLPlaceholderView
        do {
            view = try CYLPlaceholderView(itemAttributes: displayAttributes(attributes) as! [AnyHashable: Any], imageBundle: nil)
        } catch {
            NSLog("CYLRefresh: icon animation not shown: %@", error.localizedDescription)
            return
        }
        // [EN] Stopped until the policy plays it; it would otherwise start when it enters the window.
        // [CN] 在播放策略开始播放前保持停止；否则进入 window 时会自动播放。
        view.stopPlaceholderAnimation()
        view.backgroundColor = .clear
        // [EN] The icon fills its own frame: the component's 16-point placeholder margins left no room in a 30-point icon.
        // [CN] 图标铺满自身 frame：组件默认的 16 点占位图边距在 30 点的图标里没有空间。
        view.contentMargin = 0
        view.reportsContentSize = true
        view.isUserInteractionEnabled = false
        view.isAccessibilityElement = false
        view.accessibilityElementsHidden = true
        if animationSpeed != 1 { view.setPlaceholderAnimationSpeed(animationSpeed) }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        placeholderView = view
    }

    // MARK: - Playback policy

    /**
     * [EN] Applies the playback policy for the control's state; the control calls it.
     * [CN] 按控件状态应用播放策略；由控件调用。
     */
    @objc(updateForState:)
    public func update(for state: CYLRefreshState) {
        self.state = state
        if state != .idle { pullingPercent = 0 }
        showAttributes(for: state)
        applyPlayback()
    }

    /**
     * [EN] Follows the pulling percent while idle; the control calls it.
     * [CN] 空闲状态下跟随下拉百分比；由控件调用。
     */
    @objc(updateForPullingPercent:)
    public func update(pullingPercent: CGFloat) {
        self.pullingPercent = pullingPercent.isFinite ? max(0, pullingPercent) : 0
        if state == .idle { applyPlayback() }
    }

    private func applyPlayback() {
        guard let view = placeholderView else { return }
        switch state {
        case .pulling, .refreshing, .willRefresh:
            playLooping()
        case .noMoreData:
            stop()
        default:
            if pullingPercent <= 0 {
                stop()
            } else if scrubsWhilePulling && view.setPlaceholderAnimationProgress(min(1, pullingPercent)) {
                // [EN] Seeking stops the animation on that frame. [CN] 定位会把动画停在该帧。
                playing = false
            } else {
                playLooping()
            }
        }
    }

    private func playLooping() {
        if playing { return }
        applyRepeatCount()
        placeholderView?.playPlaceholderAnimation()
        playing = true
    }

    // [EN] An animation that names its own repeat count keeps it; otherwise it loops while the control acts, or plays
    //      once when `loopsWhilePlaying` is NO.
    // [CN] 属性中指定了播放次数的动画保持该设置；否则在控件工作期间循环播放，`loopsWhilePlaying` 为 NO 时播放一次。
    private func applyRepeatCount() {
        if shownAttributes?[CYLPlaceholderItemAnimationRepeatCount] != nil { return }
        placeholderView?.animationRepeatCount = loopsWhilePlaying ? 0 : 1
    }

    private var storedAnimationSpeed: CGFloat = 1

    /**
     * [EN] The playback rate of the icon's animation, 1 by default, applied live and kept when the icon changes with the
     *      state (the examples' speed slider, docs/Example-Animation-Playback.md; Android and HarmonyOS
     *      `animationSpeed`). Engines without a playback speed (PAG on iOS) ignore it. Values that are not positive and
     *      finite are ignored.
     * [CN] 图标动画的播放速率，默认 1，实时生效，图标随状态切换时保持（示例的倍速滑块）。没有播放速度的引擎（iOS 上的 PAG）忽略它。
     *      非正数或非有限值被忽略。
     */
    @objc public var animationSpeed: CGFloat {
        get { storedAnimationSpeed }
        set {
            if !newValue.isFinite || newValue <= 0 || newValue == storedAnimationSpeed { return }
            storedAnimationSpeed = newValue
            placeholderView?.setPlaceholderAnimationSpeed(newValue)
        }
    }

    private var storedLoopsWhilePlaying = true

    /**
     * [EN] YES (the default): the icon loops while it plays (pulling, refreshing); NO plays it once and rests on its last
     *      frame (the examples' loop switch; Android and HarmonyOS `loopsWhilePlaying`). Applied live. An animation whose
     *      attributes name `CYLPlaceholderItemAnimationRepeatCount` keeps that count.
     * [CN] YES（默认）：播放时（下拉、刷新中）循环；NO：播放一次并停在最后一帧（示例的循环开关）。实时生效。属性中指定了
     *      `CYLPlaceholderItemAnimationRepeatCount` 的动画保持该次数。
     */
    @objc public var loopsWhilePlaying: Bool {
        get { storedLoopsWhilePlaying }
        set {
            storedLoopsWhilePlaying = newValue
            // [EN] Only while playing: a stopped icon gets the count when it plays. [CN] 只在播放时设置；停止的图标在播放时获得该次数。
            if playing { applyRepeatCount() }
        }
    }

    /**
     * [EN] Restarts the shown icon from its first frame with the current speed and loop setting (the examples' Play all;
     *      Android and HarmonyOS `replayAnimation()`). Does nothing without an icon.
     * [CN] 以当前速度与循环设置从第一帧重新播放当前图标（示例的“全部播放”）。没有图标时不做任何事。
     */
    @objc public func replayAnimation() {
        guard let view = placeholderView else { return }
        applyRepeatCount()
        // [EN] playPlaceholderAnimation starts from progress 0. [CN] playPlaceholderAnimation 从进度 0 开始。
        view.playPlaceholderAnimation()
        playing = true
    }

    private func stop() {
        placeholderView?.stopPlaceholderAnimation()
        playing = false
    }

    // MARK: - Attribute builders (formerly the CYLRefreshIconAttributes category)

    /**
     * [EN] The item attributes of an animation file at `size`; nil for an empty path.
     * [CN] 动画文件在 `size` 大小下的 item 属性；路径为空时为 nil。
     */
    @objc(attributesForAnimationFilePath:size:)
    public class func attributes(forAnimationFilePath filePath: String, size: CGSize) -> [String: Any]? {
        if filePath.isEmpty { return nil }
        return [
            CYLPlaceholderItemAnimationFilePath: filePath,
            CYLPlaceholderItemAnimationSize: [NSNumber(value: Double(size.width)), NSNumber(value: Double(size.height))],
        ]
    }

    /**
     * [EN] The item attributes of a core-bundle animation at `size`, with the options it needs (Rive state machines, line
     *      icon colors); nil when the file is missing.
     * [CN] 核心 bundle 动画在 `size` 大小下的 item 属性，带上所需选项；文件不存在时为 nil。
     */
    @objc(attributesForBundledAnimation:size:)
    public class func attributes(forBundledAnimation fileName: String, size: CGSize) -> [String: Any]? {
        if CYLPlaceholderView.path(forBundledAnimation: fileName) == nil {
            NSLog("CYLRefresh: bundled animation %@ not found.", fileName)
            return nil
        }
        // [EN] The scenario builder adds the options a bundled file needs (Rive state machines, line icon colors).
        // [CN] 由场景组件构建方法补充内置文件需要的选项（Rive 状态机、线条图标颜色）。
        let component = CYLPlaceholderComponent(bundledAnimation: fileName, fallbackStyle: .refresh, title: nil, size: size,
                                                action: nil)
        // [EN] Without the scenario's default repeat count (0, loop): the refresh policy and `loopsWhilePlaying` decide.
        // [CN] 去掉场景默认的播放次数（0，循环）：由刷新播放策略与 `loopsWhilePlaying` 决定。
        var attributes = component.attributes
        attributes.removeValue(forKey: CYLPlaceholderItemAnimationRepeatCount)
        return attributes
    }

    /**
     * [EN] The refresh icon animations of the core bundle (see `CYLRefreshIconAnimating`): the `CYLRefresh*` files and the
     *      placeholder animations that also suit a refresh control.
     * [CN] 核心 bundle 中的刷新图标动画（见 `CYLRefreshIconAnimating`）：`CYLRefresh*` 文件与同样适合刷新控件的占位动画。
     */
    @objc public class var bundledAnimationFileNames: [String] {
        // [EN] The two placeholder animations whose content is also a refresh state: turning arrows and a ring that fills
        //      while pulling. Other placeholder files (scenes, hands, play arrows) are not refresh icons.
        // [CN] 内容同样表示刷新状态的两个占位动画：旋转箭头，以及随下拉填满的圆环。其他占位文件（场景、手势、播放箭头）不是刷新图标。
        let placeholderNames: Set<String> = ["CYLPlaceholderRefresh.json", "CYLPlaceholderProgress.pag"]
        return CYLPlaceholderView.bundledAnimationFileNames().filter {
            $0.hasPrefix("CYLRefresh") || placeholderNames.contains($0)
        }
    }
}
