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
//       header keeps its forward declaration and the `CYLRefreshIconAnimating` protocol; the `CYLRefreshComponent
//       (CYLRefreshIconLayout)` methods are a Swift extension in `CYLRefreshComponent.swift` since 2026-11-20 (step 12).
//  [CN] 自 2026-11-19 起 `CYLRefreshIconView` 类（含原 `CYLRefreshIconAttributes` 分类的类成员）用 Swift 编写（`CYLRefreshIconView.swift`，
//       docs/Swift-Migration.md 第 7 步），Objective-C API 不变；本头文件保留其前向声明与 `CYLRefreshIconAnimating` 协议；
//       `CYLRefreshComponent (CYLRefreshIconLayout)` 的方法自 2026-11-20 起是 `CYLRefreshComponent.swift` 中的 Swift 扩展（第 12 步）。
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

// [EN] The `CYLRefreshComponent (CYLRefreshIconLayout)` methods (`cyl_iconView`, `cyl_usesIconView`,
//      `cyl_setIconAnimationAttributes:forState:`, `cyl_placeIconViewAtCenter:visible:replacingViews:`,
//      `cyl_updateIconViewVisible:replacingViews:`, `cyl_placeIconViewWithTitle:labels:visible:replacingViews:`,
//      `cyl_setIconImages:duration:forState:`, `cyl_showIconImageFrameOf:pullingPercent:`,
//      `cyl_setAnimationImages:duration:forState:`, `cyl_animationImagesForState:`, `cyl_showIdleAnimationFrame`,
//      `cyl_setIconAnimationFilePath:size:forState:`, `cyl_setBundledIconAnimation:size:forState:`) are a Swift extension
//      of the class since 2026-11-20 (`CYLRefreshComponent.swift`, docs/Swift-Migration.md, step 12): Objective-C gets
//      them from the generated Swift header through the umbrella header `CYLTableViewPlaceHolder.h`.
// [CN] `CYLRefreshComponent (CYLRefreshIconLayout)` 的方法自 2026-11-20 起是该类的 Swift 扩展（`CYLRefreshComponent.swift`，
//      docs/Swift-Migration.md 第 12 步）：Objective-C 通过总头文件 `CYLTableViewPlaceHolder.h` 从生成的 Swift 头文件获得它们。

NS_ASSUME_NONNULL_END
