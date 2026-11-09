//
//  CYLPlaceholderItemAnimationPlayer.m
//  CYLTableViewPlaceHolder
//
//  Adapted from CYLTabBarController (`CYLTabBarItemAnimation/`, branch
//  feat/cross-platform-components), MIT License,
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//

#import "CYLPlaceholderItemAnimationPlayer.h"

@implementation CYLPlaceholderItemAnimationBasePlayer

- (instancetype)initWithAnimationView:(UIView *)animationView {
    if (self = [super init]) {
        _animationView = animationView;
    }
    return self;
}

@end
