//
//  CYLRefreshIconView.h
//  CYLTableViewPlaceHolder
//
//  [EN] The icon of a refresh control, drawn by the library's icon component (CYLPlaceholderView): a static image or
//       an animation file, GIF, Lottie, PAG or Rive (the last three need the matching subspec). The animated-image
//       controls (CYLRefreshAnimationHeader, CYLRefreshBackAnimationFooter, CYLRefreshAutoAnimationFooter, `CYLRefreshIconAnimating`) create
//       it only when an icon animation is set, place it where the animation view draws its images and hide that view; without an
//       icon animation nothing changes. The arrow and spinner controls keep their arrow and spinner.
//       The icon plays by a fixed policy that follows the control:
//       - idle, not pulled:          stopped on its resting frame
//       - idle, being pulled:        scrubbed to the pulling percent when the engine can seek (Lottie, PAG), else plays
//       - pulling (release to load): plays, looping
//       - refreshing / will refresh: plays, looping
//       - no more data:              stopped
//  [CN] 刷新控件的图标，由本库的图标组件（CYLPlaceholderView）绘制：静态图片，或 GIF、Lottie、PAG、Rive 动画文件（后三者需要对应的子规格）。
//       只有设置了图标动画时，“动画图片”控件（CYLRefreshAnimationHeader、CYLRefreshBackAnimationFooter、CYLRefreshAutoAnimationFooter，见
//       `CYLRefreshIconAnimating`）才创建它，把它放在 动画视图绘制图片的位置并隐藏该视图；不设置时行为不变。箭头与菊花控件保持原样。图标按固定策略随控件状态播放：
//       空闲未拖动时停在静止帧；拖动中按下拉百分比定位（Lottie、PAG 可定位），否则播放；松开即可刷新时循环播放；
//       刷新中循环播放；没有更多数据时停止。
//

#import <UIKit/UIKit.h>
#import "CYLRefreshComponent.h"

NS_ASSUME_NONNULL_BEGIN

@class CYLPlaceholderView;

@interface CYLRefreshIconView : UIView

/*!
 * [EN] The item attributes of CYLPlaceholderView for a state, such as `CYLPlaceholderItemAnimationFilePath`,
 *      `CYLPlaceholderItemAnimationSize`, `CYLPlaceholderItemAnimationOptions`, `CYLPlaceholderItemAnimationColors` or
 *      `CYLPlaceholderItemImage`; nil removes it. A state without attributes uses the idle state's.
 * [CN] 某个状态的 CYLPlaceholderView item 属性；nil 表示移除。没有属性的状态使用空闲状态的属性。
 */
- (void)setAnimationAttributes:(nullable NSDictionary<NSString *, id> *)attributes forState:(CYLRefreshState)state
    NS_SWIFT_NAME(setAnimationAttributes(_:for:));
/*!
 * [EN] The attributes set for a state, without the idle fallback. [CN] 某个状态设置的属性（不含空闲状态的回退）。
 */
- (nullable NSDictionary<NSString *, id> *)animationAttributesForState:(CYLRefreshState)state
    NS_SWIFT_NAME(animationAttributes(for:));
/*!
 * [EN] YES when any state has attributes. [CN] 任意状态设置了属性时为 YES。
 */
@property (nonatomic, readonly) BOOL hasAnimations;
/*!
 * [EN] The icon component showing the current state's attributes; nil before any is set or when they are invalid.
 * [CN] 显示当前状态属性的图标组件；尚未设置或属性无效时为 nil。
 */
@property (nonatomic, strong, readonly, nullable) CYLPlaceholderView *placeholderView;
/*!
 * [EN] The size the control lays the icon out at: `CYLPlaceholderItemAnimationSize` of the current state's attributes,
 *      else 30 × 30. [CN] 控件布局图标使用的尺寸：当前状态属性中的 `CYLPlaceholderItemAnimationSize`，否则为 30 × 30。
 */
