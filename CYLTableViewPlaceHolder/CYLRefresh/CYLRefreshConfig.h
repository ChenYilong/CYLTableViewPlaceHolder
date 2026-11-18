//
//  CYLRefreshConfig.h
//
//  Created by Frank on 2018/11/27.
//  Copyright © 2018 小码哥. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CYLRefreshComponent, CYLRefreshHeader, CYLRefreshFooter;

NS_ASSUME_NONNULL_BEGIN

@interface CYLRefreshConfig : NSObject

/*!
 * 默认使用的语言版本, 默认为 nil. 将随系统的语言自动改变
 */
@property (copy, nonatomic, nullable) NSString *languageCode;

/*!
 * 默认使用的语言资源文件名, 默认为 nil, 即默认的 Localizable.strings.
 *
 * - Attention: 文件名不包含后缀.strings
 */
@property (copy, nonatomic, nullable) NSString *i18nFilename;
/*!
 * i18n 多语言资源加载自定义 Bundle.
 *
 * - Attention: 默认为 nil 采用内置逻辑. 这里设置后将忽略内置逻辑的多语言模式, 采用自定义的多语言 bundle
 */
@property (nonatomic, nullable) NSBundle *i18nBundle;

/*!
 * [EN] Makes the header `-[UIScrollView cyl_installDefaultRefreshControls]` installs where a scroll view has none
 *      (CYLRefreshLayout's `setDefaultRefreshHeaderCreator`). Default nil.
 * [CN] 生成 `-[UIScrollView cyl_installDefaultRefreshControls]` 为没有刷新头的滚动视图安装的刷新头（对应 CYLRefreshLayout 的
 *      `setDefaultRefreshHeaderCreator`）。默认 nil。
 */
@property (copy, nonatomic, nullable) CYLRefreshHeader * _Nullable (^defaultHeaderCreator)(UIScrollView *scrollView);
/*!
 * [EN] Makes the footer `-[UIScrollView cyl_installDefaultRefreshControls]` installs where a scroll view has none
 *      (CYLRefreshLayout's `setDefaultRefreshFooterCreator`). Default nil.
 * [CN] 生成 `-[UIScrollView cyl_installDefaultRefreshControls]` 为没有尾部的滚动视图安装的尾部（对应 CYLRefreshLayout 的
 *      `setDefaultRefreshFooterCreator`）。默认 nil。
 */
@property (copy, nonatomic, nullable) CYLRefreshFooter * _Nullable (^defaultFooterCreator)(UIScrollView *scrollView);
/*!
 * [EN] Sets up every control once, when it is first attached to a scroll view, before its own
 *      `didAttachToScrollView:` (CYLRefreshLayout's `setDefaultRefreshInitializer`). Default nil.
 * [CN] 每个控件第一次挂到滚动视图时调用一次，在其 `didAttachToScrollView:` 之前（对应 CYLRefreshLayout 的
 *      `setDefaultRefreshInitializer`）。默认 nil。
 */
@property (copy, nonatomic, nullable) void (^defaultInitializer)(__kindof CYLRefreshComponent *component);

/*!
 * Singleton Config instance
 */
@property (class, nonatomic, readonly) CYLRefreshConfig *defaultConfig NS_SWIFT_NAME(default);

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
