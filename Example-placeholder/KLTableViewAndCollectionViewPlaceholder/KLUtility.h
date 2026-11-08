//
//  KLUtility.h
//  KLTableViewAndCollectionViewPlaceholder
//
//  Created by 柯磊 on 2017/2/24.
//  Copyright © 2017年 https://github.com/klaus01 All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kNewClassPrefix = @"_KLPlaceholder_";

extern void swizzleMethod(Class c, SEL original, SEL alternative);