@property (nonatomic, readonly) CGSize iconSize;
/*!
 * [EN] The text shown after the icon inside the same CYLPlaceholderView (horizontal axis), so icon and text are one
 *      view and cannot drift apart; nil shows the icon alone. The control sets it to its state text.
 * [CN] 在同一个 CYLPlaceholderView 中显示在图标之后的文字（横向排列），图标与文字是同一个视图，不会错位；nil 只显示图标。
 *      控件把它设为状态文字。
 */
@property (nonatomic, copy, nullable) NSString *title;
/*!
 * [EN] The font of `title` (the state label's font). [CN] `title` 的字体（状态文字的字体）。
 */
@property (nonatomic, strong, nullable) UIFont *titleFont;
/*!
 * [EN] The color of `title` (the state label's color). [CN] `title` 的颜色（状态文字的颜色）。
 */
@property (nonatomic, strong, nullable) UIColor *titleColor;
/*!
 * [EN] The size of the icon and its `title` together, as the CYLPlaceholderView measures them; `iconSize` without a
 *      title. [CN] 图标与 `title` 合在一起的尺寸，由 CYLPlaceholderView 测量；没有 title 时为 `iconSize`。
 */
@property (nonatomic, readonly) CGSize fittingSize;
/*!
 * [EN] YES (the default): while the idle control is pulled, the animation follows the pulling percent when the engine can
 *      seek. NO: it plays instead. [CN] YES（默认）：空闲状态下拖动时，可定位的动画跟随下拉百分比；NO：改为播放。
 */
@property (nonatomic) BOOL scrubsWhilePulling;

/*!
 * [EN] Applies the playback policy for the control's state; the control calls it. [CN] 按控件状态应用播放策略；由控件调用。
 */
- (void)updateForState:(CYLRefreshState)state NS_SWIFT_NAME(update(for:));
/*!
 * [EN] Follows the pulling percent while idle; the control calls it. [CN] 空闲状态下跟随下拉百分比；由控件调用。
 */
- (void)updateForPullingPercent:(CGFloat)pullingPercent NS_SWIFT_NAME(update(pullingPercent:));

@end

/*!
 * [EN] The icon animation of MJRefresh's animated images: CYLRefreshAnimationHeader, CYLRefreshBackAnimationFooter and
 *      CYLRefreshAutoAnimationFooter adopt it, next to `setAnimationImages:forState:`. The icon takes the place of the animation view and
 *      keeps its layout (centered in the control's height; centered, or right-aligned next to the text) and its show/hide
 *      timing. The MJRefresh names (CYLRefreshGifHeader, CYLRefreshBackGifFooter, CYLRefreshAutoGifFooter) are subclasses
 *      and adopt it too. The arrow and spinner controls (Normal header, footers, trailer) keep their arrow and spinner.
 * [CN] MJRefresh“动画图片”的图标动画：CYLRefreshAnimationHeader、CYLRefreshBackAnimationFooter、CYLRefreshAutoAnimationFooter 采用本协议，与
 *      `setAnimationImages:forState:` 并列。图标替换 动画视图并沿用其布局（在控件高度内垂直居中；水平居中，或靠右紧挨文字）与显示时机。箭头与
 *      菊花控件（Normal 刷新头、刷新尾、trailer）保持原有的箭头与菊花。MJRefresh 名称的子类（CYLRefreshGifHeader 等）同样采用本协议。
 */
@protocol CYLRefreshIconAnimating <NSObject>
/*!
 * [EN] The icon, created when an icon animation is first set; the animation view is then hidden. Without an icon animation the
 *      control draws its images as before. [CN] 图标，首次设置图标动画时创建，动画视图随之隐藏。不设置图标动画时控件照常绘制动画图片。
 */
@property (strong, nonatomic, readonly) CYLRefreshIconView *iconView;
/*!
 * [EN] YES once any icon animation is set. [CN] 设置了任意图标动画后为 YES。
 */
@property (nonatomic, readonly) BOOL usesIconView;
/*!
 * [EN] The icon for a state, as CYLPlaceholderView item attributes (`CYLPlaceholderItemAnimationFilePath`,
 *      `CYLPlaceholderItemAnimationSize`, `CYLPlaceholderItemAnimationOptions`, `CYLPlaceholderItemAnimationColors`…);
 *      nil removes it. A state without attributes uses the idle state's, so one call sets the icon for every state.
 * [CN] 某个状态的图标，使用 CYLPlaceholderView 的 item 属性；nil 表示移除。没有属性的状态使用空闲状态的属性，因此调用一次即可设置所有状态的图标。
 */
