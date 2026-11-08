//
//  KLUtility.m
//  KLTableViewAndCollectionViewPlaceholder
//
//  Created by 柯磊 on 2017/2/24.
//  Copyright © 2017年 https://github.com/klaus01 All rights reserved.
//

#import "KLUtility.h"
#import <objc/runtime.h>

void swizzleMethod(Class c, SEL original, SEL alternative) {
    Method orgMethod = class_getInstanceMethod(c, original);
    Method altMethod = class_getInstanceMethod(c, alternative);
    
    if (class_addMethod(c, original, method_getImplementation(altMethod), method_getTypeEncoding(altMethod))) {
        class_replaceMethod(c, alternative, method_getImplementation(orgMethod), method_getTypeEncoding(orgMethod));
    } else {
        method_exchangeImplementations(orgMethod, altMethod);
    }
}

