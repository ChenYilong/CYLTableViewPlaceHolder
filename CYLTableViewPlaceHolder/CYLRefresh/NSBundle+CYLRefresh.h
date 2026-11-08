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
+ (instancetype)cyl_refreshBundle;
+ (UIImage *)cyl_arrowImage;
+ (UIImage *)cyl_trailArrowImage;
+ (NSString *)cyl_localizedStringForKey:(NSString *)key value:(nullable NSString *)value;
+ (NSString *)cyl_localizedStringForKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