- (instancetype)setIconAnimationAttributes:(nullable NSDictionary<NSString *, id> *)attributes
                                  forState:(CYLRefreshState)state
    NS_SWIFT_NAME(setIconAnimation(attributes:for:));
/*!
 * [EN] An animation file (.gif, .json Lottie, .pag, .riv) at `size` for a state. [CN] 某个状态使用 `size` 大小的动画文件。
 */
- (instancetype)setIconAnimationFilePath:(NSString *)filePath size:(CGSize)size forState:(CYLRefreshState)state
    NS_SWIFT_NAME(setIconAnimation(filePath:size:for:));
/*!
 * [EN] An animation of the core bundle (`bundledIconAnimationFileNames`) at `size` for a state, with the options it needs.
 * [CN] 某个状态使用核心 bundle 中 `size` 大小的内置动画（见 `bundledIconAnimationFileNames`），并带上它需要的选项。
 */
- (instancetype)setBundledIconAnimation:(NSString *)fileName size:(CGSize)size forState:(CYLRefreshState)state
    NS_SWIFT_NAME(setIconAnimation(bundled:size:for:));
/*!
 * [EN] The animations of the core bundle meant for a refresh icon: the `CYLRefresh*` files and the placeholder
 *      animations that also suit a refresh control. [CN] 核心 bundle 中适合作为刷新图标的动画：`CYLRefresh*` 文件与同样适合刷新控件的占位动画。
 */
@property (class, nonatomic, readonly) NSArray<NSString *> *bundledIconAnimationFileNames;
@end

@interface CYLRefreshIconView (CYLRefreshIconAttributes)
/*!
 * [EN] The item attributes of an animation file at `size`; nil for an empty path. [CN] 动画文件在 `size` 大小下的 item 属性；路径为空时为 nil。
 */
+ (nullable NSDictionary<NSString *, id> *)attributesForAnimationFilePath:(NSString *)filePath size:(CGSize)size
    NS_SWIFT_NAME(attributes(forAnimationFilePath:size:));
/*!
 * [EN] The item attributes of a core-bundle animation at `size`, with the options it needs (Rive state machines, line
 *      icon colors); nil when the file is missing. [CN] 核心 bundle 动画在 `size` 大小下的 item 属性，带上所需选项；文件不存在时为 nil。
 */
+ (nullable NSDictionary<NSString *, id> *)attributesForBundledAnimation:(NSString *)fileName size:(CGSize)size
    NS_SWIFT_NAME(attributes(forBundledAnimation:size:));
/*!
 * [EN] The refresh icon animations of the core bundle (see `CYLRefreshIconAnimating`). [CN] 核心 bundle 中的刷新图标动画。
 */
@property (class, nonatomic, readonly) NSArray<NSString *> *bundledAnimationFileNames;
@end

/*!
 * [EN] The plumbing behind `CYLRefreshIconAnimating`, for refresh controls (and custom subclasses) that replace a view
 *      with the icon. [CN] `CYLRefreshIconAnimating` 背后的实现，供用图标替换某个视图的刷新控件（及自定义子类）使用。
 */
@interface CYLRefreshComponent (CYLRefreshIconLayout)
/*!
 * [EN] The icon, created on first use and following the control's state. [CN] 图标，首次使用时创建并跟随控件状态。
 */
@property (strong, nonatomic, readonly) CYLRefreshIconView *cyl_iconView;
/*!
 * [EN] YES once any icon animation is set. [CN] 设置了任意图标动画后为 YES。
 */
@property (nonatomic, readonly) BOOL cyl_usesIconView;
/*!
 * [EN] Sets the icon for a state and lays the control out again; nil removes it. [CN] 设置某个状态的图标并重新布局；nil 表示移除。
 */
