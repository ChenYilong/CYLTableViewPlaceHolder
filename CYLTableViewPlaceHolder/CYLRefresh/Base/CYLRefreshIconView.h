//
//  CYLRefreshIconView.h
//  CYLTableViewPlaceHolder
//
//  [EN] The icon of a refresh control, drawn by the library's icon component (CYLPlaceholderView): a static image or
//       an animation file, GIF, Lottie, PAG or Rive (the last three need the matching subspec). A refresh header,
//       footer or trailer creates it only when an icon animation is set (`-[CYLRefreshComponent
//       setIconAnimationAttributes:forState:]`), places it where its arrow, spinner or GIF view sits, and hides those;
//       without an icon animation nothing changes. The icon plays by a fixed policy that follows the control:
//       - idle, not pulled:          stopped on its resting frame
//       - idle, being pulled:        scrubbed to the pulling percent when the engine can seek (Lottie, PAG), else plays
//       - pulling (release to load): plays, looping
//       - refreshing / will refresh: plays, looping
//       - no more data:              stopped
//  [CN] 刷新控件的图标，由本库的图标组件（CYLPlaceholderView）绘制：静态图片，或 GIF、Lottie、PAG、Rive 动画文件（后三者需要对应的子规格）。
//       只有设置了图标动画（`-[CYLRefreshComponent setIconAnimationAttributes:forState:]`）时，刷新头、尾或 trailer 才创建它，
//       把它放在原箭头、菊花或 GIF 视图的位置并隐藏它们；不设置时行为不变。图标按固定策略随控件状态播放：
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
/*! [EN] The attributes set for a state, without the idle fallback. [CN] 某个状态设置的属性（不含空闲状态的回退）。 */
- (nullable NSDictionary<NSString *, id> *)animationAttributesForState:(CYLRefreshState)state
    NS_SWIFT_NAME(animationAttributes(for:));
/*! [EN] YES when any state has attributes. [CN] 任意状态设置了属性时为 YES。 */
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
 * [EN] YES (the default): while the idle control is pulled, the animation follows the pulling percent when the engine can
 *      seek. NO: it plays instead. [CN] YES（默认）：空闲状态下拖动时，可定位的动画跟随下拉百分比；NO：改为播放。
 */
@property (nonatomic) BOOL scrubsWhilePulling;

/*! [EN] Applies the playback policy for the control's state; the control calls it. [CN] 按控件状态应用播放策略；由控件调用。 */
- (void)updateForState:(CYLRefreshState)state NS_SWIFT_NAME(update(for:));
/*! [EN] Follows the pulling percent while idle; the control calls it. [CN] 空闲状态下跟随下拉百分比；由控件调用。 */
- (void)updateForPullingPercent:(CGFloat)pullingPercent NS_SWIFT_NAME(update(pullingPercent:));

@end

/*! [EN] For refresh controls (and custom subclasses) that draw an icon. [CN] 供绘制图标的刷新控件（及自定义子类）使用。 */
@interface CYLRefreshComponent (CYLRefreshIconLayout)
/*!
 * [EN] When an icon animation is set: places the icon at `center` with `iconView.iconSize`, shows it when `visible`
 *      (where the replaced view would show, so the layout and show/hide strategy stay the control's own) and hides
 *      `views` (the arrow, spinner or GIF view it replaces). Call at the end of `placeSubviews`. Does nothing otherwise.
 * [CN] 设置了图标动画时：把图标以 `iconView.iconSize` 放在 `center`，`visible` 为 YES 时显示（与被替换视图的显示时机一致，布局与
 *      显示策略保持控件原有的），并隐藏被替换的 `views`（箭头、菊花或 GIF 视图）。在 `placeSubviews` 末尾调用；未设置时不做任何事。
 */
- (void)cyl_placeIconViewAtCenter:(CGPoint)center visible:(BOOL)visible replacingViews:(NSArray<UIView *> *)views
    NS_SWIFT_NAME(cyl_placeIconView(at:visible:replacing:));
/*! [EN] The same without moving the icon, for the end of `setState:`. [CN] 同上但不移动图标，在 `setState:` 末尾调用。 */
- (void)cyl_updateIconViewVisible:(BOOL)visible replacingViews:(NSArray<UIView *> *)views
    NS_SWIFT_NAME(cyl_updateIconView(visible:replacing:));
@end

NS_ASSUME_NONNULL_END
