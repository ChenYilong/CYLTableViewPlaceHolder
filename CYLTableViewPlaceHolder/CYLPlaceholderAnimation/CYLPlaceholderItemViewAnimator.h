//
//  CYLPlaceholderItemViewAnimator.h
//  CYLTableViewPlaceHolder
//
//  Adapted from CYLTabBarController (`CYLTabBarItemAnimation/`, branch
//  feat/cross-platform-components), MIT License,
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYLPlaceholderItemAnimator.h"
#import "CYLPlaceholderItemAnimationPlayableView.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] A ready-made `CYLPlaceholderItemAnimator` for libraries whose view plays itself (`CYLPlaceholderItemAnimationPlayableView`).
 *      It does everything that is the same for such libraries, so a library only describes itself and provides its view:
 *      - matches files by extension;
 *      - splits a tab's URL into the file and its options (`CYLTabBarAnimationURLWithOptions()`) and asks the view
 *        provider for a view;
 *      - plays, stops and shows the last frame through the view, and applies `CYLTabBarAnimationDarkColors` only when
 *        Dark Mode changes, resolved for the trait collection.
 *      A library registers one in its `+load`:
 *
 *          [CYLPlaceholderItemAnimatorRegistry registerAnimator:
 *              [[CYLPlaceholderItemViewAnimator alloc] initWithIdentifier:@"Rive"
 *                                                     fileExtensions:@[ @"riv" ]
 *                                                      attributeKeys:@{ CYLTabBarAnimationURL : CYLTabBarRiveURL }
 *                                                       viewProvider:[CYLRiveTabBarItemAnimationView class]]];
 *
 * [CN] 为视图自己会播放（`CYLPlaceholderItemAnimationPlayableView`）的动画库准备的现成 `CYLPlaceholderItemAnimator`。它完成这类动画库都相同的工作，
 *      动画库只需描述自己并提供视图：
 *      - 按扩展名匹配文件；
 *      - 把 Tab 的 URL 拆分为文件与选项（`CYLTabBarAnimationURLWithOptions()`），并向视图 provider 请求视图；
 *      - 通过视图播放、停止与显示最后一帧，并仅在深色模式变化时应用按 trait collection 解析后的 `CYLTabBarAnimationDarkColors`。
 *      动画库在其 `+load` 中注册一个实例，示例见上。
 */
@interface CYLPlaceholderItemViewAnimator : NSObject <CYLPlaceholderItemAnimator>

/*!
 * [EN] `viewProvider`: the class that makes the views (constructor injection, checked by the compiler); used only when it
 *      adopts `CYLPlaceholderItemAnimationViewProviding`. A Swift class is passed from Objective-C through the module's
 *      generated `…-Swift.h` header.
 * [CN] `viewProvider`：创建视图的类（构造器注入，由编译器检查）；仅在其遵守 `CYLPlaceholderItemAnimationViewProviding` 时使用。Swift 类通过模块
 *      生成的 `…-Swift.h` 头文件从 Objective-C 传入。
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
                    fileExtensions:(NSArray<NSString *> *)fileExtensions
                     attributeKeys:(nullable NSDictionary<NSString *, NSString *> *)attributeKeys
                      viewProvider:(nullable Class<CYLPlaceholderItemAnimationViewProviding>)viewProvider NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/*!
 * [EN] Where the views come from (dependency injection): by default the class given at initialization. Set any class
 *      adopting `CYLPlaceholderItemAnimationViewProviding` (e.g. a test double); nil goes back to the default.
 * [CN] 视图的来源（依赖注入）：默认为初始化时传入的类。可以设置为任意遵守 `CYLPlaceholderItemAnimationViewProviding` 的类（例如测试替身）；设为 nil
 *      恢复默认。
 */
@property (nonatomic, null_resettable) Class<CYLPlaceholderItemAnimationViewProviding> viewProvider;

@end

NS_ASSUME_NONNULL_END