- (void)cyl_setIconAnimationAttributes:(nullable NSDictionary<NSString *, id> *)attributes forState:(CYLRefreshState)state
    NS_SWIFT_NAME(cyl_setIconAnimation(attributes:for:));
/*!
 * [EN] When an icon animation is set: places the icon at `center` with `iconView.iconSize`, shows it when `visible`
 *      and hides `views` (the animation view it replaces). Call at the end of `placeSubviews`. Does nothing otherwise.
 * [CN] 设置了图标动画时：把图标以 `iconView.iconSize` 放在 `center`，`visible` 为 YES 时显示，并隐藏被替换的 `views`（动画视图）。
 *      在 `placeSubviews` 末尾调用；未设置时不做任何事。
 */
- (void)cyl_placeIconViewAtCenter:(CGPoint)center visible:(BOOL)visible replacingViews:(NSArray<UIView *> *)views
    NS_SWIFT_NAME(cyl_placeIconView(at:visible:replacing:));
/*!
 * [EN] The same without moving the icon, for the end of `setState:`. [CN] 同上但不移动图标，在 `setState:` 末尾调用。
 */
- (void)cyl_updateIconViewVisible:(BOOL)visible replacingViews:(NSArray<UIView *> *)views
    NS_SWIFT_NAME(cyl_updateIconView(visible:replacing:));
/*!
 * [EN] When an icon animation is set: shows the icon and `title` as one CYLPlaceholderView centered in the control,
 *      and fades out `labels` (the state and time labels whose text it carries) and hides `views` (the animation view).
 *      When not `visible`, the labels come back and the icon hides. Call at the end of `placeSubviews` and `setState:`.
 * [CN] 设置了图标动画时：把图标与 `title` 作为一个 CYLPlaceholderView 居中显示在控件中，淡出 `labels`（文字已由它显示的状态与时间
 *      文字），并隐藏 `views`（动画视图）。`visible` 为 NO 时恢复文字并隐藏图标。在 `placeSubviews` 与 `setState:` 末尾调用。
 */
- (void)cyl_placeIconViewWithTitle:(nullable NSString *)title labels:(NSArray<UILabel *> *)labels visible:(BOOL)visible
                    replacingViews:(NSArray<UIView *> *)views
    NS_SWIFT_NAME(cyl_placeIconView(title:labels:visible:replacing:));
/*!
 * [EN] MJRefresh's image sequences (`setAnimationImages:` / `setImages:`) as the icon of a state, drawn by the icon's
 *      CYLPlaceholderView like any other icon: several images play as one animated image of `duration` seconds; the
 *      idle state shows one frame, chosen by `cyl_showIconImageFrameOf:pullingPercent:`. The idle state, when it has no
 *      icon yet, gets the first image as a still frame. With Reduce Motion on, the first image stays still.
 * [CN] MJRefresh 的图片序列（`setAnimationImages:` / `setImages:`）作为某个状态的图标，与其他图标一样由图标的 CYLPlaceholderView
 *      绘制：多张图片作为一张时长 `duration` 秒的动画图片播放；空闲状态只显示一帧，由 `cyl_showIconImageFrameOf:pullingPercent:`
 *      选择。空闲状态尚无图标时，以第一张图片作为静止帧。开启“减弱动态效果”时，第一张图片保持静止。
 */
- (void)cyl_setIconImages:(NSArray<UIImage *> *)images duration:(NSTimeInterval)duration forState:(CYLRefreshState)state
    NS_SWIFT_NAME(cyl_setIconImages(_:duration:for:));
/*!
 * [EN] While idle, shows the frame of `images` that matches `pullingPercent`, as MJRefresh does while pulling.
 * [CN] 空闲时显示 `images` 中与 `pullingPercent` 对应的那一帧，与 MJRefresh 下拉时的做法相同。
 */
- (void)cyl_showIconImageFrameOf:(nullable NSArray<UIImage *> *)images pullingPercent:(CGFloat)pullingPercent
    NS_SWIFT_NAME(cyl_showIconImageFrame(of:pullingPercent:));
@end

NS_ASSUME_NONNULL_END
