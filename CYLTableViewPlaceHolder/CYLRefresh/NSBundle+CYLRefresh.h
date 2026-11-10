//
//  NSBundle+CYLRefresh.h
//  CYLRefresh
//
//  Created by MJ Lee on 16/6/13.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (CYLRefresh)
/// The library's single resource bundle, CYLTableViewPlaceHolder.bundle. It holds the refresh images and the
/// refresh strings (`<language>.lproj/CYLRefresh.strings`) next to the placeholder's resources; CYLRefresh.bundle
/// no longer exists.
+ (instancetype)cyl_refreshBundle;
+ (UIImage *)cyl_arrowImage;
+ (UIImage *)cyl_trailArrowImage;
+ (NSString *)cyl_localizedStringForKey:(NSString *)key value:(nullable NSString *)value;
+ (NSString *)cyl_localizedStringForKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
