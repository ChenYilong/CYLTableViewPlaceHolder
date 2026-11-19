//
//  CYLRefreshIconView.h
//  CYLTableViewPlaceHolder
//
//  [EN] The icon of a refresh control, drawn by the library's icon component (CYLPlaceholderView): a static image or
//       an animation file, GIF, Lottie, PAG or Rive (each needs its animation subspec, which adds the engine). The animated-image
//       controls (CYLRefreshAnimationHeader, CYLRefreshBackAnimationFooter, CYLRefreshAutoAnimationFooter, `CYLRefreshIconAnimating`) create
//       it only when an icon animation is set, place it where the animation view draws its images and hide that view; without an
//       icon animation nothing changes. The arrow and spinner controls keep their arrow and spinner.
//       The icon plays by a fixed policy that follows the control:
//       - idle, not pulled:          stopped on its resting frame
//       - idle, being pulled:        scrubbed to the pulling percent when the engine can seek (Lottie, PAG), else plays
//       - pulling (release to load): plays, looping
//       - refreshing / will refresh: plays, looping
//       - no more data:              stopped
//  [CN] 刷新控件的图标，由本库的图标组件（CYLPlaceholderView）绘制：静态图片，或 GIF、Lottie、PAG、Rive 动画文件（各自需要对应的动画子规格，由其带入引擎）。
//       只有设置了图标动画时，“动画图片”控件（CYLRefreshAnimationHeader、CYLRefreshBackAnimationFooter、CYLRefreshAutoAnimationFooter，见
//       `CYLRefreshIconAnimating`）才创建它，把它放在 动画视图绘制图片的位置并隐藏该视图；不设置时行为不变。箭头与菊花控件保持原样。图标按固定策略随控件状态播放：
//       空闲未拖动时停在静止帧；拖动中按下拉百分比定位（Lottie、PAG 可定位），否则播放；松开即可刷新时循环播放；
//       刷新中循环播放；没有更多数据时停止。
//
//  [EN] Swift since 2026-11-19: the class `CYLRefreshIconView` (with the former `CYLRefreshIconAttributes` category's class
//       members) is in `CYLRefreshIconView.swift` (docs/Swift-Migration.md, step 7), with the same Objective-C API; this
//       header keeps its forward declaration, the `CYLRefreshIconAnimating` protocol and the `CYLRefreshComponent
//       (CYLRefreshIconLayout)` category (implemented in `CYLRefreshComponent.m`).
//  [CN] 自 2026-11-19 起 `CYLRefreshIconView` 类（含原 `CYLRefreshIconAttributes` 分类的类成员）用 Swift 编写（`CYLRefreshIconView.swift`，
//       docs/Swift-Migration.md 第 7 步），Objective-C API 不变；本头文件保留其前向声明、`CYLRefreshIconAnimating` 协议与
//       `CYLRefreshComponent (CYLRefreshIconLayout)` 分类（实现在 `CYLRefreshComponent.m`）。
//

#import <UIKit/UIKit.h>
#import "CYLRefreshComponent.h"

NS_ASSUME_NONNULL_BEGIN

@class CYLPlaceholderView;

/*!
 * [EN] The icon of a refresh control, drawn by the library's icon component (CYLPlaceholderView): a static image or a
 *      GIF, Lottie, PAG or Rive animation that plays by the control's state, as the file header describes. The class is
 *      Swift (`CYLRefreshIconView.swift`), with the same Objective-C API (`-setAnimationAttributes:forState:`,
 *      `-animationAttributesForState:`, `hasAnimations`, `placeholderView`, `iconSize`, `title`, `titleFont`, `titleColor`,
 *      `fittingSize`, `scrubsWhilePulling`, `animationSpeed`, `loopsWhilePlaying`, `-replayAnimation`, `-updateForState:`,
 *      `-updateForPullingPercent:`, and the class members `+attributesForAnimationFilePath:size:`,
 *      `+attributesForBundledAnimation:size:`, `bundledAnimationFileNames`); Objective-C code that messages it imports
 *      the umbrella header `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] 刷新控件的图标，由本库的图标组件（CYLPlaceholderView）绘制：静态图片或 GIF、Lottie、PAG、Rive 动画，按文件开头所述随控件状态播放。
 *      该类用 Swift 编写（`CYLRefreshIconView.swift`），Objective-C API 不变；需要调用它的 Objective-C 代码请导入总头文件
 *      `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshIconView;

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
/*!
 * [EN] The one implementation of `setAnimationImages:duration:forState:` for the animation header and both animation
 *      footers: keeps the images of `state`, grows the control to the tallest image and shows them as the icon
 *      (`cyl_setIconImages:duration:forState:`). nil is ignored.
 * [CN] 动画刷新头与两种动画尾部的 `setAnimationImages:duration:forState:` 的唯一实现：保存 `state` 的图片，控件高度随最高的图片
 *      增大，并作为图标显示（`cyl_setIconImages:duration:forState:`）。nil 被忽略。
 */
- (void)cyl_setAnimationImages:(nullable NSArray<UIImage *> *)images duration:(NSTimeInterval)duration
                      forState:(CYLRefreshState)state NS_SWIFT_NAME(cyl_setAnimationImages(_:duration:for:));
/*!
 * [EN] The images set for `state` with `cyl_setAnimationImages:duration:forState:`, or nil.
 * [CN] 用 `cyl_setAnimationImages:duration:forState:` 为 `state` 设置的图片，或 nil。
 */
- (nullable NSArray<UIImage *> *)cyl_animationImagesForState:(CYLRefreshState)state
    NS_SWIFT_NAME(cyl_animationImages(for:));
/*!
 * [EN] While idle, shows the idle images' frame for the current `pullingPercent`. [CN] 空闲时显示空闲图片中与当前 `pullingPercent` 对应的帧。
 */
- (void)cyl_showIdleAnimationFrame;
/*!
 * [EN] The one implementation of `CYLRefreshIconAnimating`'s `setIconAnimationFilePath:size:forState:`.
 * [CN] `CYLRefreshIconAnimating` 的 `setIconAnimationFilePath:size:forState:` 的唯一实现。
 */
- (void)cyl_setIconAnimationFilePath:(NSString *)filePath size:(CGSize)size forState:(CYLRefreshState)state
    NS_SWIFT_NAME(cyl_setIconAnimation(filePath:size:for:));
/*!
 * [EN] The one implementation of `CYLRefreshIconAnimating`'s `setBundledIconAnimation:size:forState:`.
 * [CN] `CYLRefreshIconAnimating` 的 `setBundledIconAnimation:size:forState:` 的唯一实现。
 */
- (void)cyl_setBundledIconAnimation:(NSString *)fileName size:(CGSize)size forState:(CYLRefreshState)state
    NS_SWIFT_NAME(cyl_setBundledIconAnimation(_:size:for:));
@end

NS_ASSUME_NONNULL_END
